function flabel_new = transfer_flabel...
    ( xs_old, elems_old, xs_new, elems_new, flabel_old)
% Transfer face-label from the first surface mesh (xs_old, elems_old)
% onto the second surface mesh (xs_new, elems_new)

%#codegen -args {coder.typeof( double(0), [inf,3], [1,0]), 
%#  coder.typeof( int32(0), [inf,4], [1,1]), 
%#  coder.typeof( double(0), [inf,3], [1,0]), 
%#  coder.typeof( int32(0), [inf,4], [1,1]), 
%#  coder.typeof( int32(0), [inf,1], [1,0])}

coder.extrinsic('warning');

assert( isa( xs_old, 'double') && isa( xs_new, 'double'));
assert( isa( elems_old, 'int32') && isa( elems_new, 'int32') && isa( flabel_old, 'int32'));
coder.varsize( 'xs_elem', [4,3]);

% This is a very simple algorithm assuming all the labeled faces are
% on flat patches. It has a time complexity equal to p*n, where p is
% the number of patches and is assumed to be small, and n is the number
% of faces.

npatch = max(flabel_old, [], 1);

%% First, compute the bounding boxes, average normal, and a sample point
%  in each patch
patch_nrm = zeros(npatch, 3);
patch_mag = zeros(npatch, 1);
patch_seedtri = zeros(npatch, 1, 'int32');
patch_seedcnt = nullcopy(zeros(npatch, 3));

% bounding box of patch [[minx,miny,minz],[maxx,maxy,maxz]]...
patch_bb = nullcopy(zeros(npatch, 6));
patch_bb(:,1:3) = realmax; patch_bb(:,4:6) = -realmax;

nrm = nullcopy(zeros(3,1));
for i=1:int32(size(elems_old,1))
    if flabel_old(i)==0; continue; end
    
    patchid = flabel_old(i);
    
    % For each face with nonzero flabel, compute its face normal
    xs_elem = get_elem_coors( xs_old, elems_old, i);
    nrm(1:3,1) = face_normal(xs_elem);
    
    % Compute sum of face normals.
    patch_nrm(patchid, 1:3) = patch_nrm(patchid, 1:3) + nrm';
    mag = norm2_vec(nrm);
    
    % Use largest triangle of each patch as seed.
    if patch_mag(patchid) < mag
        patch_seedtri(patchid) = i;
        patch_mag(patchid) = mag;
        
        patch_seedcnt(patchid,1:3) = sum(xs_elem,1)/size(xs_elem,1);
    end
    
    % Obtain bounding box of patch
    for k=1:3
        patch_bb(patchid,k) = min(patch_bb(patchid,k), min(xs_elem(:,k),[],1));
        patch_bb(patchid,k+3) = max(patch_bb(patchid,k+3), max(xs_elem(:,k),[],1));
    end
end


for i=1:npatch
    patch_nrm(i, 1:3) = patch_nrm(i, 1:3) / norm2_vec(patch_nrm(i, 1:3));

    % Enlarge the bounding box by 20%.
    tol_dist = 0.2*sqrt(patch_mag(i));
    patch_bb(i,1:3) = patch_bb(i,1:3) - tol_dist;
    patch_bb(i,4:6) = patch_bb(i,4:6) + tol_dist;
end

% Build a kd-tree of triangles of new mesh
centers = nullcopy(zeros(size(elems_new,1),3));

for i=1:int32(size(elems_new,1))
    xs_elem = get_elem_coors( xs_new, elems_new, i);
    centers(i,1:3) = sum(xs_elem,1)/size(xs_elem,1);
end

[tree,bboxes] = kdtree_build_3( centers, true);


tris = nullcopy(zeros(size(elems_new,1),1,'int32'));
%% For each patch, find a seed triangle in the new mesh for which the
%  sample point projects onto and is very close.
for i=1:npatch
    min_dist = sqrt(patch_mag(i));
    tol_dist = 0.01*min_dist;
    bb = patch_bb(i,1:6);

    % First, check whether patch_seedtri(i) is the right seed, in case
    % the triangle was not renumbered.
    oldseed = patch_seedtri(i);
    xs_elem_old = get_elem_coors( xs_old, elems_old, oldseed);
    
    % Look through all the elements to find the best match.
    patch_seedtri(i) = 0;
    
    [nfound, tris] = kdtree_search_3( tree, bboxes, bb', tris);
    
    for j=1:nfound
        k = tris(j);
        xs_elem = get_elem_coors( xs_new, elems_new, k);
        
        if inpatch( xs_elem, bb, patch_nrm(i,1:3)')
            cnt = sum(xs_elem,1)/size(xs_elem,1);
            
            dist = min( distance_to_face(cnt, xs_elem_old), ...
                distance_to_face(patch_seedcnt(i,1:3), xs_elem));
            
            if dist < min_dist
                % Take current face as seed triangle
                patch_seedtri(i) = k;
                min_dist = dist;
                if min_dist<=tol_dist; break; end
            end
        end
    end

    if min_dist > tol_dist;
        s = sprintf('The best seed face for patch %d is far from the patch. The distance is %g%% of the patch size.', i, min_dist/tol_dist);
        warning(s);  %#ok<SPWRN>
        assert( patch_seedtri(i) >0);
    end
end

% Construct halfedge data structure
flabel_new = zeros( size( elems_new,1), 1, 'int32');

%% For each patch, starting from the seed triangle label the adjacent 
%  faces in a breadth-first manner.

sibhes = determine_sibling_halfedges( size(xs_new,1), elems_new);
flags = nullcopy(zeros(size(elems_new,1),1, 'int32'));
queue = nullcopy(zeros(size(elems_new,1),1, 'int32'));

for i=1:npatch
    bb = patch_bb( i,1:6);

    queue(1) = patch_seedtri(i); qindex=1; qlen=1; 
    flags(queue(1)) = i;
    
    while qindex<=qlen
        fid = queue(qindex);
        
        xs_elem = get_elem_coors( xs_new, elems_new, fid);
        
        % check whether the face is in the patch
        if inpatch( xs_elem, bb, patch_nrm(i,1:3)')
            assert(flabel_new(fid)==0);
            flabel_new( fid) = i;
            
            % Add more faces into the queue
            for k=1:3
                fneighbor = heid2fid( sibhes( fid, k));
                if fneighbor > 0 && flags(fneighbor) ~= i
                    qlen = qlen + 1;
                    queue(qlen) = fneighbor;
                    flags(fneighbor) = i;
                end
            end
        end
        
        qindex = qindex + 1;
    end
end

function xs_elem = get_elem_coors( xs, elems, i)
if size(elems,2)==4 && elems(i,4)~=0
    xs_elem = xs(elems(i,1:4),1:3);
else
    xs_elem = xs(elems(i,1:3),1:3);
end

function b = inpatch( xs_elem, bb, patch_nrm)
% tol_nrm = cos( 5/180*pi);
tol_nrm = 0.996194698091746;

assert( size(xs_elem,1)>=3 && size(xs_elem,2)==3 && length(bb)==6);
if in_bbox( xs_elem(1,1:3), bb) && in_bbox( xs_elem(2,1:3), bb) && ...
        in_bbox( xs_elem(3,1:3), bb) && ...
        (size(xs_elem,1)==3 || in_bbox( xs_elem(size(xs_elem,1),1:3), bb))
    
    nrm = face_normal(xs_elem);
    nrm = nrm / (norm2_vec(nrm)+1.e-100);
    
    b = patch_nrm'*nrm > tol_nrm;
else
    b = false;
end

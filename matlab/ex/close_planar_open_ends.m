function  [xs_new, tris_new, flabels] = close_planar_open_ends( xs, tris) %#codegen 
% CLOSE_PLANAR_OPEN_ENDS    Close up planar open ends.
% [XS_NEW, TRIS_NEW, FLABLES] = CLOSE_PLANAR_OPEN_ENDS( XS, TRIS) call
%    Triangle to close up planar open ends of a surface mesh and append the
%    new vertices and faces to the end of the vertex and face lists.
%    XS is nx3 and TRIS is mx3. The new mesh is give by xs_new and tris_new.
%    The faces of each patch are assigned a positive patch ID, as indicated
%    in flabels.

%#codegen -args {coder.typeof(0,[inf,3],[1,0]), coder.typeof(int32(0),[inf,3],[1,0])}

coder.extrinsic('fprintf');

[xs, tris] = remove_duplicate_nodes( xs, tris);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract border edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nv = int32(size(xs,1)); nt = int32(size(tris,1));
[b2v, bdedgs] = extract_border_curv_tri(nv, tris);
nb = int32(length(b2v));

% Verify boundary curve does not have self-intersections
nadjbvs = zeros(nb,1,'int32');
for ii=1:int32(size(bdedgs,1))
    nadjbvs(bdedgs(ii,1)) = nadjbvs(bdedgs(ii,1))+1;
    nadjbvs(bdedgs(ii,2)) = nadjbvs(bdedgs(ii,2))+1;
end

for ii=1:nb
    if nadjbvs(ii)~=2
        fprintf(1, 'Warning: Boundary vertex %d has %d incident border edges. Input mesh is invalid.\n', ...
            b2v(ii), nadjbvs(ii));
    end
end

% Construct half-vertex data structure
opphvs = determine_nextpage_curv(nb, bdedgs);
b2hv = determine_incident_halfverts(bdedgs, opphvs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Arrange border edges into individual curves and fill the holes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xs_new = [xs; nullcopy(zeros( nb*10, 3))];
tris_new = [tris; nullcopy(zeros( nb*10, 3, 'int32'))];
verts_curv = nullcopy(zeros( nb,1, 'int32'));

flabels = nullcopy(zeros( nt+nb*10, 1, 'int32')); label = int32(0);
flags = false(nb,1);
for ii=1:nb
    if flags(ii); continue; end
    
    ne = 0;
    
    % Obtain first half-vertex
    hv = b2hv(ii);
    fid = hvid2eid(hv); org = bdedgs( fid, 1); start = org;
    while ~flags( org)
        flags(org) = true;
        
        ne = ne+1; verts_curv(ne) = org;
        hv  = opphvs( fid, 1);
        fid = hvid2eid(hv); org = bdedgs( fid,1);
    end
    if start ~= org || any( nadjbvs(verts_curv(1:ne))~=2)
        fprintf(1, 'Error: Boundary curve with vertex %d has self-intersection.\n', b2v(org));
        continue;
    end
    
    % Triangulate the surface bounded by the curve.
    xs_curv = xs(b2v(verts_curv(1:ne)),:);

    [xs_patch, tris_patch, ierror] = triangulate_bounded_area( xs_curv);
    
    if ~ierror
        new_vids = (nv+1):(nv+size(xs_patch,1)-size(xs_curv,1));
        
        node_num = nullcopy(zeros(size(xs_patch,1),1,'int32'));
        node_num(1:size(xs_curv,1)) = b2v(verts_curv(1:ne));
        node_num(int32(size(xs_curv,1))+1:int32(size(xs_patch,1))) = new_vids;
        
        % Increase the number of elements
        nv = nv + size(xs_patch,1) - size(xs_curv,1);
        nt_new = nt+size(tris_patch,1);
        
        if size(xs_new,1)<nv % Double its size
            xs_new = [xs_new; zeros(size(xs_new))]; %#ok<AGROW>
        end
        if size(tris_new,1)<nt_new % Double its size
            tris_new = [tris_new; zeros(size(tris_new),'int32')]; %#ok<AGROW>
            flabels = [flabels; zeros(size(tris_new,1),1,'int32')]; %#ok<AGROW>
        end
        
        xs_new(new_vids,:) = xs_patch(size(xs_curv,1)+1:end,:);
        tris_new(nt+1:nt_new,:) = node_num(tris_patch);
        assert( all(all(tris_new(nt+1:nt_new,:)<=nv)));
        label = label + 1; flabels(nt+1:nt_new) = label; nt = nt_new;
    else
        fprintf(1,'Boundary curve with vertex %d is invalid. Skipping... \n',b2v(ii));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prepare output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xs_new = xs_new(1:nv,:);
tris_new = tris_new(1:nt,:);
flabels = flabels(1:nt,:);

function [xs, tris] = remove_duplicate_nodes( xs, tris)
% Remove duplicate nodes in the mesh. Assuming link condition is not violated.

nv = int32(size(xs,1));
ntris = int32(size(tris,1));
nodemap = 1:nv;

next = [2 3 1]; prev = [3 1 2];

hasdup = false;
for ii=1:ntris 
    if isequal(xs(tris(ii,1),:), xs(tris(ii,2),:)) && ...
            isequal(xs(tris(ii,1),:), xs(tris(ii,3),:)) 
        for jj=1:3
            if tris(ii,jj)<tris(ii,next(jj)) && tris(ii,jj)<tris(ii,prev(jj))
                nodemap( tris(ii,next(jj))) = nodemap( tris(ii,jj));
                nodemap( tris(ii,prev(jj))) = nodemap( tris(ii,jj));
            end
            tris(ii,:) = 0;
            hasdup = true;
            break;
        end
    else
        for jj=1:3
            if isequal(xs(tris(ii,next(jj)),:), xs(tris(ii,jj),:))
                if tris(ii,jj) < tris(ii,next(jj))
                    nodemap( tris(ii,next(jj))) = nodemap( tris(ii,jj));
                else
                    nodemap( tris(ii,jj)) = nodemap( tris(ii,next(jj)));
                end
                
                tris(ii,:) = 0;
                hasdup = true;
                break;
            end
        end
    end
end

if hasdup
    fprintf(1, 'Warning: Input mesh has duplicate nodes. Removing...');
    % Recompute nodemap and remove unused vertices
    for ii=1:nv
        v = nodemap(ii);
        while v ~= nodemap(v); 
            v = nodemap(v); 
        end
        nodemap(ii) = v;
    end

    count = 0;
    for ii=1:nv
        if nodemap(ii) == ii; 
            count = count + 1; 
            nodemap(ii) = count;
            if count < ii; xs(count,:) = xs(ii,:); end
        else
            assert( nodemap(nodemap(ii)) <= nodemap(ii));
            nodemap(ii) = nodemap(nodemap(ii));
        end
    end    
    xs = xs(1:count, :);
    
    ntris_new = 0;
    % Update tris
    for ii=1:ntris
        if tris(ii,1)
            ntris_new = ntris_new + 1;            
            tris( ntris_new, :) = nodemap(tris( ii, :));
        end
    end
    
    tris = tris(1:ntris_new,:);
    fprintf(1, 'Done.\n');
end

function [xs_patch, tris_patch,ierror] = triangulate_bounded_area( xs_curv)
% TRIANGULATE_BOUNDED_AREA   Triangulate bounded area of a given curve

if size(xs_curv,1)<3
    xs_patch = zeros(0,3); tris_patch = zeros(0,3,'int32'); ierror = true; return;
end

nnodes = int32(size(xs_curv,1));

% Make sure there are no duplicate nodes.
dup = isequal(xs_curv(1,:),xs_curv(nnodes,:));
if ~dup
    for ii=2:nnodes
        if isequal(xs_curv(ii-1,:),xs_curv(ii,:)); dup = true; break; end
    end
end
if dup
    xs_patch = zeros(0,3); tris_patch = zeros(0,3,'int32'); ierror = true; return;
end

% First, compute plane containing the points
center = sum(xs_curv)/size(xs_curv,1);
xs_shifted = [xs_curv(:,1)-center(1), xs_curv(:,2)-center(2), xs_curv(:,3)-center(3)];

V = eig3_sorted(xs_shifted'*xs_shifted);

% Project points onto the plane
uvw = xs_shifted * V;
uv = uvw(:,1:2);

% Triangluate surface
%TODO: Support calling Triangle when Agility is used.
triopts = 'pq30gYQ';
edges = [1:nnodes; [2:nnodes,1]]';

[us_new, tris_patch] = triangle( uv, edges, triopts);

% Check whether the boundary curve are the first vertices
[b2v, bdedgs] = extract_border_curv_tri(size(us_new,1), tris_patch);

if length(b2v) ~= nnodes || sum( bdedgs(:,1)<bdedgs(:,2))~=1 && ...
        sum( bdedgs(:,1)>bdedgs(:,2))~=1
    % figure; edgemesh( edges, uv(:,1), uv(:,2),'-o');
    xs_patch = zeros(0,3); tris_patch = zeros(0,3,'int32'); ierror = true; return;
else
    for ii=1:nnodes
        if b2v(ii)~=ii;
            xs_patch = zeros(0,3); tris_patch = zeros(0,3,'int32'); ierror = true; return;
        end
    end
    
    % Label vertices that were contracted.
    ierror = false;
end
    
% Change the coordinates.
xs_patch = us_new * V(:,1:2)';
for k=1:3
    xs_patch(:,k) = xs_patch(:,k)+center(k);
end

% Correct the orientation of the triangles if necessary
if sum( bdedgs(:,1)<bdedgs(:,2))==1
    % Swap first two columns
    tmp = tris_patch(:,1);
    tris_patch(:,1) = tris_patch(:,2);
    tris_patch(:,2) = tmp;
end

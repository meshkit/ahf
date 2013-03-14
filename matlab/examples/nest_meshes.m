function [parent_v, nats_v] = nest_meshes( xs_crs, tris_crs, xs_fine, tris_fine) %#codegen 
% Nest a finer mesh in a coarser mesh.
%
% [PARENTF, NATS] = NEST_MESHES( XS_CRS, TRIS_CRS, XS_FINE, TRIS_FINE)
% Given a coarse mesh and a fine mesh, determine a nesting of the finer 
%     mesh in the coarse mesh. Each face (and edge) of the coarse mesh is 
%     assumed to be union of those of the finer mesh. It returns two 
%     arrays. The first array contains the parent face ID in the coarse
%     mesh for each vertex in the fine mesh. The second array contains
%     the natural coordinates of the vertex within the parent face.

assert( size(xs_crs,2)==3 && size(tris_crs,2)==3);
assert( size(xs_fine,2)==3 && size(tris_fine,2)==3);
assert( size(xs_fine,1)>=int32(size(xs_crs,1)) && size(tris_fine,1)>=int32(size(tris_crs,1)));

% Construct data structures.
sibhes_crs = determine_opposite_halfedge( size(xs_crs, 1), tris_crs);
sibhes_fine = determine_opposite_halfedge( size(xs_fine, 1), tris_fine);

parent_f = zeros( size(tris_fine,1),1, 'int32');
queue = nullcopy(zeros(size(tris_fine,1),1, 'int32'));

while 1
    seedface = int32(0);
    % Select a face without parent as the seed
    for i=1:int32(size(tris_fine,1))
        if parent_f(i)==0
            seedface = i; break;
        end
    end
    if seedface==0; 
        break;
    end
    
    % Use a faces in the finer mesh as seed and locate its parent face.
    verts = tris_fine( seedface, 1:3);
    v1=xs_fine(verts(2),1:3)-xs_fine(verts(1),1:3);
    v2=xs_fine(verts(3),1:3)-xs_fine(verts(2),1:3);
    v3=xs_fine(verts(1),1:3)-xs_fine(verts(3),1:3);
    tol_dist = sqrt(min(min(v1*v1', v2*v2'), v3*v3'));
    
    % Loop through source faces to locate the triangle that is the closest.
    mindist = tol_dist;
    seedparent = int32(0);
    
    for i=1:int32(size(tris_crs,1))
        xs_tri = xs_crs( tris_crs(i,1:3),1:3);
        
        % Do a quick checking based on bonding box.
        bbox = compute_bbox( xs_tri);
        bbox(1:3) = bbox(1:3) - tol_dist; bbox(4:6) = bbox(4:6) + tol_dist;
        
        if ~in_bbox( xs_fine( verts(1),1:3), bbox) || ...
                ~in_bbox( xs_fine( verts(2),1:3), bbox) || ...
                ~in_bbox( xs_fine( verts(3),1:3), bbox)
            continue;
        end
        
        % Check whether the distance is the minimum.
        dist = 0;
        j = int32(1);
        while dist < mindist && j<=3
            dist = max(dist, distance_to_face( xs_fine( verts(j),1:3), xs_tri));
            j = j+1;
        end
        
        if dist < mindist
            mindist = dist;
            seedparent = i;
            
            % If precision is high enough, then stop.
            if mindist<tol_dist*1.e-6; break; end
        end
    end
    
    assert( seedparent>0);
    parent_f(seedface) = seedparent;
    
    %% Starting from seed face and its parent, move from neighbor to neighbor
    % on the coarse mesh to locate their parent faces.    
    queue(1) = seedface; qindex=1; qlen=1;
    
    while qindex<=qlen
        fid = queue(qindex);
        
        % Check the incident Add more faces into the queue
        for k=1:3
            fneighbor = heid2fid( sibhes_fine( fid, k));
            
            % If the neighbor face has not been checked
            if fneighbor == 0 || parent_f(fneighbor); continue; end
            
            qlen = qlen + 1;
            queue(qlen) = fneighbor;
            
            % Determine the parent face of the face
            xs_tri = xs_fine( tris_fine( fneighbor, 1:3), 1:3);
            parent_f(fneighbor) = get_parent_face( xs_tri, ...
                parent_f(fid), xs_crs, tris_crs, sibhes_crs);
            
            assert( parent_f (fneighbor)~=0);
        end
        
        qindex = qindex + 1;
    end
end

%% Finally, compute the parent and natural coordinates of vertices
parent_v = zeros( size(xs_fine,1),1, 'int32');
nats_v = double(zeros( size(xs_fine,1),2), 'int32');
for i=1:int32(size(tris_fine,1))
    for j=1:3
        v = tris_fine( i,j);
        
        if parent_v(v); continue; end
        
        % Project vertex onto the parent face of the face
        parent_v(v) = parent_f(i);
        xs_tri = xs_crs( tris_crs(parent_f(i),1:3), 1:3);
        nats_v(v,:) = project_pnt_tri( xs_fine( v,1:3), xs_tri);
    end
end

function parent = get_parent_face( xs_tri, ...
    seedface, xs_crs, tris_crs, sibhes_crs) 
% Locate the parent face in the coarse mesh for the face fid 
%    in the fine mesh. The parent face must be either the seedface
%    or an incident face of the seedface
v1=xs_tri(2,:)-xs_tri(1,:);
v2=xs_tri(3,:)-xs_tri(2,:);
v3=xs_tri(1,:)-xs_tri(3,:);
tol_dist = sqrt(min(min(v1*v1', v2*v2'), v3*v3'));

% Loop through source faces to locate the triangle that is the closest.
mindist = tol_dist;
parent = int32(0);

faces = [seedface, heid2fid( sibhes_crs(seedface, 1)), ...
    heid2fid( sibhes_crs(seedface, 2)), heid2fid( sibhes_crs(seedface, 3))];

for i=1:4
    xs_tri_crs = xs_crs( tris_crs(faces(i),1:3),1:3);
    
    % Check whether the distance is the minimum.
    dist = 0;
    j = int32(1);
    while dist < mindist && j<=3
        dist = max(dist, distance_to_face( xs_tri(j,1:3), xs_tri_crs));
        j = j+1;
    end
    
    if dist < mindist
        mindist = dist;
        parent = faces(i);
        
        % If precision is high enough, then stop.
        if mindist < tol_dist*1.e-6; break; end;
    end
end

assert(mindist < tol_dist*1.e-6);

function nc = project_pnt_tri(p, vs)
% Each row of vs is a vertex.
% Solve the equation the following equation in least squares sense:
%   vs(1,:)*(1-xi-eta) + vs(2,:)*xi + vs(3,:)*eta = p;

A = [vs(2,:)'-vs(1,:)', vs(3,:)'-vs(1,:)'];
b = p' - vs(1,:)';

nc = solve3x2(A, b);

if abs(nc(1))<1.e-8; nc(1)=0; elseif abs(1-nc(1))<1.e-8; nc(1)=1; end
if abs(nc(2))<1.e-8; nc(2)=0; elseif abs(1-nc(2))<1.e-8; nc(2)=1; end
if abs(nc(1)+nc(2)-1)<1.e-8
    if abs(nc(1)-0.5)<1.e-8;
        nc(1)=0.5;
    elseif abs(nc(1)-0.25)<1.e-8; 
        nc(1)=0.25;
    elseif abs(nc(2)-0.25)<1.e-8; 
        nc(1)=0.75;
    elseif abs(nc(1)-0.125)<1.e-8; 
        nc(1)=0.125;
    elseif abs(nc(2)-0.125)<1.e-8; 
        nc(1)=0.875;
    end
    nc(2) = 1-nc(1);
end

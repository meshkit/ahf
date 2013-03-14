function sibhes = determine_opposite_halfedge_tri(nv, tris, sibhes) %#codegen
%DETERMINE_OPPOSITE_HALFEDGE_TRI Determine opposite half-edges for triangle 
%mesh.
% DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS,SIBHES) Determines
% opposite half-edges for triangle mesh. The following explains the input
% and output arguments.
%
% SIBHES = DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS)
% SIBHES = DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS,SIBHES)
% Computes mapping from each half-edge to its opposite half-edge for 
% triangle mesh.
%
% Convention: Each half-edge is indicated by <face_id,local_edge_id>.
% We assign 2 bits to local_edge_id (starts from 0).
%
% See also DETERMINE_OPPOSITE_HALFEDGE

coder.inline('never');

nepE = int32(3);  % Number of edges per element
next = int32([2,3,1]);
inds = int32(1:3);

ntris = int32(size(tris,1));
%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
for ii=1:ntris
    if tris(ii,1)==0; ntris=ii-1; break; end
    is_index(tris(ii,inds)+1) = is_index(tris(ii,inds)+1) + 1;
end
is_index(1) = 1;
for ii=1:nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

ne = ntris*nepE;
v2nv = nullcopy(zeros( ne,1, 'int32'));  % Vertex to next vertex in each halfedge.
v2he = nullcopy(zeros( ne,1, 'int32'));  % Vertex to half-edge.
for ii=1:ntris
    v2nv(is_index( tris(ii,inds))) = tris(ii,next);
    v2he(is_index( tris(ii,inds))) = 4*ii-1+inds;
    is_index(tris(ii,inds)) = is_index(tris(ii,inds)) + 1;
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;
%% Set sibhes
if nargin<3 || isempty(sibhes)
    sibhes = zeros(size(tris,1), nepE, 'int32');
else
    assert( size(sibhes,1)>=ntris && size(sibhes,2)>=nepE);
    sibhes(:) = 0;
end

for ii=1:ntris
    for jj=int32(1):3
        if sibhes(ii,jj); continue; end
        v = tris(ii,jj); vn = tris(ii,next(jj));

        % LOCATE: Locate index col in v2nv(first:last)
        found = int32(0);
        for index = is_index(vn):is_index(vn+1)-1
            if v2nv(index)==v
                opp = v2he(index);
                sibhes(ii,jj) = opp;
                %sibhes(heid2fid(opp),heid2leid(opp)) = ii*4+jj-1;
                sibhes(bitshift(uint32(opp),-2),mod(opp,4)+1) = ii*4+jj-1;

                found = found + 1;
            end
        end

        % Check for consistency
        if found>1
            error( 'Input mesh is not an oriented manifold.');
        elseif ~found
            for index = is_index(v):is_index(v+1)-1
                if v2nv(index)==vn && int32(bitshift( uint32(v2he(index)),-2))~=ii
                    if nargin==3
                        error( 'Input mesh is not oriented.');
                    else
                        sibhes = zeros(0,3, 'int32'); return;
                    end
                end
            end
        end
    end
end

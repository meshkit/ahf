function sibhes = determine_opposite_halfedge_quad(nv, quads, sibhes) %#codegen 
%DETERMINE_OPPOSITE_HALFEDGE_QUAD Determine the opposite half-edge.
% DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,SIBHES) Determines
% the opposite half-edge for a quadrilateral or mixed (quad-dominant) mesh.
% The following explains the input and output arguments.
%
% SIBHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS)
% SIBHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,SIBHES)
% Computes mapping from each half-edge to its opposite half-edge.
%
% Convention: Each half-edge is indicated by <face_id,local_edge_id>.
% We assign 2 bits to local_edge_id (starts from 0).
%
% See also DETERMINE_OPPOSITE_HALFEDGE

nepE = int32(4);  % Number of edges per element
next3 = int32([2,3,1]);
next4 = int32([2,3,4,1]);
inds3 = int32(1:3);
inds4 = int32(1:4);

nquads = int32(size(quads,1));

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1, 'int32');
for ii=1:nquads
    if quads(ii,1)==0; nquads=ii-1; break; end
    if quads(ii,4)==0
        is_index(quads(ii,inds3)+1) = is_index(quads(ii,inds3)+1) + 1;
    else
        is_index(quads(ii,inds4)+1) = is_index(quads(ii,inds4)+1) + 1;
    end
end
is_index(1) = int32(1);
for ii=1:nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

ne = nquads*nepE;
v2nv = nullcopy(zeros( ne,1, 'int32'));  % Vertex to next vertex in each halfedge.
v2he = nullcopy(zeros( ne,1, 'int32'));  % Vertex to half-edge.
for ii=1:nquads
    if quads(ii,4)==0
        v2nv(is_index( quads(ii,inds3))) = quads(ii,next3);
        v2he(is_index( quads(ii,inds3))) = 4*ii-1+inds3;
        is_index(quads(ii,inds3)) = is_index(quads(ii,inds3)) + 1;
    else
        v2nv(is_index( quads(ii,inds4))) = quads(ii,next4);
        v2he(is_index( quads(ii,inds4))) = 4*ii-1+inds4;
        is_index(quads(ii,inds4)) = is_index(quads(ii,inds4)) + 1;
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set sibhes
if nargin<3 || isempty(sibhes)
    sibhes = zeros(size(quads,1), nepE, 'int32');
else
    assert( size(sibhes,1)>=nquads && size(sibhes,2)>=nepE);
    sibhes(:) = 0;
end

for ii=1:nquads
    
    for jj=1:3+int32(quads(ii,4)~=0)
        if sibhes(ii,jj); continue; end
        v = quads(ii,jj); 
        if quads(ii,4)~=0; 
            vn = quads(ii,next4(jj));
        else
            vn = quads(ii,next3(jj));
        end

        % LOCATE: Locate index col in v2nv(first:last)
        found = 0;
        for index = is_index(vn):is_index(vn+1)-1
            if v2nv(index)==v
                opp = v2he(index);
                sibhes(ii,jj) = opp;
                % sibhes(heid2fid(opp),heid2leid(opp)) = ii*4+jj-1;
                sibhes( bitshift( uint32(opp),-2),mod(opp,4)+1) = ii*4+jj-1;

                found = found + 1;
            end
        end

        % Check for consistency
        if found>1
            error( 'Input mesh is not an oriented manifold.');
        elseif ~found
            for index = is_index(v):is_index(v+1)-1
                if v2nv(index)==vn && int32(bitshift(uint32(v2he(index)),-2))~=ii
                    if nargin==3
                        error( 'Input mesh is not oriented.');
                    else
                        sibhes = zeros(0,nepE, 'int32'); return;
                    end
                end
            end
        end
    end
end

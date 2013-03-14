function [sibhes, manifold, oriented] = determine_sibling_halfedges(nv, elems, varargin)
%DETERMINE_SIBLING_HALFEDGES constructs an extended half-edge data structure
%  for a non-oriented or non-manifold surface mesh. It works for both
%  triangle and quadrilateral meshes that are either linear and quadratic.
%
%    [SIBHES, MANIFOLD, ORIENTED] = DETERMINE_SIBLING_HALFEDGES(NV,ELEMS)
%
% Computes mapping from each half-edge to a sibling halfedge for a 
% non-oriented or non-manifold surface mesh. The halfedges around an edge 
% are in a cyclic order of the elements.
% At output, it returns SIBHES, and also logical variable indicating
% whether the mesh is a manifold, and if so whether it is oriented.
%
% Usage:
%  The following functionscalls set up the extended half-edge data structure:
%  >> sibhes = determine_sibling_halfedges(nv, elems);
%  >> v2he = determine_incident_halfedges(nv, elems, sibhes);
%
%  Then 
%  >> heid_1 = v2he(v)
%  gives a half-edge incident on vertex v.
%  >> heid_2 = sibhes( heid2fid(heid_1), heid2leid(heid_1))
%  gives the next half-edge incident around the edge,
%  >> heid_3 = sibhes( heid2fid(heid_2), heid2leid(heid_2))
%  gives the third half-edge incident around the edge.
%  Repeat until heid_n == heid_1.
%
% See also DETERMINE_INCIDENT_HALFEDGES.

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, inf])}

% Convention: Each half-edge is identified by <face_id,local_edge_id>.
%             We assign 2 bits to local_edge_id.

nvpE = int32(size(elems,2));  % Number of vertices per element
if nvpE==4 || nvpE==8 || nvpE==9
    nepE = int32(4); % Number of edges per element
else
    assert( nvpE==3 || nvpE==6);
    nepE = int32(3); % Number of edges per element
end
next = int32([2,3,4,1]);

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
nelems = int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems = ii-1; break; end
    
    hasthree = nepE~=4 || ~elems(ii,4);
    for j=1:4-int32(hasthree)
        k = elems(ii,j)+1; is_index(k) = is_index(k) + 1;
    end
end

is_index(1) = 1;
for ii=1:nv; is_index(ii+1) = is_index(ii) + is_index(ii+1); end

ne = nelems*nepE;
v2nv = nullcopy(zeros( ne,1,'int32'));  % Vertex to next vertex in each halfedge.
v2he = nullcopy(zeros( ne,1,'int32'));  % Vertex to halfedge.
for ii=1:nelems
    hasthree = nepE~=4 || ~elems(ii,4);
    for j=1:4-int32(hasthree)
        k = elems(ii,j);

        v2nv(is_index( k)) = elems(ii,next(j+int32(hasthree & j==3)));
        v2he(is_index( k)) = fleids2heid(ii, j);
        is_index(k) = is_index(k) + 1;
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set sibhes
if nargin<3 || isempty(varargin{1})
    sibhes = zeros(nelems, nepE, 'int32');
else
    sibhes = varargin{1};
    sibhes(:) = 0;
end

manifold = true; oriented = true;

for ii=int32(1):nelems
    hasthree = nepE~=4 || ~elems(ii,4);
    for jj=1:4-int32(hasthree)
        v = elems(ii,jj); vn = elems(ii,next(jj+int32(hasthree & jj==3)));
        if vn<v; continue; end

        first_heid = fleids2heid(ii, jj);
        prev_heid = first_heid;
        nhes = 0;

        % LOCATE: Locate index in v2nv(first:last)
        for index = is_index(vn):is_index(vn+1)-1
            if v2nv(index)==v
                sibhes(heid2fid(prev_heid),heid2leid(prev_heid)) = v2he(index);
                prev_heid = v2he(index);
                nhes = nhes+1;
            end
        end

        % Check for halfedges in the same orientation
        for index = is_index(v):is_index(v+1)-1
            if v2nv(index)==vn && heid2fid(v2he(index))~=ii
                sibhes(heid2fid(prev_heid),heid2leid(prev_heid)) = v2he(index);
                prev_heid = v2he(index);
                nhes = nhes+1;
                oriented = false;
            end
        end

        if prev_heid ~= first_heid
            % Close up the cycle
            sibhes(heid2fid(prev_heid),heid2leid(prev_heid)) = first_heid;
            nhes = nhes+1;
        end

        if nargout>1 && manifold && nhes>2
            manifold = false; oriented = false;
        end
    end
end

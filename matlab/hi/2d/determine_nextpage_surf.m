function nxtpgs = determine_nextpage_surf(nv, elems, nxtpgs) %#codegen
%DETERMINE_NEXTPAGE_SURF constructs an extended half-edge data structure
%  for a non-oriented or non-manifold surface mesh. It works for both
%  triangle and quadrilateral meshes that are either linear and quadratic.
%
% NXTPGS = DETERMINE_NEXTPAGE_SURF(NV,ELEMS)
% NXTPGS = DETERMINE_NEXTPAGE_SURF(NV,ELEMS,NXTPGS)
%
% Computes mapping from each half-edge to the next page for a non-oriented
% or non-manifold surface mesh. The pages around an edge are in cyclic order 
% of the elements. If NXTPGS is not given at input, it is allocated by the
% function.
%
% Usage:
%  The following function calls set up the extended half-edge data structure:
%  >> nxtpgs = determine_nextpage_surf(nv, elems);
%  >> v2he = determine_incident_halfface(elems, nxtpgs);
%
%  Then 
%  >> heid_1 = v2he(v)
%  gives a half-edge incident on vertex v.
%  >> heid_2 = heids( heid2fid(heid_1), heid2leid(heid_1))
%  gives the next half-edge incident around the edge,
%  >> heid_3 = heids( heid2fid(heid_2), heid2leid(heid_2))
%  gives the third half-edge incident around the edge.
%  Repeat until heid_n == heid_1.
%
% See also DETERMINE_OPPOSITE_HALFEDGE, DETERMINE_INCIDENT_HALFEDGES.

% Convention: Each half-edge is identified by <face_id,local_edge_id>.
%             We assign 2 bits to local_edge_id.

nvpE = int32(size(elems,2));  % Number of vertices per element
if nvpE==4 || nvpE==8 || nvpE==9
    nepE = int32(4); % Number of edges per element
    next = int32([2,3,4,1]);
    inds = int32(1:4);
else
    assert( nvpE==3 || nvpE==6);
    nepE = int32(3); % Number of edges per element
    next = int32([2,3,1]);
    inds = int32(1:3);
end

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
nelems = int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems = ii-1; break; end
    is_index(elems(ii,inds)+1) = is_index(elems(ii,inds)+1) + 1;
end
is_index(1) = 1;
for ii=1:nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

ne = nelems*nepE;
v2nv = nullcopy(zeros( ne,1,'int32'));  % Vertex to next vertex in each halfedge.
v2he = nullcopy(zeros( ne,1,'int32'));  % Vertex to half-edge.
for ii=1:nelems
    v2nv(is_index( elems(ii,inds))) = elems(ii,next);
    v2he(is_index( elems(ii,inds))) = 4*ii-1+inds;
    is_index(elems(ii,inds)) = is_index(elems(ii,inds)) + 1;
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set nxtpgs
if nargin<3 || isempty(nxtpgs)
    nxtpgs = zeros(nelems, nepE, 'int32');
else
    nxtpgs(:) = 0;
end

for ii=int32(1):nelems
    for jj=int32(1):nepE
        v = elems(ii,jj); vn = elems(ii,next(jj));
        if vn<v; continue; end

        first_pageid = ii*4+jj-1;
        prev_pageid = first_pageid;

        % LOCATE: Locate index col in v2nv(first:last)
        for index = is_index(vn):is_index(vn+1)-1
            if v2nv(index)==v
                nxtpgs(heid2fid(prev_pageid),heid2leid(prev_pageid)) = v2he(index);
                prev_pageid = v2he(index);
            end
        end

        % Check for consistency
        for index = is_index(v):is_index(v+1)-1
            if v2nv(index)==vn && heid2fid(v2he(index))~=ii
                nxtpgs(heid2fid(prev_pageid),heid2leid(prev_pageid)) = v2he(index);
                prev_pageid = v2he(index);
            end
        end

        if prev_pageid ~= first_pageid
            % Close up the cycle
            nxtpgs(heid2fid(prev_pageid),heid2leid(prev_pageid)) = first_pageid;
        end
    end
end

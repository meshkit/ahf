function nxtpgs = determine_nextpage_curv(nv, edges, nxtpgs) %#codegen
% DETERMINE_NEXTPAGE_CURV constructs an extended half-vertex data
%       structure for a non-oriented or non-manifold curve.
%
% NXTPGS = DETERMINE_NEXTPAGE_CURV(NV,EDGES)
% NXTPGS = DETERMINE_NEXTPAGE_CURV(NV,EDGES,NXTPGS)
%
% Computes mapping from each half-vertex to the next page for a
% non-oriented or non-manifold curve. The pages around a vertex are in
% cyclic order of edge IDs. If NXTPGS is not given at input, it is allocated
% by the function.
%
% Usage:
%  The following function calls setup the extended half-vertex data structure:
%  >> nxtpgs = determine_nextpage_curv(nv, edges);
%  >> v2hv = determine_incident_halfverts(edges, nxtpgs);
%
%  Then 
%  >> hvid_1 = v2hv(v)
%  gives a half-vertex incident on vertex v.
%  >> hvid_2 = hvids( hvid2eid(hvid_1), hvid2lvid(hvid_1))
%  gives the second half-vertex incident on the vertex,
%  >> hvid_3 = hvids( hvid2eid(hvid_2), hvid2lvid(hvid_2))
%  gives the third half-vertex incident on vertex.
%  Repeat until hvid_n == hvid_1.
%
% See also DETERMINE_OPPOSITE_HALFVERT, DETERMINE_INCIDENT_HALFVERTS

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1, 'int32');
nedgs = int32(size(edges,1));
for ii=1:nedgs
    if edges(ii,1)==0; nedgs=ii-1; break; end

    is_index(edges(ii,1)+1) = is_index(edges(ii,1)+1) + 1;
    is_index(edges(ii,2)+1) = is_index(edges(ii,2)+1) + 1;
end
is_index(1) = 1;
for ii=1:nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

nhv = nedgs*2;
v2hv = nullcopy(zeros( nhv,1, 'int32'));  % Vertex to half-vertex.

for ii=1:nedgs
    v2hv( is_index( edges(ii,1:2))) = 2*ii+int32([0,1]);
    is_index( edges(ii,1:2)) = is_index( edges(ii,1:2)) + 1;
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set nxtpgs
if nargin<3 || isempty(nxtpgs)
    nxtpgs =  zeros(size(edges,1), 2, 'int32');
else
    assert( size(nxtpgs,1)>=nedgs && size(nxtpgs,2)>=2);
    nxtpgs(:,:) = 0;
end

for v=1:nv
    last = is_index(v+1)-1;
    
    if last > is_index(v)
        % The vertex has two or more incident halfedges
        hvid_prev = v2hv(last);
        for ii = is_index(v):last
            hvid = v2hv(ii);
            nxtpgs( hvid2eid( hvid_prev), hvid2lvid( hvid_prev)) = hvid;
            hvid_prev = hvid;
        end
    end
end

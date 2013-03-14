function [sibhvs,manifold,oriented] = determine_sibling_halfverts(nv, edges, varargin)
% DETERMINE_SIBLING_HALFVERTS determines the sibling half-vertices for each vertex.
%
% [SIBHVS,MANIFOLD,ORIENTED] = DETERMINE_SIBLING_HALFVERTS(NV, EDGES)
% [SIBHVS,MANIFOLD,ORIENTED] = DETERMINE_SIBLING_HALFVERTS(NV, EDGES, SIBHVS)
%
% Computes mapping from each half-vertex to a sibling half-vertex for a
% non-oriented or non-manifold curve. The sibling half-vertices are in
% a cyclic order. If SIBHVS is not given at input, it is allocated
% by the function.
% At output, it returns SIBHES, and also logical variable indicating
% whether the mesh is a manifold, and if so whether it is oriented.
%
% Usage:
%  The following function calls set up the extended half-vertex data structure:
%  >> sibhvs = determine_sibling_halfverts(nv, edges);
%  >> v2hv = determine_incident_halfverts(nv, edges);
%
%  Then
%  >> hvid_1 = v2hv(v)
%  gives a half-vertex incident on vertex v.
%  >> hvid_2 = sibhvs( hvid2eid(hvid_1), hvid2lvid(hvid_1))
%  gives the second half-vertex incident on the vertex,
%  >> hvid_3 = sibhvs( hvid2eid(hvid_2), hvid2lvid(hvid_2))
%  gives the third half-vertex incident on vertex.
%  Repeat until hvid_n == hvid_1.
%
% See also DETERMINE_INCIDENT_HALFVERTS

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2])}

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

%% Set sibhvs
if nargin<3 || isempty(varargin{1})
    sibhvs =  zeros(size(edges,1), 2, 'int32');
else
    sibhvs = varargin{1};
    assert( size(sibhvs,1)>=nedgs && size(sibhvs,2)>=2);
    sibhvs(:,:) = 0;
end

manifold = true; oriented = true;

for v=1:nv
    last = is_index(v+1)-1;
    
    if last > is_index(v)
        % The vertex has two or more incident halfedges
        hvid_prev = v2hv(last);
        
        for ii = is_index(v):last
            hvid = v2hv(ii);
            sibhvs( hvid2eid( hvid_prev), hvid2lvid( hvid_prev)) = hvid;
            hvid_prev = hvid;
        end
        
        if nargout>1 && manifold
            if last-is_index(v) > 2;
                manifold = false; oriented = false;
            elseif nargout>2 && oriented
                oriented = hvid2lvid(v2hv(is_index(v))) ~= hvid2lvid(hvid_prev);
            end
        end
    end
end

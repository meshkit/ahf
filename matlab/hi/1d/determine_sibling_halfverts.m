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
%#codegen determine_sibling_halfverts_usestruct -args
%#codegen {int32(0), coder.typeof(int32(0), [inf,2]), false}


%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1, 'int32');
nedgs = int32(size(edges,1));
for ii=1:nedgs
    if edges(ii,1)==0; nedgs=ii-1; break; end
    
    is_index(edges(ii,1)+1) = is_index(edges(ii,1)+1) + 1;
    is_index(edges(ii,2)+1) = is_index(edges(ii,2)+1) + 1;
end
is_index(1) = 1;
for ii=int32(1):nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

nhv = nedgs*2;
if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    v2hv = nullcopy(zeros( nhv,1, 'int32'));  % Vertex to half-vertex.
else
    v2hv_eid = nullcopy(zeros( nhv,1, 'int32')); 
    v2hv_lvid = nullcopy(zeros( nhv,1, 'int8')); 
end

if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    for ii=1:nedgs
        for j=int32(1):2
            v2hv( is_index( edges(ii,j))) = elvids2hvid( ii, j);
            is_index( edges(ii,j)) = is_index( edges(ii,j)) + 1;
        end
    end
else
    for ii=1:nedgs
        for j=int32(1):2
            v2hv_eid( is_index( edges(ii,j))) = ii;
            v2hv_lvid( is_index( edges(ii,j))) = j;
            is_index( edges(ii,j)) = is_index( edges(ii,j)) + 1;
        end
    end
end

for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set sibhvs
if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    sibhvs =  zeros(size(edges,1), 2, 'int32');
elseif islogical(varargin{1})
    sibhvs = struct( 'eid', zeros(size(edges,1), 2, 'int32'), ...
        'lvid', zeros(size(edges,1), 2, 'int8'));
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
        
        if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
            hvid_prev = v2hv(last);
            for ii = is_index(v):last
                hvid = v2hv(ii);
                sibhvs( hvid2eid( hvid_prev), hvid2lvid( hvid_prev)) = hvid;
                hvid_prev = hvid;
            end
        else
            eid_prev=v2hv_eid(last);
            lvid_prev=v2hv_lvid(last);
            for ii = is_index(v):last
                sibhvs.eid(eid_prev, lvid_prev) = v2hv_eid(ii);
                sibhvs.lvid(eid_prev, lvid_prev) = v2hv_lvid(ii);
                eid_prev=v2hv_eid(ii);
                lvid_prev=v2hv_lvid(ii);
            end
            
        end
        
        if nargout>1 && manifold
            if is_index(v+1)-is_index(v) > 2;
                manifold = false; oriented = false;
            elseif nargout>2 && oriented
                if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
                    oriented = hvid2lvid(v2hv(is_index(v))) ~= hvid2lvid(hvid_prev);
                else
                    oriented = (v2hv_eid(is_index(v))==eid_prev)&&(v2hv_lvid(is_index(v))==lvid_prev);
                end    
            end
        end
    end
end
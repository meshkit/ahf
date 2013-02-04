function opphvs = determine_opposite_halfvert(nv, edges, opphvs) %#codegen
% DETERMINE_OPPOSITE_HALFVERT determines the opposite half-vertex of each 
% half-vertex of an oriented, manifold curve with or without boundary.
%
% OPPHVS = DETERMINE_OPPOSITE_HALFVERT(NV,EDGES)
% OPPHVS = DETERMINE_OPPOSITE_HALFVERT(NV,EDGES,OPPHVS)
% Computes mapping from each half-vertex to its opposite half-vertex 
% for a curve.
%
% See also DETERMINE_NEXTPAGE_CURV

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

v2av = nullcopy(zeros( nhv,1, 'int32'));  % Vertex to adjacent vertices within edge.
v2hv = nullcopy(zeros( nhv,1, 'int32'));  % Vertex to half-vertex.

for ii=1:nedgs
    v2av( is_index( edges(ii,1:2))) = edges(ii,[2 1]);
    v2hv( is_index( edges(ii,1:2))) = 2*ii+int32([0,1]);

    is_index( edges(ii,1:2)) = is_index( edges(ii,1:2)) + 1;
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

%% Set opphvs
if nargin<3 || isempty(opphvs)
    opphvs = zeros(size(edges,1), 2, 'int32');
else
    assert( size(opphvs,1)>=nedgs && size(opphvs,2)>=2);
    opphvs(:,:) = 0;
end

for ii=1:nedgs
    for jj=int32(1):2
        if opphvs(ii,jj); continue; end
        v = edges(ii,jj); vn = edges(ii,3-jj);

        % LOCATE: Locate index col in v2nv(first:last)
        found = false;
        for index = is_index(v):is_index(v+1)-1
            if v2av(index)~=vn;
                if found;
                    error('Input curve is not manifold at vertex %d. Please use determine_nextpage_curv instead.\n', v);
                end
                opp = v2hv(index);
                opphvs(ii,jj) = opp;
                opphvs(hvid2eid(opp),hvid2lvid(opp)) = ii*2+jj-1;

                found = true;
            end
        end

        % Check for consistency
        if ~found
            for index = is_index(vn):is_index(vn+1)-1
                if v2av(index)==v && hvid2eid(v2hv(index))~=ii
                    if nargin==3
                        error( 'Input curve is not oriented.');
                    else
                        opphvs = zeros(0, 2, 'int32'); return;
                    end
                end
            end
        end
    end
end

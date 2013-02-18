function [b2v, bdtris, facmap] = extract_border_surf_tet...
    (nv, tets, elabel, opphfs, inwards) %#codegen
%EXTRACT_BORDER_SURF_TET Extract border vertices and edges.
% [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS,INWARDS)
% Extracts border vertices and edges of tetrahedral mesh. Return list of
% border vertex IDs and list of border faces.  The following explains the
% input and output arguments.
%
% [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS)
% [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL)
% [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS)
% [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS,INWARDS)
% NV: specifies the number of vertices.
% TETS: contains the connectivity.
% ELABEL: contains a label for each element.
% OPPHFS: contains the opposite half-faces.
% INWARDS: specifies whether the face normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDTRIS: is connectivity of border faces.
% FACMAP: stores mapping to halfface ID
%
% See also EXTRACT_BORDER_SURF

if nargin>=5 && inwards
    % List vertices in counterclockwise order, so that faces are inwards.
    hf_tet = int32([1,2,3; 1 4 2; 2 4 3; 3 4 1]);
else
    % List vertices in counter-clockwise order, so that faces are outwards.
    hf_tet = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
end
isborder = false( nv,1);

if nargin<3; elabel = 0; end
if nargin<4;
    opphfs = nullcopy(zeros(size(tets),'int32'));
    opphfs = determine_opposite_halfface_tet(nv, tets, opphfs);
end

ngbtris = int32(0);
ii=int32(1);
while ii<=int32(size(tets,1))
    if tets(ii,1)==0; break; end
    
    for jj=1:4
        if opphfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                elabel(ii)~=elabel(hfid2cid(opphfs(ii,jj)))
            isborder( tets(ii,hf_tet(jj,:))) = true; ngbtris = ngbtris +1;
        end
    end
    ii = ii + 1;
end

%% Determine border faces
% Define new numbering for border nodes
v2b = zeros(nv,1,'int32');
b2v = nullcopy(zeros(sum(isborder),1,'int32'));
k = int32(1);
for ii=1:nv
    if isborder(ii);
        b2v(k) = ii; v2b(ii) = k; k = k+1;
    end
end

if nargout>1
    bdtris = nullcopy(zeros(ngbtris,3,'int32'));
    if nargout>2; facmap = nullcopy(zeros(ngbtris,1,'int32')); end
    
    count = int32(1); ii=int32(1);
    while ii<=int32(size(tets,1))
        if tets(ii,1)==0; break; end
        
        for jj=int32(1):4
            if opphfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                    elabel(ii) ~= elabel(hfid2cid(opphfs(ii,jj)))
                bdtris(count, :) = v2b(tets(ii,hf_tet(jj,:)));
                
                if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                count = count + 1;
            end
        end
        
        ii = ii + 1;
    end
end

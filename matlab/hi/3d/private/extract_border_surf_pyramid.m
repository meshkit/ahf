function [b2v, bdquads, facmap] = extract_border_surf_pyramid...
    (nv, elems, elabel, sibhfs, inwards) %#codegen
%EXTRACT_BORDER_SURF_PYRAMID Extract border vertices and edges.
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_PYRAMID(NV,ELEMS,ELABEL,SIBHFS,INWARDS)
% Extracts border vertices and edges of a pyramid mesh. Returns list of 
% border vertex IDs and list of border faces. The following explains the
% input and output arguments.
%
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_PYRAMID(NV,ELEMS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_PYRAMID(NV,ELEMS,ELABEL)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_PYRAMID(NV,ELEMS,ELABEL,SIBHFS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_PYRAMID(NV,ELEMS,ELABEL,SIBHFS,INWARDS)
% NV: specifies the number of vertices.
% ELEMS: contains the connectivity.
% ELABEL: contains a label for each element.
% SIBHFS: contains the sibling half-faces.
% INWARDS: specifies whether the face normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDQUADS: is connectivity of border faces.
% FACMAP: stores mapping to halfface ID
%
% See also EXTRACT_BORDER_SURF

nfpE = int32(5); % Number of faces per element

if nargin>=5 && inwards
    % List vertices in clockwise order, so that faces are inwards.
    hf_pyr    = int32([1,2,3,4; 1,5,2,0; 2,5,3,0; 3,5,4,0; 4,5,1,0]);
else
    % List vertices in counter-clockwise order, so that faces are outwards.
    hf_pyr    = int32([1,4,3,2; 1,2,5,0; 2,3,5,0; 3,4,5,0; 4,1,5,0]);
end
isborder = false( nv,1);

if nargin<3; elabel = 0; end
if nargin<4; sibhfs = determine_sibling_halffaces(nv, elems); end

ngbquads = int32(0);
ii=int32(1);
while ii<=int32(size(elems,1))
    if elems(ii,1)==0; break; end
    for jj=1:nfpE
        if sibhfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                elabel(ii)~=elabel(hfid2cid(sibhfs(ii,jj)))
            nvpf = 3+(jj==4);
            isborder( elems(ii,hf_pyr(jj,1:nvpf))) = true; ngbquads = ngbquads +1;
        end
    end
    ii = ii +1 ;
end

%% Determine border faces
% Define new numbering for border nodes
v2b = zeros(nv,1,'int32');
b2v = zeros(sum(isborder),1,'int32');
k = int32(1);
for ii=1:nv
    if isborder(ii);
        b2v(k) = ii; v2b(ii) = k; k = k+1;
    end
end

if nargout>1
    bdquads = nullcopy(zeros(ngbquads,4,'int32'));
    if nargout>2; facmap  = zeros(ngbquads,1,'int32'); end
    
    count = int32(1);
    ii=int32(1);
    while ii<=int32(size(elems,1))
        if elems(ii,1)==0; break; end

        for jj=1:nfpE
            if sibhfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                    elabel(ii)~=elabel(hfid2cid(sibhfs(ii,jj)))
                nvpf = 3+(jj==4);
                bdquads(count,4) = 0;
                bdquads(count, 1:nvpf) = v2b(elems(ii,hf_pyr(jj,1:nvpf)));
                
                if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                count = count + 1;
            end
        end
        ii = ii + 1;
    end
end

function [b2v, bdquads, facmap] = extract_border_surf_hex...
    (nv, elems, elabel, opphfs, inwards) %#codegen
%EXTRACT_BORDER_SURF_HEX Extract border vertices and edges.
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_HEX(NV,ELEMS,ELABEL,OPPHFS,INWARDS)
% Extracts border vertices and edges of hexahedral mesh. Returns list of 
% border vertex IDs and list of border faces. The following explains the
% input and output arguments.
%
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_HEX(NV,ELEMS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_HEX(NV,ELEMS,ELABEL)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_HEX(NV,ELEMS,ELABEL,OPPHFS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_HEX(NV,ELEMS,ELABEL,OPPHFS,INWARDS)
% NV: specifies the number of vertices.
% ELEMS: contains the connectivity.
% ELABEL: contains a label for each element.
% OPPHFS: contains the opposite half-faces.
% INWARDS: specifies whether the face normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDQUADS: is connectivity of border faces.
% FACMAP: stores mapping to halfface ID
%
% See also EXTRACT_BORDER_SURF

nfpE = int32(6); % Number of faces per element

if nargin>=5 && inwards
    % List vertices in clockwise order, so that faces are inwards.
    hf_hex    = int32([1,2,3,4; 1,5,6,2; 2,6,7,3; 3,7,8,4; 4,8,5,1; 5,8,7,6]);
else
    % List vertices in counter-clockwise order, so that faces are outwards.
    hf_hex   = int32([1,4,3,2; 1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 5,6,7,8]);
end
isborder = false( nv,1);

if nargin<3; elabel = 0; end
if nargin<4; opphfs = determine_opposite_halfface_hex(nv, elems); end

ngbquads = int32(0);
ii=int32(1);
while ii<=int32(size(elems,1))
    if elems(ii,1)==0; break; end
    for jj=1:nfpE
        if opphfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                elabel(ii)~=elabel(hfid2cid(opphfs(ii,jj)))
            isborder( elems(ii,hf_hex(jj,:))) = true; ngbquads = ngbquads +1;
        end
    end
    ii = ii +1 ;
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
    bdquads = nullcopy(zeros(ngbquads,4,'int32'));
    if nargout>2; facmap  = nullcopy(zeros(ngbquads,1,'int32')); end
    
    count = 1;
    ii=1;
    while ii<=int32(size(elems,1))
        if elems(ii,1)==0; break; end

        for jj=1:nfpE
            if opphfs(ii,jj) == 0 || size(elabel,1)>1 && ...
                elabel(ii)~=elabel(hfid2cid(opphfs(ii,jj)))
                bdquads(count, :) = v2b(elems(ii,hf_hex(jj,:)));
                
                if nargout>2; facmap(count)=ii*8+jj-1; end
                count = count + 1;
            end
        end
        ii = ii + 1;
    end
end

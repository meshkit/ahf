function [b2v, bdquads, facmap] = extract_border_surf_mixed...
    (nv, elems, elabel, sibhfs, inwards) %#codegen
%EXTRACT_BORDER_SURF_HEX Extract border vertices and edges.
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_MIXED(NV,ELEMS,ELABEL,SIBHFS,INWARDS)
% Extracts border vertices and edges of hexahedral mesh. Returns list of
% border vertex IDs and list of border faces. The following explains the
% input and output arguments.
%
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_MIXED(NV,ELEMS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_MIXED(NV,ELEMS,ELABEL)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_MIXED(NV,ELEMS,ELABEL,SIBHFS)
% [B2V,BDQUADS,FACMAP] = EXTRACT_BORDER_SURF_MIXED(NV,ELEMS,ELABEL,SIBHFS,INWARDS)
% NV: specifies the number of vertices.
% ELEMS: contains the connectivity.
% ELABEL: contains a label for each element.
% SIBHFS: contains the sibling half-faces.
% INWARDS: specifies whether the face normals should be inwards (false by default)
% B2V:     is a mapping from border-vertex ID to vertex ID.
% BDQUADS: is connectivity of border faces.
% FACMAP:  stores mapping to halfface ID
%
% See also EXTRACT_BORDER_SURF_TET

if nargin>=5 && inwards
    % List vertices in clockwise order, so that faces are inwards.
    hf_tet = int32([1,2,3; 1 4 2; 2 4 3; 3 4 1]);
    hf_pyr = int32([1,2,3,4; 1,5,2,0; 2,5,3,0; 3,5,4,0; 4,5,1,0]);
    hf_pri = int32([1,4,5,2; 2,5,6,3; 3,6,4,1; 1 2 3 0; 4 6 5 0]);
    hf_hex = int32([1,2,3,4; 1,5,6,2; 2,6,7,3; 3,7,8,4; 4,8,5,1; 5,8,7,6]);
else
    % List vertices in counter-clockwise order, so that faces are outwards.
    hf_tet = int32([1,3,2; 1 2 4; 2 3 4; 3 1 4]);
    hf_pyr = int32([1,4,3,2; 1,2,5,0; 2,3,5,0; 3,4,5,0; 4,1,5,0]);
    hf_pri = int32([1,2,5,4; 2,3,6,5; 3,1,4,6; 1 3 2 0; 4 5 6 0]);
    hf_hex = int32([1,4,3,2; 1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 5,6,7,8]);
end
isborder = false( nv,1);

if nargin<3; elabel = int32(0); end
if nargin<4; sibhfs = determine_sibling_halffaces(nv, elems); end

ngbquads = int32(0);
offset=int32(1); offset_o=int32(1); ii=int32(1);
while offset < size(elems,1)
    switch elems(offset)
        case {4,10}
            % Tetrahedral
            for jj=1:4
                if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                        elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                    isborder( elems(offset+hf_tet(jj,:))) = true;
                    ngbquads = ngbquads +1;
                end
            end
        case {5,14}
            % Pyramid
            for jj=1:5
                if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                        elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                    nvpf = 3+(jj==1);
                    isborder( elems(offset+hf_pyr(jj,1:nvpf))) = true;
                    ngbquads = ngbquads +1;
                end
            end
        case {6,15,18}
            % Prism
            for jj=1:5
                if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                        elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                    nvpf = 3+(jj<4);
                    isborder( elems(offset+hf_pri(jj,1:nvpf))) = true;
                    ngbquads = ngbquads +1;
                end
            end
        case {8,20,27}
            % Hexhedral
            for jj=1:6
                if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                        elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                    isborder( elems(offset+hf_hex(jj,:))) = true;
                    ngbquads = ngbquads +1;
                end
            end
        otherwise
            error('Unrecognized element type.');
    end
    
    ii = ii + 1;
    offset = offset+elems(offset)+1;
    offset_o = offset_o + sibhfs(offset_o) + 1;
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
    bdquads = zeros(ngbquads,4,'int32');
    if nargout>2; facmap  = nullcopy(zeros(ngbquads,1,'int32')); end
    
    count =int32(1);
    offset=int32(1); offset_o=int32(1); ii=int32(1);
    while offset < size(elems,1)
        switch elems(offset)
            case {4,10}
                for jj=1:4
                    if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                            elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                        bdquads(count, 1:3) = v2b(elems(offset+hf_tet(jj,:)));
                        
                        if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                        count = count + 1;
                    end
                end
            case {5,14}
                for jj=1:5
                    if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                            elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                        nvpf = 3+(jj==1);
                        bdquads(count, 1:nvpf) = v2b(elems(offset+hf_pyr(jj,1:nvpf)));
                        
                        if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                        count = count + 1;
                    end
                end
            case {6,15,18}
                for jj=1:5
                    if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                            elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                        nvpf = 3+(jj<4);
                        bdquads(count, 1:nvpf) = v2b(elems(offset+hf_pri(jj,1:nvpf)));
                        
                        if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                        count = count + 1;
                    end
                end
            case {8,20,27}
                for jj=1:6
                    if sibhfs(offset_o+jj) == 0 || size(elabel,1)>1 && ...
                            elabel(ii)~=elabel(hfid2cid(sibhfs(offset_o+jj)))
                        bdquads(count, :) = v2b(elems(offset+hf_hex(jj,:)));
                        
                        if nargout>2; facmap(count)=clfids2hfid(ii,jj); end
                        count = count + 1;
                    end
                end
            otherwise
                error('Unrecognized element type.');
        end
        
        ii = ii + 1;
        offset = offset+elems(offset)+1;
        offset_o = offset_o + sibhfs(offset_o) + 1;
    end
end

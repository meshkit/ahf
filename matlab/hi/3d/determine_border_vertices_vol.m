function isborder = determine_border_vertices_vol(nv, elems, sibhfs, isborder, quadratic)
% DETERMINE_BORDER_VERTICES_VOL Determine border vertices of a volume mesh.
%
% ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS)
% ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,SIBHFS)
% ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,SIBHFS,ISBORDER)
% ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,SIBHFS,ISBORDER,QUADRATIC)
% Determines border vertices of a volume mesh.  It supports both linear
%    and quadratic elements. It returns bitmap of border vertices. For
%    quadratic elements, vertices on edge and face centers are set to false,
%    unless QUADRATIC is set to true at input.
%
% See also DETERMINE_BORDER_VERTICES_CURV, DETERMINE_BORDER_VERTICES_SURF

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1]),coder.typeof(false, [inf,1]), false}
%#codegen determine_border_vertices_vol_v1 -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1])}
%#codegen determine_border_vertices_vol_v2 -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1])}
%#codegen determine_border_vertices_vol_v3 -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1]),coder.typeof(false, [inf,1])}

if nargin<3 || isempty(sibhfs)
    sibhfs = determine_opposite_halfface(nv, elems);
end
if nargin<4 || isempty(isborder)
    isborder = false(nv,1);
else
    assert(size(isborder,1)>=nv);
end
if nargin<5
    quadratic = false;
end

% List vertices in counter-clockwise order, so that faces are outwards.
hf_tet = int32([1,3,2,7,5,6; 1,2,4,5,9,8; 2,3,4,6,10,9; 3,1,4,7,8,10]);
hf_pyr = int32([1,4,3,2,9,8,7,6,14; 1,2,5,6,11,10,0,0,0; 2,3,5,7,12,11,0,0,0; ...
    3,4,5,8,13,12,0,0,0; 4,1,5,9,10,13,0,0,0]);
hf_pri = int32([1,2,5,4,7,11,13,10,16; 2,3,6,5 8,12,14,11,17; ...
    3,1,4,6,9,10,15,12,18; 1 3 2,9,8,7,0,0,0; 4 5 6,13,14,15,0,0,0]);
hf_hex = int32([1,4,3,2,12,11,10,9,21; 1,2,6,5,9,14,17,13,22; ...
    2,3,7,6,10,15,18,14,23; 3,4,8,7,11,16,19,15,24; ...
    4,1,5,8,13,20,16,12,25; 5,6,7,8,17,18,19,20,26]);

if size(elems,2)==1
    % Mixed elements
    offset=int32(1); offset_o=int32(1); ii=int32(1);
    while offset < size(elems,1)
        switch elems(offset)
            case {4,10}
                % Tetrahedral
                isquadratic = int32(quadratic && elems(offset)>4);
                nvpf = 3*(1+isquadratic);
                
                for jj=1:4
                    if sibhfs(offset_o+jj) == 0
                        for kk=1:nvpf
                            isborder( elems(offset+hf_tet(jj,kk))) = true;
                        end
                    end
                end
            case {5,14}
                % Pyramid
                isquadratic = int32(quadratic && elems(offset)>5);
                for jj=1:5
                    if sibhfs(offset_o+jj) == 0
                        nvpf = int32(3+(jj==1))*(1+isquadratic)+int32(isquadratic && jj==1);
                        for kk=1:nvpf
                            isborder( elems(offset+hf_pyr(jj,kk))) = true;
                        end
                    end
                end
            case {6,15,18}
                % Prism
                isquadratic = int32(quadratic && elems(offset)>6);
                for jj=1:5
                    if sibhfs(offset_o+jj) == 0
                        nvpf = int32(3+(jj<4))*(1+isquadratic)+int32(elems(offset)==18 && jj<4);
                        for kk=1:nvpf
                            isborder( elems(offset+hf_pri(jj,kk))) = true;
                        end
                    end
                end
            case {8,20,27}
                % Hexahedral
                isquadratic = int32(quadratic && elems(offset)>8);
                nvpf = 4*(1+isquadratic) + int32(elems(offset)==27);
                
                for jj=1:6
                    if sibhfs(offset_o+jj) == 0
                        for kk=1:nvpf
                            isborder( elems(offset+hf_hex(jj,kk))) = true;
                        end
                    end
                end
            otherwise
                error('Unrecognized element type.');
        end
        
        ii = ii + 1;
        offset = offset+elems(offset)+1;
        offset_o = offset_o + sibhfs(offset_o) + 1;
    end
else
    % Table for local IDs of incident faces of each vertex.
    switch size(elems,2)
        case {4,10}
            hf = hf_tet;
            isquadratic = int32(quadratic && size(elems,2)>4);
            nvpf = 3 * (1+isquadratic);
        case {5,14}
            hf = hf_pyr;
            isquadratic = int32(quadratic && size(elems,2)>5);
            nvpf = 4 * (1+isquadratic) + 1;
        case {6,15,18}
            hf = hf_pri;
            isquadratic = int32(quadratic && size(elems,2)>6);
            nvpf = 4 * (1+isquadratic) + int32(size(elems,2)==18);
        case {8,20,27}
            hf = hf_hex;
            isquadratic = int32(quadratic && size(elems,2)>8);
            nvpf = 4 * (1+isquadratic) + int32(size(elems,2)==27);
        otherwise
            hf = hf_tet; nvpf = int32(0); %#ok<NASGU>
            error('Unsupported element type');
    end
    nfpE = int32(size(hf,1));
    
    ii=int32(1);
    while ii<=int32(size(elems,1))
        if elems(ii,1)==0; break; end
        
        for jj=1:nfpE
            if sibhfs(ii,jj) == 0
                for kk=1:nvpf
                    isborder( elems(ii,hf(jj,kk))) = true;
                end
            end
        end
        ii = ii + 1;
    end
end

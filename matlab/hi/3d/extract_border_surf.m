function [b2v, bdelems, facemap] = extract_border_surf(nv, elems) 
%EXTRACT_BORDER_SURF Extract border vertices and faces.
% [B2V,BDTRIS] = EXTRACT_BORDER_SURF(NV,ELEMS)
%
% See also EXTRACT_BORDER_SURF_TET, EXTRACT_BORDER_SURF_HEX

%#codegen -args {int32(0), coder.typeof( int32(0), [inf,27], [1,1])}

assert(isa(nv, 'int32') && isa(elems, 'int32'));

switch  size(elems,2)
    case 1
        [b2v, bdelems, facemap] = extract_border_surf_mixed(nv, elems);
    case 4
        [b2v, bdelems, facemap] = extract_border_surf_tet(nv, elems);
    case 5
        [b2v, bdelems, facemap] = extract_border_surf_pyramid(nv, elems);
    case 6
        [b2v, bdelems, facemap] = extract_border_surf_prism(nv, elems);
    case 8
        [b2v, bdelems, facemap] = extract_border_surf_hex(nv, elems);
    otherwise
        error('Unsupported element type');
end

function opphfs = determine_opposite_halfface_mex( nv, elems) %#codegen
%DETERMINE_OPPOSITE_HALFFACE_MEX determines the opposite half-face of
% each half-face of an oriented, manifold volume mesh with or
% without boundary.
%
% OPPHFS = DETERMINE_OPPOSITE_HALFFACE_MEX(NV,ELEMS)
% Computes mapping from each half-face to its opposite half-face. 
% We assign three bits to local_face_id.

assert(isa(nv, 'int32'));
assert(isa(elems, 'int32') && size(elems,2)>=1);

switch size(elems,2)
    case 1 % mixed
        opphfs = determine_opposite_halfface_mixed(nv, elems);
    case {4,10} % tet
        opphfs = determine_opposite_halfface_tet(nv, elems);
    case {5,14} % pyramid
        opphfs = determine_opposite_halfface_pyramid(nv, elems);
    case {6,15,18} % prism
        opphfs = determine_opposite_halfface_prism(nv, elems);
    case {8,20,27} % hex
        opphfs = determine_opposite_halfface_hex(nv, elems);
    otherwise
        opphfs=int32(0); %#ok<NASGU>
        error('Unsupported element type.');
end

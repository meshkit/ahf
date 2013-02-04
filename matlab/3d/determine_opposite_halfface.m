function opphfs = determine_opposite_halfface( nv, elems, opphfs) %#codegen
%DETERMINE_OPPOSITE_HALFFACE determines the opposite half-face of
% each half-face of an oriented, manifold volume mesh with or
% without boundary.
%
% OPPHFS = DETERMINE_OPPOSITE_HALFFACE(NV,ELEMS)
% OPPHFS = DETERMINE_OPPOSITE_HALFFACE(NV,ELEMS,OPPHFS)
% Computes mapping from each half-face to its opposite half-face.
%
% See also DETERMINE_NEXTPAGE_VOL, DETERMINE_INCIDENT_HALFFACES

if nargin<3; opphfs = nullcopy(zeros(size(elems),'int32')); end

switch size(elems,2)
    case 1
        opphfs = determine_opposite_halfface_mixed(nv, elems, opphfs);
    case {4,10} % tet
        opphfs = determine_opposite_halfface_tet(nv, elems, opphfs);
    case {5,14} % pyramid
        opphfs = determine_opposite_halfface_pyramid(nv, elems, opphfs);
    case {6,15,18} % prism
        opphfs = determine_opposite_halfface_prism(nv, elems, opphfs);
    case {8,20,27} % hex
        opphfs = determine_opposite_halfface_hex(nv, elems, opphfs);
    otherwise
        opphfs = zeros(0, 1, 'int32'); %#ok<NASGU>
        error('Unsupported element type.');
end

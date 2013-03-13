function sibhfs = determine_sibling_halfface( nv, elems, sibhfs)
% DETERMINE_SIBLING_HALFFACE determines the sibling half-face of
%     each half-face of an oriented, manifold volume mesh with or
%     without boundary.
%
%   SIBHFS = DETERMINE_SIBLING_HALFFACE(NV,ELEMS)
%   SIBHFS = DETERMINE_SIBLING_HALFFACE(NV,ELEMS,SIBHFS)
% Computes mapping from each half-face to its sibling half-face.
%
% See also DETERMINE_INCIDENT_HALFFACES

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1])} determine_sibling_halfface_v1
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1])}

if nargin<3
    switch size(elems,2)
        case 1
            sibhfs = determine_sibling_halfface_mixed(nv, elems);
        case {4,10} % tet
            sibhfs = determine_sibling_halfface_tet(nv, elems);
        case {5,14} % pyramid
            sibhfs = determine_sibling_halfface_pyramid(nv, elems);
        case {6,15,18} % prism
            sibhfs = determine_sibling_halfface_prism(nv, elems);
        case {8,20,27} % hex
            sibhfs = determine_sibling_halfface_hex(nv, elems);
        otherwise
            sibhfs = zeros(0, 1, 'int32'); %#ok<NASGU>
            error('Unsupported element type.');
    end
else
    switch size(elems,2)
        case 1
            sibhfs = determine_sibling_halfface_mixed(nv, elems, sibhfs);
        case {4,10} % tet
            sibhfs = determine_sibling_halfface_tet(nv, elems, sibhfs);
        case {5,14} % pyramid
            sibhfs = determine_sibling_halfface_pyramid(nv, elems, sibhfs);
        case {6,15,18} % prism
            sibhfs = determine_sibling_halfface_prism(nv, elems, sibhfs);
        case {8,20,27} % hex
            sibhfs = determine_sibling_halfface_hex(nv, elems, sibhfs);
        otherwise
            sibhfs = zeros(0, 1, 'int32'); %#ok<NASGU>
            error('Unsupported element type.');
    end
end

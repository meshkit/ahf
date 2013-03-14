function [sibhfs,manifold,oriented] = determine_sibling_halffaces( nv, elems, varargin)
% DETERMINE_SIBLING_HALFFACES determines the sibling half-face of each 
% half-face of an oriented, manifold volume mesh with or without boundary.
%
%   SIBHFS = DETERMINE_SIBLING_HALFFACES(NV,ELEMS)
%   SIBHFS = DETERMINE_SIBLING_HALFFACES(NV,ELEMS,SIBHFS)
% Computes mapping from each half-face to its sibling half-face.
%
% See also DETERMINE_INCIDENT_HALFFACES

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,inf]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1])} determine_sibling_halffaces_v1
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1])}

manifold = true; oriented = true;

switch size(elems,2)
    case 1
        sibhfs = determine_sibling_halffaces_mixed(nv, elems, varargin{:});
    case {4,10} % tet
        [sibhfs,manifold,oriented] = determine_sibling_halffaces_tet(nv, elems, varargin{:});
    case {5,14} % pyramid
        sibhfs = determine_sibling_halffaces_pyramid(nv, elems, varargin{:});
    case {6,15,18} % prism
        sibhfs = determine_sibling_halffaces_prism(nv, elems, varargin{:});
    case {8,20,27} % hex
        sibhfs = determine_sibling_halffaces_hex(nv, elems, varargin{:});
    otherwise
        sibhfs = zeros(0, 1, 'int32'); %#ok<NASGU>
        error('Unsupported element type.');
end

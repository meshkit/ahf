function [sibhfs, v2hf] = construct_halffaces(nv, elems)
%CONSTRUCT_HALFFACES constructs an extended half-face data structure
%  for a non-oriented or non-manifold volume mesh.
%
% [sibhfs, v2hf] = construct_halffaces(nv, elems)
%
% See also construct_halfverts, construct_halfedges

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, inf])}

sibhfs = determine_sibling_halffaces(nv, elems);
v2hf = determine_incident_halffaces(nv, elems, sibhfs);

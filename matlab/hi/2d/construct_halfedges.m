function [sibhes, v2he, manifold, oriented] = construct_halfedges(nv, elems)
%CONSTRUCT_HALFEDGES constructs an extended half-edge data structure
%    for a non-oriented or non-manifold surface mesh.
%
% [sibhes, v2he, manifold, oriented] = construct_halfedges(nv, elems)
%
% At output, it returns sibhes and v2he, along with two logical variable 
% indicating whether the mesh is a manifold, and if so whether it is oriented.
%
% See also construct_halfverts, construct_halffaces

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, inf])}

[sibhes,manifold,oriented] = determine_sibling_halfedges(nv, elems);
v2he = determine_incident_halfedges(nv, elems, sibhes);

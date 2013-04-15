function [sibhes, manifold, oriented] = determine_sibling_halfedges_usestruct(nv, elems, usestruct)
[sibhes, manifold, oriented] = determine_sibling_halfedges(nv, elems, usestruct);
function [sibhfs,manifold,oriented] = determine_sibling_halffaces_tet_usestruct( nv, elems, usestruct)
[sibhfs,manifold,oriented] = determine_sibling_halffaces_tet( nv, elems, usestruct);
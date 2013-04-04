function [sibhfs, v2hf,manifold,oriented] = construct_halffaces(nv, elems)
%CONSTRUCT_HALFFACES constructs an extended half-face data structure
%  for a non-oriented or non-manifold volume mesh.
%
% [sibhfs,v2hf,manifold,oriented] = construct_halffaces(nv, elems)
% 
% At output, it returns sibhvs and v2he, along with two logical variable 
% indicating whether the mesh is a manifold, and if so whether it is oriented.
%
% See also construct_halfverts, construct_halfedges

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, inf])}
 
[sibhfs,manifold,oriented] = determine_sibling_halffaces(nv, elems);
if nargout>1
    v2hf = determine_incident_halffaces(elems, sibhfs);
end

function test  %#ok<DEFNU>
%!test
%! tets = int32([1,2,3,4; 1,2,4,5; 1,3,2,6]);
%!
%! nv = int32(6);
%! [sibhes,v2he,manifold,oriented] = construct_halffaces(nv, tets);
%! assert( manifold && oriented);

%! tets(1,[2,3])=tets(1,[3,2]);
%! [sibhes,v2he,manifold,oriented] = construct_halffaces(nv, tets);
%! assert( manifold && ~oriented);

%! tets(1,[2,3])=tets(1,[3,2]);
%! tets(4,:)=int32([1,2,3,5]);
%! [sibhes,v2he,manifold,oriented] = construct_halffaces(nv, tets);
%! assert( ~manifold && ~oriented);

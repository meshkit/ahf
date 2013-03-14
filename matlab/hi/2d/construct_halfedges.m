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
if nargout>1
    v2he = determine_incident_halfedges(nv, elems, sibhes);
end

function test  %#ok<DEFNU>
%!test
%! xs = [1,1,0;
%!     2,1,0;
%!     3,1,0;
%!     1,2,0;
%!     2,2,0;
%!     3,2,0;
%!     1,3,0;
%!     2,3,0;
%!     3,3,0;
%!     4,2,0];
%!
%! tris = int32([5,4,1;
%!     1,2,5;
%!     5,2,3;
%!     3,6,5;
%!     8,7,4;
%!     4,5,8;
%!     8,5,6;
%!     6,9,8;
%!     10,6,3]);
%!
%! nv = int32(size(xs,1)); nf=int32(size(tris,1));
%! [sibhes,v2he,manifold,oriented] = construct_halfedges(nv, tris);
%! assert( verify_incident_halfedges(tris, sibhes, v2he, nf));
%! assert( manifold && oriented);

%! tris(1,[2,3])=tris(1,[3,2]);
%! [sibhes,v2he,manifold,oriented] = construct_halfedges(nv, tris);
%! assert( verify_incident_halfedges(tris, sibhes, v2he, nf));
%! assert( manifold && ~oriented);

%! tris(1,[2,3])=tris(1,[3,2]);
%! tris(10,:)=int32([3,6,9]);
%! [sibhes,v2he,manifold,oriented] = construct_halfedges(nv, tris);
%! assert( verify_incident_halfedges(tris, sibhes, v2he, nf));
%! assert( ~manifold && ~oriented);


function [sibhvs, v2hv,manifold,oriented] = construct_halfverts(nv, edgs)
%CONSTRUCT_HALFVERTS constructs an extended half-vertex data
%       structure for a non-oriented or non-manifold curve.
%
% [sibhvs, v2hv, manifold,oriented] = construct_halfverts(nv, edgs)
% 
% At output, it returns sibhvs and v2he, along with two logical variable 
% indicating whether the mesh is a manifold, and if so whether it is oriented.
%
% See also construct_halfedges, construct_halffaces

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2])}

[sibhvs,manifold,oriented] = determine_sibling_halfverts(nv, edgs);
if nargout>1
    v2hv = determine_incident_halfverts(nv, edgs);
   % v2hv = determine_incident_halfverts(edgs, sibhvs);
end

function test %#ok<DEFNU>
%!test
%! edges = [1 2; 2 3; 3 4; 4 5];
%! [sibhvs,~,manifold,oriented] = construct_halfverts(5, edges);
%! assert( manifold && oriented);

%! edges = [1 2; 2 3; 3 4; 5 4];
%! [sibhvs,~,manifold,oriented] = construct_halfverts(5, edges);
%! assert( manifold && ~oriented);

%! edges = [1 2; 2 3; 3 4; 4 5; 3 5];
%! [sibhvs,~,manifold,oriented] = construct_halfverts(5, edges);
%! assert( ~manifold && ~oriented);

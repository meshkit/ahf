function [sibhvs, v2hv] = construct_halfverts(nv, edgs)
%CONSTRUCT_HALFVERTS constructs half-vertex data structure.
%
% [sibhvs, v2hv] = construct_halfverts(nv, edgs)
%
% See also construct_halfedges, construct_halffaces

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2])}

sibhvs = determine_sibling_halfvert(nv, edgs);
v2hv = determine_incident_halfverts(nv, edgs);

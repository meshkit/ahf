function isbnd = determine_border_vertices(nv, elems, dim)
% Determines border vertices of a mesh in 1-D, 2-D, or 3-D.
%
% ISBND = DETERMINE_BORDER_VERTICES(NV,ELEMS,DIM)
%
% Determines border vertices of a mesh.  It supports linear and quadratic
%    elements. It returns bitmap of border vertices. For quadratic elements,
%    vertices on edge and face centers are set to false.
%
% See also determine_border_vertices_curv, determine_border_vertices_surf,
% determine_border_vertices_vol

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1]), int32(1)}

switch dim
    case 1
        isbnd = determine_border_vertices_curv(nv, elems);
    case 2
        isbnd = determine_border_vertices_surf(nv, elems);
    case 3
        isbnd = determine_border_vertices_vol(nv, elems);
    otherwise
        error('Unsupported dimensions.');
end

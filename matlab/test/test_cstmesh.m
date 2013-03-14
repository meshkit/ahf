function mesh = test_cstmesh( meshfile )
%TEST_CSTMESH This function reads in CST mesh and construct a mesh 
%   data structure from it.

[xs,cells,~,~]=readvtk_cst(meshfile);

nv = int32(size(xs,1));
mesh.xs = xs;

% Insert edges into mesh
mesh.edges = int32(cells.edges);
[mesh.sibhvs,mesh.v2hv] = construct_halfverts( nv, mesh.edges);

% Insert faces into mesh
mesh.faces = int32(cells.tris);
[mesh.sibhes,mesh.v2he] = construct_halfedges( nv, mesh.faces);

% Insert cells into mesh
mesh.cells = int32(cells.tets);
[mesh.sibhfs,mesh.v2hf] = construct_halffaces( nv, mesh.cells);

end


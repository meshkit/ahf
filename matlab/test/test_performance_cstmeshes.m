function test_performance_cstmeshes(meshfile)

[xs,cells,~,~]=readvtk_cst(meshfile);

nv = int32(size(xs,1));
mesh.xs = xs;
t1 = wtime;
% Insert edges into mesh
mesh.edges = int32(cells.edges);
[mesh.sibhvs,mesh.v2hv] = construct_halfverts( nv, mesh.edges);

% Insert faces into mesh
mesh.faces = int32(cells.tris);
[mesh.sibhes,mesh.v2he] = construct_halfedges( nv, mesh.faces);

% Insert cells into mesh
mesh.tets = int32(cells.tets);
[mesh.sibhfs,mesh.v2hf] = construct_halffaces( nv, mesh.tets);
time_mds = wtime - t1;
fprintf('Construct of MDS: Time = %g secs\n',time_mds);
fprintf('No. of vertices = %d\n', nv);
fprintf('No. of edges = %d\n',size(mesh.edges,1));
fprintf('No. of faces = %d\n', size(mesh.faces,1));
fprintf('No. of tets = %d\n', size(mesh.tets,1));
%test_queries(mesh)
%fprintf('Result from eid2faces_top\n');
test_eid2faces_top(mesh)
end


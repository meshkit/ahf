function test_uniform_refinement
[xs,tets] = readvtk_unstr('four_tets.vtk');
edges = int32([6 1; 6 5]);
tris = int32([6 5 1; 1 4 6]);

[tets_hi, tris_hi, edges_hi, xs_hi] = uniform_refinement_mixed(xs,edges,tris,tets);
fprintf('here');
end


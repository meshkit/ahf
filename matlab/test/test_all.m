function test_all
fprintf('Timing for Mesh 1 RJ45\n');
test_performance_cstmeshes('CST-meshes/example-1-RJ45.vtk')

fprintf(' Timing for Mesh 2 T-splitter-port1\n');
test_performance_cstmeshes('CST-meshes/example-2-t-splitter-port1.vtk')

fprintf('Timing for Mesh 3 Wire-with-cylinder\n');
test_performance_cstmeshes('CST-meshes/example-3-wire-with-cylinder.vtk')

fprintf('Timing for Mesh 4 Planes-wires-inside-cylinder\n');
test_performance_cstmeshes('CST-meshes/example-4-planes-wires-inside-cylinder.vtk')

fprintf('Timing for Mesh 5 Two-cubes-wire\n');
test_performance_cstmeshes('CST-meshes/example-5-two-cubes-wire.vtk')


end


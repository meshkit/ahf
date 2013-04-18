function passed = test_obtain_neighbor_tets

tets = [ 1,2,3,4;   % 1
         2,3,4,6;   % 2   
         1,2,3,7;   % 3
         1,2,4,5;   % 4
         1,3,4,8;   % 5
        ];
    
[mesh.sibhfs,manifold,oriented]=determine_sibling_halffaces(8,tets);
mesh.cells=tets;

%% Test 1. Tetrahedrah in the middle, has four neighbors
ngbtets = obtain_neighbor_tets(1,mesh); 

passed=size(ngbtets,1)==4;
passed=passed && sum(sort(ngbtets,1)-[2,3,4,5]',1)==0;

%% Test 2. Tetrahedrah on the boundary, has one neighbor
ngbtets = obtain_neighbor_tets(2,mesh); 

passed=size(ngbtets,1)==1;
passed=passed && ngbtets==1;

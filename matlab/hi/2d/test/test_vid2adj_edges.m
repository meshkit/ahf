function passed = test_vid2adj_edges
% test geometry
% contains non-manifold vertex
% test boundary vertex, non-manifold interior vertex and manifold interior
% vertex

nv=10;
edges=int32([
       3,5;    % 1
       1,2;    % 2
       2,3;    % 3
       1,10;   % 4
       10,6;   % 5
       1,6;    % 6
       2,6;    % 7
       9,10;   % 8
       ]);
   
 [sibhvs,v2hv] = construct_halfverts( nv, edges);  
   
 %% Test 1. Boundary vertex
 vid=int32(9);
 [edge_list, nedges]=vid2adj_edges(vid,v2hv,sibhvs);
 % we only expect edge 8
 passed=edge_list(1:nedges,1)==8;
 
 %% Test 2. Interior manifold vertex
 vid=int32(3);
 [edge_list, nedges]=vid2adj_edges(vid,v2hv,sibhvs);
 % we expect edges 1 and 3
 passed=passed && sum(sort(edge_list(1:nedges,1),1)-int32([1;3]),1)==0;
 
 %% Test 3. Interior non-manifold vertex
 vid=int32(10);
 [edge_list, nedges]=vid2adj_edges(vid,v2hv,sibhvs);
 % we expect edges 4, 5 and 8
 passed=passed && sum(sort(edge_list(1:nedges,1),1)-int32([4;5;8]),1)==0;
 
 
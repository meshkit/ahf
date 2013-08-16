function [xs,edges,tris,tets] = uniform_refinement_mixed(xs,edges,tris,tets)
% Construct the high-order nodes
[tets_hi, tris_hi, edges_hi, xs_hi] = construct_hiorder_fe3_mixed(xs,edges,tris,tets);
xs=xs_hi;
% Divide the high-order elements to obtain the refined elements
edges = decompose_hiorder_fe1(edges_hi);
tris = decompose_hiorder_fe2(tris_hi);
tets = decompose_hiorder_fe3(tets_hi);

end


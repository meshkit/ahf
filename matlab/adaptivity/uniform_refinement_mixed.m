function [xs,edges,tris,tets] = uniform_refinement_mixed(xs,edges,tris,tets)
% Construct the high-order nodes
[tets_hi, tris_hi, edges_hi, xs_hi] = construct_hiorder_fe3_mixed(xs,edges,tris,tets);

% Divide the high-order elements to obtain the refined elements

end


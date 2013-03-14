function [ps_new, tris_new] = reshape_mesh(ps,tris,contract_param,split_param,flip_param,deg)
%#codegen -args { coder.typeof(double(0), [Inf 3]), coder.typeof(int32(0), [Inf 3])} 

% Splits edges to improve element consistency
[ps, tris] = split_edge_surf_tri(ps, tris, split_param, deg);

% Contract relatively short edges
[ps, tris] = contract_edge_surf_tri(ps, tris, contract_param, deg);

% Flip edges to improve element quality
[ps, tris] = flip_edge_surf_tri(flip_param, ps, tris);

% % Obtain opphe and v2he matrices
% sibhes = determine_opposite_halfedge(size(ps,1), tris);
% v2he=determine_incident_halfedges(tris, sibhes);
% 
% % Use mesh regulation to redistribute the vertices
% ps = surf_diff_mesh_reg(ps, tris, sibhes, v2he);

ps_new = ps;
tris_new = tris;
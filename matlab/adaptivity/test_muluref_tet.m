function test_muluref_tet
%load mesh

nverts =size(xs,1); ntets =size(tets,1); nv_orig=nverts;
%% construct half face data
[sibhfs, v2hf] =construct_halffaces(nverts, tets);

%% uniform refinement with degree 2 or 3
degs_level =[2 3 3];
[xs, nverts, tets, ntets, nverts_level, ntets_level, parent_id, parent_coeff]=mul_level_uref_tetmesh_deg2o3(xs, nverts, tets, ntets, sibhfs, degs_level);

%% high order projection

% step 1: find surface boundary of original mesh
elabel =zeros
[b2v, bdtris, facmap] =extract_border_surf_tet(nv_orig, tets(1:ntets_level(1),:));%, elabel, sibhfs, inwards);

% step 2: construct high order fitting for each boundary vetex
[sibhes, v2he] =construct_halfedges(numel(b2v), bdtris);
degree =int32(2);
noise =false; nv=numel(b2v); ntris =size(bdtris,1);
vtags =zeros(nv,1);
ftags =zeros(ntris,1);
[coeffs, coors, degs_out]=walf3d_get_coeff_trimesh(xs(b2v(:),:), nv, nrms, tris, ntris, sibhes, v2he, degree, noise, vtags, ftags);

% step 3: border high order node will be projected
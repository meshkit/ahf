function test_muluref_tri
load sphere0.mat

nverts=size(xs,1); ntris =size(tris,1);
%% Construct half edge data
[sibhes,v2he] =construct_halfedges(nverts, tris);

%% Uniform Refinment with various degrees
% 3 level refinement, first level degree 2 refine, second degree 3, third
% level degree 2
degs_level=[2 3];
[xs, nverts, tris, ntris, nverts_level, ntris_level, parent_id, parent_coeff]=mul_level_uref_trimesh(xs, nverts, tris, ntris, sibhes, degs_level);

%% high order projection, level by level
degree =int32(5);
noise =false;
nv_orig =nverts_level(1); ntris_orig=ntris_level(1);
vtags =logical(zeros(nv_orig,1));
ftags =logical(zeros(ntris_orig,1));
nrms =compute_average_normal(xs(1:nv_orig,:), tris(1:ntris_orig,:));

xs=hiproj_walf_uref(xs, nverts_level, parent_id, nrms, tris, ntris_level, degs_level, sibhes, v2he, degree, noise, vtags, ftags);

function nrms = compute_average_normal( xs, tris)
% Compute area-averaged vertex normals
ntris = size(tris, 1);
nv = size(xs, 1);

nrms = zeros( nv, 3);
for ii = 1 : ntris
    nrm = cross_col( xs(tris(ii,3), 1:3)-xs(tris(ii,2), 1:3), ...
        xs(tris(ii,1), 1:3)-xs(tris(ii,3), 1:3));

    for jj = 1:3
        nrms(tris(ii,jj), :) = nrms(tris(ii,jj), :) + nrm';
    end
end

for ii = 1 : nv
    nrms(ii,:) = nrms(ii,:)/sqrt(nrms(ii,:)*nrms(ii,:)');
end

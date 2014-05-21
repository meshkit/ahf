function [xs, nverts, tets, ntets, nverts_level, ntets_level, parent_id, parent_coeff]=mul_level_uref_tetmesh_deg2o3(xs, nverts, tets, ntets, sibhfs, degs_level)
if nargin==0
    xs=[1 0 0;...
    0 1 0;...
    0 0 0;...
    0 0 1;...
    0 0 -1];
    nverts =size(xs,1); nv_orig=5;
    tets=[1 2 3 4;2 1 3 5];
    ntets=size(tets,1);
    degs_level=[2 3 2];
    [sibhfs, ~] =construct_halffaces(nverts,tets);
    figure
    tetramesh(tets,xs);
    %parent_id =zeros(0,1);parent_coeff=zeros(0,1);
end

mxlevel =numel(degs_level);
nverts_level =zeros(mxlevel+1,1); nverts_level(1) =nverts;
ntets_level =zeros(mxlevel+1,1); ntets_level(1) =ntets;
pre_ntets =0; nv_orig =nverts;
parent_id =zeros(0,1); parent_coeff =zeros(0,1);
for level=1:mxlevel-1
    deg =degs_level(level);
    tic
    if deg==2
        [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg2(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff);
    elseif deg==3
        [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg3(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff);
    end
    toc
    figure 
    tetramesh(tets(ntets_level(level)+1:ntets,:),xs);
    title(['level ', num2str(level), ' refinement, deg= ', num2str(deg)]);
    nverts_level(level+1) =nverts; ntets_level(level+1) =ntets; pre_ntets =ntets_level(level);
    tic
    [sibhfs,~] =construct_halffaces(nverts,tets(pre_ntets+1:ntets,:));
    toc
end
level =mxlevel;
deg =degs_level(level);
tic
if deg==2
    [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg2(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff);
elseif deg==3
    [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg3(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff);
end
toc
tic
[sibhfs,v2hf,oriented] =construct_halffaces(nverts,tets(ntets_level(level):ntets,:));
toc
if oriented
    disp GREAT:Oriented
else
    disp BAD
end

figure
tetramesh(tets(ntets_level(level)+1:ntets,:),xs);
title(['level ', num2str(level), ' refinement, deg= ', num2str(deg)]);
nverts_level(level+1) =nverts; ntets_level(level+1) =ntets;

tol =1e-10;
for i=1:size(parent_id,1)
    tet_conn =tets(parent_id(i),:);
    xs_linear =parent_coeff(i,:)*xs(tet_conn,:);
    assert(norm(xs(i+nv_orig,:)-xs_linear)<tol);
end
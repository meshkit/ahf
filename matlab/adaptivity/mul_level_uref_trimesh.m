function [xs, nverts, tris, ntris, nverts_level, ntris_level, parent_id, parent_coeff]=mul_level_uref_trimesh(xs, nverts, tris, ntris, sibhes, degs_level)
if nargin==0
    xs=[0 0 0;1 0 0;0.5 1 0;0.5 -1 0];
    tris=[1 2 3;1 4 2];
    nverts=size(xs,1);ntris=size(tris,1);
    [sibhes,~] =construct_halfedges(nverts, tris);
    degs_level=[2 3 5];
end
figure; trimesh(tris, xs(:,1),xs(:,2),xs(:,3));title('level 0 mesh');
MXLEVEL=numel(degs_level);
nverts_level=zeros(MXLEVEL+1,1); ntris_level=zeros(MXLEVEL+1,1);
nverts_level(1) =nverts; ntris_level(1) =ntris;
pre_ntris =0;nv_orig =nverts;
parent_id =zeros(0,1);parent_coeff =zeros(0,1);
for level=1:MXLEVEL-1
    deg =degs_level(level);
    tic
    [xs, nverts, tris, ntris, parent_id, parent_coeff]=uref_tri_mesh(xs, nverts, nv_orig, tris, pre_ntris, ntris, deg, sibhes, parent_id, parent_coeff);
    toc
    figure; trimesh(tris(ntris_level(level)+1:ntris,:), xs(:,1), xs(:,2), xs(:,3)); 
    title(['level ', num2str(level), ' refinement, deg= ', num2str(deg)]);
    nverts_level(level+1) =nverts; ntris_level(level+1) =ntris; pre_ntris =ntris_level(level);
    tic
    [sibhes,~] =construct_halfedges(nverts, tris(ntris_level(level)+1:ntris,:));
    toc
end
deg =degs_level(MXLEVEL);
[xs, nverts, tris, ntris, parent_id, parent_coeff]=uref_tri_mesh(xs, nverts, nv_orig, tris, pre_ntris, ntris, deg, sibhes, parent_id, parent_coeff);
figure; trimesh(tris(ntris_level(MXLEVEL)+1:ntris,:), xs(:,1), xs(:,2), xs(:,3));
title(['level ', num2str(MXLEVEL), ' refinement, deg= ', num2str(deg)]);
ntris_level(MXLEVEL+1) =ntris; nverts_level(MXLEVEL+1) =nverts;
%test case
tol=1e-10;ERR=0;
for i=1:size(parent_id)
    tri =tris(parent_id(i),:);
    xs_linear =parent_coeff(i,:)*xs(tri,:);
    for j=1:MXLEVEL
        if i+nv_orig>nverts_level(j)
            level =j;
        end
    end
    root_tri=tris(get_root_tri(parent_id(i), level, degs_level, ntris_level),:);
    err=det([xs(root_tri(2),:)-xs(root_tri(1),:); xs(root_tri(3),:)-xs(root_tri(1),:); xs(i+nv_orig,:)-xs(root_tri(1),:)]);
    if err>tol
        error('get wrong root');
    end
    if err>ERR
        ERR=err;
    end
    if norm(xs_linear-xs(nv_orig+i,:))>tol
        fprintf('ERROR\n');
        fprintf('%f %f %f\n', xs_linear);
        fprintf('%f %f %f\n', xs(nv_orig+i,:));
    end
end
format long
ERR


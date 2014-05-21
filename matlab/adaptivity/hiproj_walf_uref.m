function xs=hiproj_walf_uref(xs, nverts_level, parent_id, nrms, tris, ntris_level, degs_level, sibhes, v2he, degree, noise, vtags, ftags)
assert(size(xs,1)==nverts_level(end)&&size(xs,2)==3);
assert(numel(parent_id)==nverts_level(end)-nverts_level(1));
assert(size(nrms,1)==nverts_level(1)&&size(nrms,2)==3);
assert(size(tris,1)==ntris_level(end)&&size(tris,2)==3);
assert(numel(nverts_level)==numel(ntris_level));
% step 1: compute coefficients of fitting polynomials for each vertex
nv_orig =nverts_level(1); ntris_orig =ntris_level(1);
[coeffs, coors, degs_out]=walf3d_get_coeff_trimesh(xs(1:nv_orig,:), nv_orig, nrms, tris(1:ntris_orig,:), ntris_orig, sibhes, v2he, degree, noise, vtags, ftags);

%step 2: high order projection for newly added hi-nodes, level by level
MXERR_proj=0;
for level=1:numel(degs_level)
    for j=nverts_level(level)+1:nverts_level(level+1)
        xs_linear =xs(j, :);
        tri_id =get_root_tri(parent_id(j-nv_orig), level, degs_level, ntris_level);
        A=[xs(tris(tri_id,1),:)' xs(tris(tri_id,2),:)' xs(tris(tri_id,3),:)'];
        local_coor =A\xs_linear';
        xs_hi =walf_eval(xs(tris(tri_id,:),:), coeffs(tris(tri_id,:),:), coors(tris(tri_id,:),:), int32(degs_out(tris(tri_id,:))), local_coor(2), local_coor(3), false);
        xs(j,:) =xs_hi;
        err =abs(norm(xs_hi)-1);
        if err>MXERR_proj
            MXERR_proj=err;
        end
    end
    figure
    tri_ids=ntris_level(level)+1:ntris_level(level+1);
    trimesh(tris(tri_ids,:), xs(1:j,1),...
        xs(1:j,2),xs(1:j,3));
    title(['level ', num2str(level), ' refinement with hiprojection degree ', num2str(degree)]);
end
fprintf('high order projection error %f\n', MXERR_proj);
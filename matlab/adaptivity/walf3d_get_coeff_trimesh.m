function [coeffs, coors, degs_out]=walf3d_get_coeff_trimesh(xs, nv, nrms, tris, ntris, sibhes, v2he, degree, noise, vtags, ftags)
if noise
    ring =(degree+2)/2;
else
    ring =(degree+1)/2;
end
MAXNPNTS =128; minpnts =5;
ngbvs =zeros(MAXNPNTS,1);

coeffs =zeros(nv, (degree+2)*(degree+1)/2);
degs_out =zeros(nv,1);
coors =zeros(nv, 9);
for i=1:nv
    [ngbvs, num_nbs, vtags, ftags] = obtain_nring_surf(i, ring, minpnts, ...
                tris(1:ntris,:), sibhes, v2he, ngbvs, vtags, ftags);
    ngbpnts =zeros(num_nbs+1,3);
    ngbpnts(1,:) =xs(i,:);
    ngbpnts(2:num_nbs+1,:) =xs(ngbvs(1:num_nbs),:);
    nrms_local =zeros(num_nbs+1,3);
    nrms_local(1,:) =nrms(i,:);
    nrms_local(2:num_nbs+1,:) =nrms(ngbvs(1:num_nbs),:);
    [coeffs(i,:),coors(i,:),degs_out(i)] = polyfit3d_get_coeff(ngbpnts, nrms_local, degree, false);
end
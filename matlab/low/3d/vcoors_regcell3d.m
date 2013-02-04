function vc = vcoors_regcell3d(coors,i,j,k) %#codegen
% Extract coordinates of a given element in 3-D.
% VC = VC_OF_REGCELL_3D(COORS,I,J,K)
%
% COORS is assumed to be ni-by-nj-by-nk-by-3.

vc = [coors(i,j,k,1), coors(i,j,k,2), coors(i,j,k,3);
    coors(i+1,j,k,1), coors(i+1,j,k,2), coors(i+1,j,k,3);
    coors(i+1,j+1,k,1), coors(i+1,j+1,k,2),  coors(i+1,j+1,k,3);
    coors(i,j+1,k,1), coors(i,j+1,k,2), coors(i,j+1,k,3);
    coors(i,j,k+1,1), coors(i,j,k+1,2), coors(i,j,k+1,3);
    coors(i+1,j,k+1,1), coors(i+1,j,k+1,2), coors(i+1,j,k+1,3);
    coors(i+1,j+1,k+1,1), coors(i+1,j+1,k+1,2), coors(i+1,j+1,k+1,3);
    coors(i,j+1,k+1,1), coors(i,j+1,k+1,2), coors(i,j+1,k+1,3)];

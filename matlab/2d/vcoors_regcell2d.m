function vc = vcoors_regcell2d(coors,i,j) %#codegen
% Extract coordinates of a given element in 2-D.
% VC = VC_OF_REGCELL2D(COORS,I,J)
%
% COORS is assumed to be ni-by-nj-by-2 or ni-by-nj-by-3.

if size(coors,3)>=3
    vc = [coors(i,j,1), coors(i,j,2), coors(i,j,3);
        coors(i+1,j,1), coors(i+1,j,2), coors(i+1,j,3);
        coors(i+1,j+1,1), coors(i+1,j+1,2), coors(i+1,j+1,3);
        coors(i,j+1,1), coors(i,j+1,2), coors(i,j+1,3)];
else
    vc = [coors(i,j,1), coors(i,j,2);
        coors(i+1,j,1), coors(i+1,j,2);
        coors(i+1,j+1,1), coors(i+1,j+1,2);
        coors(i,j+1,1), coors(i,j+1,2)];
end

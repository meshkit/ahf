function [xs elem]=append_meshes(xs1,elem1,xs2,elem2) %#codegen 
% VERIFY THAT THE ELEMENTS ARE OF THE SAME TYPE OR HYBRIDIZE THE RESULT
coder.extrinsic('fprintf');

if(size(elem1,2)~=int32(size(elem2,2)))
    fprintf(1,'Meshes not of the same type \n');
    %VERIFY THAT BOTH ARE TOPOLOGICALLY 2D OR TOPOLOGICALLY 3D
    %if(~same_dim)
      %error(cannot add meshes that are of differnt dimensionality');
    %end
end
nv1=int32(size(xs1,1));
xs=cat(1,xs1,xs2);
elem2=elem2+nv1;
elem=cat(1,elem1,elem2);
% DEAL WITH NODE AND CELL FIELDS LATER

end

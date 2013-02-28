function writestl(filename,xs,elems)

%     PURPOSE -
%
%        THIS ROUTINE WRITES AN STL FILE
%
%     INPUT ARGUMENTS -
%
%        xs - coordinates
%        tris - tri or quad connectivity
%
%     OUTPUT ARGUMENTS -
%
%        None

type = size(elems,2); nelems = size(elems,1);
if(type < 3 || type > 4)
    error('Only triangles and quads can be written into STL format')
end
fid=fopen(filename,'Wt');
fprintf(fid,'solid \n');
%
%Get face normals
nrms = compute_face_normal_surf( xs, elems );
%
for i=1:nelems
    fprintf(fid,'  facet normal %20.12f %20.12f %20.12f\n',nrms(i,1),...
        nrms(i,2),nrms(i,3));
    fprintf(fid,'    outer loop\n');
    if(type==3)
      for j=1:3
        fprintf(fid,'      vertex %20.12f %20.12f %20.12f\n',... 
          xs(elems(i,j),1),xs(elems(i,j),2),xs(elems(i,j),3));
      end
    else
      for j=1:4
         fprintf(fid,'      vertex %20.12f %20.12f %20.12f %20.12f\n',...
            xs(elems(i,j),1),xs(elems(i,j),2),xs(elems(i,j),3),...
            xs(elems(i,j),4));
      end
    end
    fprintf(fid,'    endloop\n');
    fprintf(fid,'  endfacet\n');
end
fprintf(fid,'endsolid\n');
fclose(fid);
return;
end



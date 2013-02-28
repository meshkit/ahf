function write_lsdyna_pfem(filename, nodes, tris)
%WRITE_LSDYNA   Write out tetrahedral pfem mesh in LSDYNA format.
fid = fopen(filename,'wt');

nv = size(nodes,1); ntris = size(tris,1);

% Write out nodes
fprintf(fid,'*NODE_PFEM\n');
for i=1:nv
   fprintf(fid,'%d, %0E, %0E, %0E\n',i,nodes(i,1:3));
end
mincompsize=20;
hardedge_degree_tol=45;
%THESE ARE SEED TRINAGLES FROM THE BOX
growseeds=[489 548 499 498 564 579 122 204 163 439 335 418];
filter=false;
adjacent=true;tic
[flabel,facecount]=get_faclabel(nodes,tris,filter,adjacent,growseeds,...
    mincompsize,hardedge_degree_tol,128);toc;
flabel=flabel+1;
% Write out triangles
fprintf(fid,'*ELEMENT_PFEM\n');
for i=1:ntris
    fprintf(fid,'%d, %d, %d, %d, %d, %d\n',i,flabel(i),tris(i,1:3),tris(i,3));
end
  
fprintf(fid,'*END\n');
fclose(fid);

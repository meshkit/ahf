function writemesh_tri(fname_mesh,xs,tris,flabel,fsize)
%writes the Yams mesh format
if(nargin<4)
  flabel=[];
end
if(nargin<5)
  fsize=[];
end
fid = fopen(fname_mesh, 'w');
fprintf(fid, ' MeshVersionFormatted 1\n');
fprintf(fid, ' Dimension\n');
fprintf(fid, ' 3\n');
fprintf(fid, ' Vertices\n');
nv=size(xs,1);
fprintf(fid, ' %d\n',nv);
% Nodes:
fprintf(fid,'%g %g %g 0\n',xs');
fprintf(fid, ' Triangles\n');
ntris=size(tris,1);
fprintf(fid, ' %d\n',ntris);
fprintf(fid,'%d %d %d 0\n',tris');
if(~isempty(flabel))
  maxlabel=max(flabel);
  if(maxlabel)
    RequiredTriangles=flabel(flabel>0);
    fprintf(fid, ' RequiredTriangles\n');
    nReqtris=size(RequiredTriangles,1);
    fprintf(fid, ' %d\n',nReqtris);
    fprintf(fid,'%d0\n',RequiredTriangles);
  end
end
fprintf(fid, ' End\n');
fclose(fid);

if(~isempty(fsize))
  fid = fopen([fname_mesh(1:end-5) '.sol'], 'w');
  fprintf(fid, ' MeshVersionFormatted 1\n');
  fprintf(fid, ' Dimension\n');
  fprintf(fid, ' 3\n');
  fprintf(fid, ' SolAtVertices\n');
  fprintf(fid,'%d\n',nv);
  fprintf(fid,'1 1\n');
  for i=1:nv
    fprintf(fid,'%g\n',fsize(i));
  end
  fprintf(fid, ' End\n');
  fclose(fid);
end


%END FUNCTION
end

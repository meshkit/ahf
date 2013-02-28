function writeply(fname,xs,tris)
%WRITEPLY    Write a surface as a Stanford PLY.
% See http://en.wikipedia.org/wiki/PLY_%28file_format%29
fid = fopen(fname, 'Wt');
fprintf(fid, 'ply\n');
fprintf(fid, 'format ascii 1.0\n');
npoints=size(xs,1);
ntris=size(tris,1);
fprintf(fid,'element vertex %d\n',npoints);
fprintf(fid,'property float x\n');
fprintf(fid,'property float y\n');
fprintf(fid,'property float z\n');
fprintf(fid,'element face %d\n',ntris);
fprintf(fid,'property list uint8 int vertex_indices\n');
fprintf(fid,'end_header\n');
fprintf(fid, '%.16e %.16e %.16e\n', xs');
fprintf(fid, '3 %d %d %d\n', tris'-1);
fclose(fid);


%END FUNCTION
end

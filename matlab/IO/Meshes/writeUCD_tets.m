function writeUCD_tets(filename, nodes, cells, flabel)
%WRITEUCD   Write out triangle mesh in AVS/UCD format.
% If flabel is present, write it out also.
fid = fopen(filename,'w');

nv = size(nodes,1); ntri = size(cells,1);
if nargin>3
    fprintf(fid,'%d %d 0 1 0\n', nv, ntri);
else
    fprintf(fid,'%d %d 0 0 0\n', nv, ntri);
end

% Write out nodes
tnodes = zeros(nv,4);
tnodes(:,1) = (1:nv)';
tnodes(:,2:end) = nodes;
fprintf(fid,'%05d %0E %0E %0E\n',tnodes');

% Write out cellls
tcells = zeros(ntri,size(cells,2)+2,'int32');
tcells(:,1) = (1:ntri)';
tcells(:,3:end) = cells;


fprintf(fid,'%05d %d tet %d %d %d %d\n',tcells');

if nargin>3
    % First, indicate number of cell data
    fprintf(fid,'00001  1\n');
    fprintf(fid,'faclabel, integer\n');

    faclabel = [[1:length(flabel)]',flabel];

    fprintf(fid,'%010d %d\n',faclabel');
end

fclose(fid);

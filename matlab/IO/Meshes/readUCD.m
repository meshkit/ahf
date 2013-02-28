function [nodes,cells,fsize,faclabel] = readUCD(filename, field)

fid = fopen(filename, 'r');

%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end

s = get_nextline(fid);
parameters = sscanf(s, '%d', [1,5]);
num_nodes = parameters(1);
num_cells = parameters(2); 
num_ndata = parameters(3);
num_cdata = parameters(4); 
% num_mdata = parameters(5);

nodes = zeros(num_nodes,3);

% Read in coordinates
s = get_nextline(fid);
tmp = sscanf(s, '%f');
n = length(tmp);
nodes(1,:) = tmp(2:4);

[nodest,count] = fscanf(fid, '%g', [n,num_nodes-1]);
if (count ~= (num_nodes-1)*n)
    fprintf(2,'Error in nodal coordinates.');
end

nodes(2:end,:) = nodest(2:4,:)';

% Read in cells
s = get_nextline(fid);
tmp = regexp(s, '[a-zA-Z]+', 'match');
[~, npe] = type2num(tmp{1});
n = length(regexp(s, '[0-9]+', 'match'));
if n~=npe+2
    fprintf(2,'Problem in the number of vertices per element.');
end

cells = zeros(num_cells, npe, 'int32');
tmp = sscanf(s, '%d %d %*s %d', [n,1]);
cells(1,:) = tmp(3:n);

[cellst,count] = fscanf(fid, '%d %d %*s %d %d %d', [n,num_cells-1]);
if count ~= (num_cells-1)*n
    fprintf(2,'Error in element connectivity.');
end
get_nextline(fid);

cells(2:end,:) = cellst(3:n,:)';
param_str_template = ' %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g';
% Section 4
if (num_ndata == 0)
    fsize = [];
else
    % Section 5
    if nargin<2; field = 'fsize'; end
    fsize_index = 0;
    for i = 1 : num_ndata
        tmp = get_nextline(fid);

        if strncmp( tmp, field, length(field));
            fsize_index = i;
        end
    end

    param_str = ['%d' param_str_template(1:3*num_ndata)];

    %param_str
    % Read in data
    [fsizet,count] = fscanf(fid, param_str, [num_ndata+1,num_nodes]);
    if (count ~= (num_ndata+1)*(num_nodes))
        fprintf(2, 'Error in nodal data.');
    end

    if fsize_index
        fsize = (fsizet(fsize_index+1,:))';
    else
        fprintf(2,['\nCould not find field ', field, '\n']);
        fsize = zeros( num_nodes,1);
    end
    get_nextline(fid);
end

if nargout>3
    % Face-centered data
    flabel_index = 0;
    for i = 1 : num_cdata
        tmp = get_nextline(fid);

        if strncmp( tmp, 'faclabel', 8)
            flabel_index = i;
        end
    end

    if flabel_index
        param_str = ['%d' param_str_template(1:3*num_cdata)];
        faclabelt = fscanf(fid, param_str,[num_cdata+1,num_cells]);

        faclabel = round(faclabelt(flabel_index+1,:)');
    else
        fprintf(2,'\nCould not find field faclabel\n');
        faclabel = zeros( num_cells, 1, 'int32');
    end
end

fclose(fid);

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
    s = fgetl(fid);
    while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
        s = fgetl(fid);
    end
%skip string of gaps   
    for i = 1 : length(s)
        if (s(i) ~= ' ')
            s = s(i:end);
            return
        end
    end
    s = get_nextline(fid);

function [type, num] = type2num(str_type)
%     Line line
%     Triangle tri
%     Quadrilateral quad
%     Hexahedron hex
%     Prism prism
%     Tetrahedron tet
%     Pyramid pyr
%     Point pt
    if (strcmp(str_type,'line'))
        type = 1;
        num = 2;
    elseif (strcmp(str_type,'tri'))
        type = 2;
        num = 3;
    elseif (strcmp(str_type,'quad'))
        type = 3;
        num = 4;
    elseif (strcmp(str_type,'hex'))
        type = 4;
        num = 8;
    elseif (strcmp(str_type,'prizm'))
        type = 5;
        num = 6;
    elseif (strcmp(str_type,'tet'))
        type = 6;
        num = 4;
    elseif (strcmp(str_type,'pyr'))
        type = 7;
        num = 5;
    elseif (strcmp(str_type,'pt'))
        type = 8;
        num = 1;
    else
        error(['unknown cell type ' str_type]);
    end

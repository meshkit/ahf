function [xs,tets] = readtet(filename)

fid = fopen(filename, 'r');

%check if file was opened
if (fid == -1)
    filename = ['cannot open the file ' filename];
    error(filename);
end

get_nextline(fid); get_nextline(fid);
s = get_nextline(fid);
% search for number of vertices
assert( strncmp( s, 'num_vertices', 12));
num_nodes = sscanf( s, '%*s %d');
s = get_nextline(fid);
assert( strncmp( s, 'num_tetras', 10));
num_tets = sscanf( s, '%*s %d');

get_nextline(fid); get_nextline(fid);
get_nextline(fid); s = get_nextline(fid);
assert( strncmp( s, 'VERTICES', 8));

[xs,count] = fscanf( fid, '%g %g %g %*g %*g %*g %*g %*g', [3, num_nodes]);
assert( count==3*num_nodes);
xs = xs';

get_nextline(fid); s = get_nextline(fid);
assert( strncmp( s, 'TETRAS', 6));
[tets,count] = fscanf( fid, '%d %d %d %d %*d', [4, num_tets]);
assert( count==4*num_tets);
tets = tets'+1;

fclose(fid);
end

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
end


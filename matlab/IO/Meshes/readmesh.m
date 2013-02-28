function [xs, tris] = readmesh(filename)

fid = fopen(filename, 'r');

%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end
s='';
while ~strcmp(s,'Vertices')
  s = get_nextline(fid);
end
s = get_nextline(fid);
nnodes=strread(s,'%d');
xs=zeros(nnodes,3);
for i=1:nnodes
    s = get_nextline(fid);
    [x y z] = strread(s,'%f %f %f %*d');
    xs(i,:)=[x y z];
end
while ~strcmp(s,'Triangles')
  s = get_nextline(fid);
end
s = get_nextline(fid);
ntris=strread(s,'%d');
tris=zeros(ntris,3,'int32');
for i=1:ntris
    s = get_nextline(fid);
    [n1 n2 n3] = strread(s,'%d %d %d %*d');
    tris(i,:)=[n1 n2 n3];
end

%END FUNCTION
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
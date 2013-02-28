function [xs, tets] = readasc(filename)
%READASC   Read in an ASC file for tetrahedral mesh.
% Input: file name
% Output: Coordinates of points (nx3) and list of tets (mx4)

% Skip header
fid = fopen(filename, 'r');
get_nextline(fid);

% Get number of points
s = get_nextline(fid);
nv = sscanf(s, '%d');

% Read in coordinates
ts = fscanf(fid, '%g', [nv,3+1]);
xs = ts(:,1:3);

% Get number of faces
s = get_nextline(fid);
ntets = sscanf(s, '%d');

% Read in tets
ts = fscanf(fid, '%d', [ntets,4+1]);
tets=ts(:,1:4);

fclose( fid);
end

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
    s = fgetl(fid);
    while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
        s = fgetl(fid);
    end
end

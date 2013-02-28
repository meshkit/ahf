function [xs, tets] = readm3d(filename)
%READM3D: Read in an M3D file for tetrahedral mesh.
% Input: file name
% Output: Coordinates of points (nx3) and list of tets (mx4)

% Skip header
fid = fopen(filename, 'r');
get_nextline(fid);

% Get number of points
s = get_nextline(fid);
nv = sscanf(s, '%d');
get_nextline(fid);

% Read in coordinates
ts = fscanf(fid, '%g', [4,nv]);
xs = ts(1:3,:)';
get_nextline(fid);

% Get number of boundary faces
s = get_nextline(fid);
nbtris = sscanf(s, '%d');
get_nextline(fid);

% Read in boundary faces
dummy = fscanf(fid, '%d', [4,nbtris]);
get_nextline(fid);

% Get number of tets
s = get_nextline(fid);
ntets = sscanf(s, '%d');


% Read in tets
get_nextline(fid);
ts = fscanf(fid, '%d', [4,ntets]);
tets=ts';

fclose( fid);
end

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
    s = fgetl(fid);
    while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
        s = fgetl(fid);
    end
end

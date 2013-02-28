function [xs, elems] = readneu(filename)
%READNEU: Read in a Gambit Neutral file.
%
% Input: file name
% Output: Coordinates of points (n-by-3) and list of elements (m-by-d)

% Skip header
fid = fopen(filename, 'r');
for i=1:6
    get_nextline(fid);
end

% Get number of points and faces
s = get_nextline(fid);
ns = sscanf(s, '%d', [2,1]);
nvs = ns(1); nts = ns(2);

% Skip two lines
for i=1:2
    get_nextline(fid);
end

% Read in coordinates
ts = fscanf(fid, '%g', [4,nvs]);
xs=ts(2:end,:)';

% Skip two lines
for i=1:2
    get_nextline(fid);
end

% Determine the number of vertices per cell.
s = get_nextline(fid);
nvpe = sscanf(s, '%*d %*d %d', 1);

pat = ['%*d %*d %*d ' repmat(' %d', 1, nvpe)];
ts = zeros( nvpe,nts,'int32');
ts(:,1) = sscanf(s, pat, nvpe);
% Read in tets
ts(:,2:end) = fscanf(fid, pat, [nvpe, nts-1]);
elems=ts';

fclose( fid);
end

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
    s = fgetl(fid);
    while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
        s = fgetl(fid);
    end
end

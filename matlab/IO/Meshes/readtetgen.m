function [xs, tets] = readtetgen( prefix)
%READTETGEN   Read files in Tetgen format
% [XS, TETS] = READTETGEN( PREFIX)

% Read in number of nodes
fname = [prefix '.1.node'];
fid = fopen(fname, 'r');
nv = fscanf(fid, '%d', 1);
get_nextline(fid);

% Read in coordinates
ts = fscanf(fid, '%g', [4, nv]);
xs = ts(2:4,:)';
fclose(fid);

% Read in elements
fname = [prefix '.1.ele'];
fid = fopen(fname, 'r');
ntets = fscanf(fid, '%d', 1);
get_nextline(fid);

% Read in coordinates
ts = fscanf(fid, '%g', [5, ntets]);
tets = ts(2:5,:)'+1;
fclose(fid);

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#' || strcmp(s,' ') || s(1)==13)
    s = fgetl(fid);
end

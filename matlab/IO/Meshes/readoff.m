function [xs, fs] = readoff( fname_off)
% Read in a file in OFF format.
% Input:  file name
% Output: coordinates of points (nx3) and list of faces (mx3)

% Read in OFF format
fid = fopen(fname_off, 'r');
if fid<=0
    error('Could not open file "%s"', fname_off);
end

try
    s = get_nextline(fid);
    if ~strncmp( s, 'OFF', 3)
        fprintf(1, 'File %s does not contain keyword OFF. Input file may be invalid\n', fname_off);
    end
    
    % Get number of points and faces
    s = get_nextline(fid);
    ns = sscanf(s, '%d', [2,1]);
    nvs = ns(1); nfs = ns(2);
    
    % Read in coordinates
    xs = zeros(nvs, 3);
    s = get_nextline(fid);
    xs(1,:) = sscanf(s, '%g', [1,3]);
    if isempty(strfind( s, '#'))
        xs(2:end,:) = fscanf(fid, '%g', [3,nvs-1])';
    else
        for ii=2:nvs
            xs(ii,:) = fscanf(fid, '%g', [1,3]); fgetl(fid);
        end
    end
    
    % Read in faces
    s = get_nextline(fid);
    nvpe = sscanf(s, '%d', [1,1]);
    
    fs = zeros(nfs, nvpe, 'int32');
    [tmp, count] = sscanf(s, '%d', [1,nvpe+5]);
    fs(1,:) = tmp(1,2:nvpe+1)+1;
    if isempty(strfind( s, '#')) && count==nvpe+1
        fs(2:end,:) = fscanf(fid, ['%*d' repmat(' %d',1,nvpe)], [nvpe,nfs-1])' +1;
    else
        for ii=2:nfs
            % We assume every line ends with #
            fs(ii,:) = fscanf(fid, ['%*d' repmat(' %d',1,nvpe)], [nvpe,1])'+1; fgetl(fid);
        end
    end
catch %#ok<CTCH>
    fclose( fid);
    rethrow(lasterror); %#ok<LERR>
end

fclose( fid);

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#' || strcmp(s,' ') || s(1)==13)
    s = fgetl(fid);
end

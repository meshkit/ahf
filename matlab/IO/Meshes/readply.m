function [xs, fs, nodeproperties] = readply( fname_ply )
% Read in a file in PLY format.
% Input:  file name
% Output: coordinates of points (nx3) and list of faces (mx3)

% Read in PLY format
fid = fopen(fname_ply, 'r');
if fid<=0
    error('Could not open file "%s"', fname_ply);
end

try
    s = fgetl(fid);
    if (~strncmp( s, 'ply', 3) && ~strncmp( s, 'PLY', 3))
        fprintf(1, 'File %s does not contain keyword ply. Input file may be invalid\n', fname_ply);
    end
    
    [t] = strtok(s);
    while ~strcmpi(t,'element') && ~feof(fid)
      s = fgetl(fid);
      [t] = strtok(s);
    end
    
    nnodes=strtok(s,'element vertex');
    nnodes = str2num(nnodes); %#ok<ST2NM>
    
    s = fgetl(fid);
    [t] = strtok(s);
    if(strcmpi(t,'property') && ~feof(fid))
        s = fgetl(fid);
        s = fgetl(fid); % skip xyz as are defaults
    end
    numproperties=0;
    while(strcmpi(t,'property') && ~feof(fid))
        s = fgetl(fid);
        [t] = strtok(s);
        if(strcmpi(t,'property') && ~feof(fid))
          numproperties=numproperties+1;
        end 
    end
    if strcmpi(t,'element') && ~feof(fid)
    else
        s = fgetl(fid);
        [t] = strtok(s);
        while ~strcmpi(t,'element') && ~feof(fid)
          s = fgetl(fid);
          [t] = strtok(s);
        end
    end
    
    nfs=strtok(s,'element face');
    nfs = str2num(nfs); %#ok<ST2NM>
    
    s = fgetl(fid);
    [t] = strtok(s);
    while ~strcmpi(t,'end_header') && ~feof(fid)
      s = fgetl(fid);
      [t] = strtok(s);
    end
    
    % Read in coordinates
    if(numproperties==0)
        xs = zeros(nnodes, 3);
        s = get_nextline(fid);
        xs(1,:) = sscanf(s, '%g', [1,3]);
        xs(2:end,:) = fscanf(fid, '%g', [3,nnodes-1])';
    else
        nodeproperties = zeros(nnodes, 3+numproperties);
        s = get_nextline(fid);
        nodeproperties(1,:) = sscanf(s, '%g', [1,3+numproperties]);
        nodeproperties(2:end,:) = fscanf(fid, '%g', [3+numproperties,nnodes-1])';
        xs=nodeproperties(:,1:3);
        nodeproperties=nodeproperties(:,4:end);
    end
    
    % Read in faces
    s = get_nextline(fid);
% NOTE THIS ONLY WORKS IF ALL OF THE FACES HAVE THE SAME NUMBER OF VERTICES
    nvpe = sscanf(s, '%d', [1,1]);
    
    fs = zeros(nfs, nvpe);
    [tmp, count] = sscanf(s, '%d', [1,nvpe+5]);
    % ADD ONE SINCE PLY IS ZERO BASED
    fs(1,:) = tmp(1,2:nvpe+1);
    fs(2:end,:) = fscanf(fid, ['%*d' repmat(' %d',1,nvpe)], [nvpe,nfs-1])';
    
catch %#ok<CTCH>
    fclose( fid);
    rethrow(lasterror); %#ok<LERR>
end

fclose( fid);
fs=fs+1;

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#' || strcmp(s,' ') || s(1)==13)
    s = fgetl(fid);
end

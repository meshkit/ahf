function [xs, elems] = readgmv_ascii( fname_gmv )
% Read in a file in GMV format.
% Input:  file name
% Output: coordinates of points (nx3) and list of element (mxn)

% Read in GMV format
fid = fopen(fname_gmv, 'r');
if fid<=0
    error('Could not open file "%s"', fname_gmv);
end

try
    s = fgetl(fid);
    if (~strncmp( s, 'gmvinput ascii', 3))
        fprintf(1, 'File %s does not contain keyword gmvinput ascii.\n', fname_gmv); 
        fprintf(1,'Input file may be invalid\n');
    end
    
    [t] = strtok(s);
    while ~strcmpi(t,'nodes') && ~feof(fid)
      s = fgetl(fid);
      [t] = strtok(s);
    end
    
    nnodes=strtok(s,'nodes');
    nnodes = str2double(nnodes);
    
    % Read in coordinates
    xs = zeros(nnodes, 3);
    s = get_nextline(fid);
    ts=sscanf(s, '%g');
    xs(:,1)=ts;
    s = get_nextline(fid);
    ts=sscanf(s, '%g');
    xs(:,2)=ts;
    s = get_nextline(fid);
    ts=sscanf(s, '%g');
    xs(:,3)=ts;
    
    
    s = fgetl(fid);
    [t] = strtok(s);
    while ~strcmpi(t,'cells') && ~feof(fid)
      s = fgetl(fid);
      [t] = strtok(s);
    end
    
    nelements=strtok(s,'cells');
    nelements = str2num(nelements); %#ok<ST2NM>
    if(nelements==0);return;end;
    elems=zeros(nelements,8,'int32');
    maxnpe=0;
    count=0;
    for i=1:2*nelements
      s = fgetl(fid);
      [t] = strtok(s);
      if (strcmpi(t,'line'))
          npe=str2double(strtok(s,'line'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'tri'))
          npe=str2double(strtok(s,'tri'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'quad'))
          npe=str2double(strtok(s,'quad'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'hex'))
          npe=str2double(strtok(s,'hex'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'prism'))
          npe=str2double(strtok(s,'prism'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'tet'))
          npe=str2double(strtok(s,'tet'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'pyr'))
          npe=str2double(strtok(s,'pyr'));
          if(npe>maxnpe);maxnpe=npe;end
      elseif (strcmpi(t,'pt'))
          npe=str2double(strtok(s,'pt'));
          if(npe>maxnpe);maxnpe=npe;end
      else
          count=count+1;
          elems(count,1:npe)=sscanf(s, '%d');
      end
    end
    if(maxnpe<8)
      for i=8:-1:maxnpe+1
        elems(:,i)=[];
      end
    end
    [t] = strtok(s);
    while ~strcmpi(t,'endgmv') && ~feof(fid)
      s = fgetl(fid);
      [t] = strtok(s);
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

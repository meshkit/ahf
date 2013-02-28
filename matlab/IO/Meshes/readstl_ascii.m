function [xs,tris]=readstl_ascii(filename,dsmin)
%NOTE: STL is a terrible and wasteful format, though it is popular. To be
%at all practical, this file should be compiled.
%ALSO NOTE: STL contains no specific connectivity information. As a result,
%nodes are repeated and repeats must be deleted.
if(nargin <2)
    dsmin=1E-12;
end
fid = fopen(filename, 'r');

%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end
notdone=true;
ntris=0;
npoints=0;
while(notdone)
  s = get_nextline(fid);
  if(~isempty(findstr(s,'endloop')))
      ntris=ntris+1;
  elseif(~isempty(findstr(s,'vertex')))
      npoints=npoints+1;
  elseif(~isempty(findstr(s,'endsolid')))
      break
  end
end
fclose(fid);
xs=zeros(npoints,3);
tris=zeros(ntris,1,'int32');
fprintf(1,'Allocating for %d nodes and %d triangles \n',npoints,ntris);
fid = fopen(filename, 'r');
notdone=true;
point=0;
thistris=0;
while(notdone)
  s = get_nextline(fid);
  if(~isempty(findstr(s,'endloop')))
      thistris=thistris+1;
      tris(thistris,1)=point-2;
      tris(thistris,2)=point-1;
      tris(thistris,3)=point-0;
  elseif(~isempty(findstr(s,'vertex')))
       point=point+1;
       xs(point,:) = sscanf(s, '%*s %e %e %e');
  elseif(~isempty(findstr(s,'endsolid')))
      break
  end
end

% Now filter out duplicate points
alias=filter_points(xs,dsmin);

% Renumber entries in alias by eliminating duplicated nodes.
nodes = (1:size(xs,1))';

%condense xs and redo the connectivity
xs(alias~=nodes,:) = [];

%Define new node IDs
newnodeids = zeros(size(nodes,1),1,'int32');
nodes(alias~=nodes) = [];
newnodeids(nodes) = 1:size(nodes,1,'int32');

%Change alias to map to new nodes
alias = newnodeids(alias);
assert(all(alias)); % No entry in alias should be zero.

%Update the connectivity array
for i=1:ntris
  for j=1:3
    tris(i,j)=alias(tris(i,j));
  end
end

end

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
    s = fgetl(fid);
    while ~feof(fid) && (isempty(s) || (~isempty(findstr(s,'solid'))) || ...
            (~isempty(findstr(s,'facet'))) || (~isempty(findstr(s,'outer'))))
        s = fgetl(fid);
    end
end
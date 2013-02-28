function [xs, elems, constraints, parts, vectors, faclabels] = ...
    read_lsdyna(filename) 
% PRIMITIVE LSDYNA READER THAT ASSUMES HEXES FOR NOW
%
% See also WRITE_LSDYNA

% 
fid = fopen(filename, 'r');
%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end

% 
s='';
while ~strcmp(s,'*NODE')
  s = get_nextline(fid);
end
%COUNT UP THE NUMBER OF NODES
nnodes=0;
while 1 
  s = get_nextline(fid);
  if(strcmp(s(1),'*') )
      break
  end
  nnodes=nnodes+1;
end
xs = zeros(nnodes,3);
constraints=zeros(nnodes,2,'int32');
fclose(fid);
%NOW DETERMINE THE NUMBER OF ELEMENTS
fid = fopen(filename, 'r');
nelems=0;
ortho=false;
s=''; %#ok<NASGU>
while 1
  s = get_nextline(fid);
  if(strcmp(s,'*ELEMENT_SOLID'))
      break
  elseif(strcmp(s,'*ELEMENT_SOLID_ORTHO'))
      ortho=true;
      break
  end
end
while 1  
  s = get_nextline(fid);
  if(strcmp(s(1),'*'))
      break
  end
  if(ortho)
      s = get_nextline(fid); %#ok<NASGU>
      s = get_nextline(fid); %#ok<NASGU>
      nelems=nelems+1;
  else
    nelems=nelems+1;
  end 
end
%WE ARE ASSUMING HEXES
elems=zeros(nelems,8,'int32');
parts=zeros(nelems,1,'int32');
if(ortho)
    fiber1=zeros(nelems,3);
    fiber2=zeros(nelems,3);
end
fclose(fid);
%NOW READ IN NODES
fid = fopen(filename, 'r');
s='';
while ~strcmp(s,'*NODE')
  s = get_nextline(fid);
end
%
icount=0;
comma=false;
constrained=true;
while 1 
  s = get_nextline(fid);
  if(strcmp(s(1),'*') )
      break
  end
  if(icount==0)
      if(s(2)==',')
          comma=true;
      end
  end
  if(comma)
      if(icount==0)
        [x y z c1 c2] = ...
              strread(s,'%*d %f %f %f %d %d','delimiter',','); %#ok<NASGU>
        if(isempty(c1))
            constrained=false;
        end
      end
      if(constrained)
        [x y z c1 c2] = strread(s,'%*d %f %f %f %d %d','delimiter',',');
        icount=icount+1;
        xs(icount,:) = [x y z];
        constraints(icount,:)=[c1 c2];
      else
        [x y z] = strread(s,'%*d %f %f %f','delimiter',',');
        icount=icount+1;
        xs(icount,:) = [x y z];
      end
  else
      if(icount==0)
        [x y z c1 c2] = ...
              strread(s,'%*d %f %f %f %d %d','delimiter',','); %#ok<NASGU>
        if(isempty(c1))
            constrained=false;
        end
      end
      if(constrained)
        tmp = sscanf(s, '%*d %f %f %f %d %d');
        icount=icount+1;
        xs(icount,:) = tmp(1:3);
        constraints(icount,:)=tmp(4:5);
      else
        tmp = sscanf(s, '%*d %f %f %f');
        icount=icount+1;
        xs(icount,:) = tmp(1:3);
      end
  end
end
fclose(fid);
%
%NOW READ IN ELEMENTS
s=''; %#ok<NASGU>
comma=false;
fid = fopen(filename, 'r');
while 1
  s = get_nextline(fid);
  if(strcmp(s,'*ELEMENT_SOLID'))
      break
  elseif(strcmp(s,'*ELEMENT_SOLID_ORTHO'))
      break
  end
end
icount=0;
while 1  
  s = get_nextline(fid);
  if(icount==0)
      if(s(2)==',')
          comma=true;
      end
  end
  if(strcmp(s(1),'*'))
      break
  end
  if(ortho)
      icount=icount+1;
      if(comma)
        [p1 n1 n2 n3 n4 n5 n6 n7 n8] = ...
            strread(s,'%*d %d %d %d %d %d %d %d %d %d',...
            'delimiter',',');
        parts(icount)=p1;
        elems(icount,:) = [n1 n2 n3 n4 n5 n6 n7 n8];
        s = get_nextline(fid);
        [f1 f2 f3]=strread(s,'%f %f %f','delimiter',',');
        fiber1(icount,:)=[f1 f2 f3];
        s = get_nextline(fid);
        [f1 f2 f3]=strread(s,'%f %f %f','delimiter',',');
        fiber2(icount,:)=[f1 f2 f3];
      else
        tmp = sscanf(s, '%d');
        elems(icount,:) = tmp(3:10);
        s = get_nextline(fid);
        tmp = sscanf(s, '%f');
        fiber1(icount,:)=tmp(1:3);
        s = get_nextline(fid);
        tmp = sscanf(s, '%f');
        fiber2(icount,:)=tmp(1:3);
      end
  else
      icount=icount+1;
      if(comma)
        [n1 n2 n3 n4 n5 n6 n7 n8] = strread(s,'%*d %*d %d %d %d %d %d %d %d %d',...
            'delimiter',',');
        elems(icount,:) = [n1 n2 n3 n4 n5 n6 n7 n8];
      else
        tmp = sscanf(s, '%d');
        elems(icount,:) = tmp(3:10);
      end
  end 
end
fclose(fid);
if(ortho)
  vectors=zeros(nelems,6);
  vectors(:,1:3)=fiber1;
  vectors(:,4:6)=fiber2;
else
    vectors=[];
end
% 
%DETERMINE IF THERE ARE ANY SEGMENT SETS TO READ OVER
s=''; %#ok<NASGU>
sets=0;
numsets=zeros(1000,1,'int32');
fid = fopen(filename, 'r');
while 1
  s = get_nextline(fid);
  if(strcmp(s,'*SET_SEGMENT'))
    while 1
      sets=sets+1;
      s = get_nextline(fid);
      while 1
        s = get_nextline(fid);
        if(strcmp(s(1),'*'))
          break
        end
        numsets(sets)=numsets(sets)+1;
      end
      if(strcmp(s,'*END'))
        break
      end
    end
  end
  if(strcmp(s,'*END'))
      break
  end
end
    fclose(fid);
if(sets==0)
    faclabels=[];
    return
end
numsegments=sum(numsets(:));
faclabels=zeros(size(numsegments,5),'int32');
sets=0;
fid = fopen(filename, 'r');
count=0;
while 1
  s = get_nextline(fid);
  if(strcmp(s,'*SET_SEGMENT'))
      s = get_nextline(fid);
      while 1
        sets=sets+1;
        while 1
          s = get_nextline(fid);
          if(strcmp(s(1),'*'))
            break
          end
          count=count+1;
          faclabels(count,1)=sets;
          if(comma)
            [n1 n2 n3 n4] = strread(s,'%d %d %d %d %*f %*f %*f %*f','delimiter',',');
            faclabels(count,2:5) = [n1 n2 n3 n4];
          end
        end
        if(strcmp(s,'*END'))
          break
        end
        if(strcmp(s,'*SET_SEGMENT'))
            s = get_nextline(fid);
        end
      end
  end
  if(strcmp(s,'*END'))
      break
  end
end

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='$' || s(1)==13)
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


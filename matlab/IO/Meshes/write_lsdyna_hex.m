function write_lsdyna_hex(filename, nodes, hexes, constraints, parts,...
    vectors, faclabels)
%WRITE_LSDYNA   Write out tetrahedral mesh in LSDYNA format.
% If flabel is present, write it out also.
fid = fopen(filename,'Wt');
iscontraints=true;
isvector=true;
isssegment=true;
if(nargin<4)
    iscontraints=false;
    isvector=false;
    isssegment=false;
    parts=ones(size(hexes,1),1);
elseif(nargin<5)
    isvector=false;
    isssegment=false;
    parts=ones(size(hexes,1),1);
elseif(nargin<6)
    isvector=false;
    isssegment=false;
elseif(nargin<7)
    isssegment=false;
end
if(isvector)
  if(size(vectors,2)~=6)
      isvector=false;
      %error('Two vectors are needed');
  end
end
if(iscontraints)
  if(size(constraints,2)~=2)
      error('Two constraints are needed');
  end
end

nv = size(nodes,1); nhexes = size(hexes,1);

% Write out nodes
fprintf(fid,'*NODE\n');
for i=1:nv
    if(iscontraints)
      fprintf(fid,'%d, %0E, %0E, %0E, %d, %d\n',...
          i,nodes(i,1:3),constraints(i,1),constraints(i,2));
    else
      fprintf(fid,'%d, %0E, %0E, %0E\n',i,nodes(i,1:3));
    end
end

% Write out tets
if(isvector)
    fprintf(fid,'*ELEMENT_SOLID_ORTHO\n');
else
    fprintf(fid,'*ELEMENT_SOLID\n');
end
for i=1:nhexes
    fprintf(fid,'%d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n',...
        i,parts(i),hexes(i,1:8));
    if(isvector)
      fprintf(fid,'%0E, %0E, %0E\n',vectors(i,1:3));
      fprintf(fid,'%0E, %0E, %0E\n',vectors(i,4:6));
    end 
end

if(isssegment)
  numsets=max(faclabels(:,1));
  numsegs=size(faclabels,1);
  for i=1:numsets
    fprintf(fid,'*SET_SEGMENT\n');
    fprintf(fid,'%d,0.000E+00,0.000E+00,0.000E+00,0.000E+00\n',i);
    for j=1:numsegs
        if(faclabels(j,1)==i)
          n1=faclabels(j,2);
          n2=faclabels(j,3);
          n3=faclabels(j,4);
          n4=faclabels(j,5);
          fprintf(fid,'%d,%d,%d,%d,0.000E+00,0.000E+00,0.000E+00,0.000E+00\n'...
              ,n1,n2,n3,n4);
        end
    end
  end
end
fprintf(fid,'*END\n');
fclose(fid);

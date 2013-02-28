function write_lsdyna_tet(filename, nodes, tets, constraints, parts,...
    vectors, segments)
%WRITE_LSDYNA   Write out tetrahedral mesh in LSDYNA format.
% INPUTS:
%       VECTORS -     is an ncell x 6 array with two vectors that define a 
%                     local cooordinate system 
%       CONSTRAINTS - is an nnodes x 2 array with nodal constraints. See
%                     LSDYNA manual
%       SEGMENTS -    is an number of segments x 4 array. Column 1 has the 
%                     segment number, columns 2-4 have the node numbers 
%                     that define the segment 
% 
fid = fopen(filename,'Wt');
iscontraints=true;
isssegment=true;
%if(nargin<4)
%    iscontraints=false;
%    isvector=false;
%    isssegment=false;
%elseif(nargin<5)
%    isvector=false;
%    isssegment=false;
%elseif(nargin<6)
%    isssegment=false;
%    isvector=false;
%end
if(isempty(vectors))
   isvector=false;
else
  if(size(vectors,2)~=6)
    error('Two vectors are needed');
  else
    isvector=true;
  end
end
if(isempty(constraints))
   iscontraints=false;
end
if(isempty(parts))
   ntets=size(tets,1);
   parts=ones(ntets,1);
end
if(isempty(segments))
   isssegment=false;
end
if(iscontraints)
  if(size(constraints,2)~=2)
      error('Two constraints are needed');
  end
end

nv = size(nodes,1); ntets = size(tets,1);

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
for i=1:ntets
    fprintf(fid,'%d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n',...
        i,parts(i),tets(i,1:4), tets(i,4), tets(i,4), tets(i,4), tets(i,4));
    if(isvector)
      fprintf(fid,'%0E, %0E, %0E\n',vectors(i,1:3));
      fprintf(fid,'%0E, %0E, %0E\n',vectors(i,4:6));
    end 
end
  
if(isssegment)
  numsets=max(segments(:,1));
  numsegs=size(segments,1);
  for i=1:numsets
    fprintf(fid,'*SET_SEGMENT\n');
    fprintf(fid,'%d,0.000E+00,0.000E+00,0.000E+00,0.000E+00\n',i);
    for j=1:numsegs
        if(segments(j,1)==i)
          n1=segments(j,2);
          n2=segments(j,3);
          n3=segments(j,4);
          fprintf(fid,'%d,%d,%d,%d,0.000E+00,0.000E+00,0.000E+00,0.000E+00\n'...
              ,n1,n2,n3,n3);
        end
    end
  end
end
fprintf(fid,'*END\n');
fclose(fid);

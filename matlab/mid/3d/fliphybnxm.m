function [elems_buf,elems_offsets,reg_sibhfs,visited]=...
  fliphybnxm(n,m,ntets,elems_buf,elems_offsets,reg_sibhfs,isort,...
  common1,common2,mtet,tempsort,itemp,visited) %#codegen
%
% This routine performs the n-to-m flip
%
% INPUT ARGUMENTS -
%
%  ntets   - the n tets in the old cycle
%  mtet - the connectivity of the m new tets
%  elems_buf - the connectivity array
%  elems_offsets - offset into the connectivity array
%  reg_sibhfs - the regularized face neighbor array
%  isort - a working array  
%  common1,common2 - the two local face numbers of the single shared face
%
% OUTPUT ARGUMENTS -
%
%  elems_buf - the updatedconnectivity array
%  elems_offsets - updated offset into the connectivity array
%  reg_sibhfs - the updated regularized face neighbor array
%
%

coder.extrinsic('fprintf');


markedges=true;
if(nargin<13)
  markedges=false;
 % visited=[];
 % flipedges=[];
end
hf_tet = int32([1,3,2; 1 2 4; 2 3 4; 3 1 4]);
ind=int32(0);
%LOOP THOUGH ALL OF THE FACES OF THE N-COMPLEX
%IF ANY OF THE CONTAIN THE INTERIOR FACES, SKIP THEM
%ADD THE OTHERS TO ISORT
for i=1:n;
  oldit=ntets(i);
  if (nargin>12)&&(nargout>3)
      if(markedges)
          %UNSET ALL OF THE EDGES
          if ((nargin > 12) && (nargout > 3))
              for iedge=1:6
                  visited(oldit) = bitset( visited(oldit), iedge, 0);
              end
          end
      end
  end
  for iface=1:4;
%...WE SKIP ANY OF THE FACES INTERNAL TO THE OLD N-COMPLEX SINCE
%...WE ARE LOOKING ONLY AT THE FACES THAT THE NEIGHBORING ELEMENTS
%...TO THE N-COMPLEX SEE IN THIS PHASE
    if(iface~=common1(i) && iface~=common2(i))
      tempsort(1)=elems_buf(elems_offsets(oldit)+hf_tet(iface,1));
      tempsort(2)=elems_buf(elems_offsets(oldit)+hf_tet(iface,2));
      tempsort(3)=elems_buf(elems_offsets(oldit)+hf_tet(iface,3));
      if(reg_sibhfs(oldit,iface)~=0);
  %.... WHAT IS THE ID OF THE ELEMENT OPPOSITE THE FACE
        oldjt=hfid2cid(reg_sibhfs(oldit,iface));
  %.....AND WHAT IS ITS LOCAL FACE NUMBER
        oldjf=hfid2lfid(reg_sibhfs(oldit,iface));
        ind=ind+1;
        [tempsort]=sort(tempsort);
        isort(1,ind)=tempsort(1);
        isort(2,ind)=tempsort(2);
        isort(3,ind)=tempsort(3);
        isort(4,ind)=0;%THIS IS TO FIGURE OUT WHICH TET TEH FACE BELONGS TO FOR MARKING
        isort(5,ind)=1; %This signals an external face
        isort(6,ind)=oldjf;
        isort(7,ind)=oldjt;
      end;
    end
  end;
end;
%UPDATE CONNECTIVITY FOR NEW TETS
for i=1:m;
  elems_buf(elems_offsets(ntets(i))+1)=mtet(1,i);
  elems_buf(elems_offsets(ntets(i))+2)=mtet(2,i);
  elems_buf(elems_offsets(ntets(i))+3)=mtet(3,i);
  elems_buf(elems_offsets(ntets(i))+4)=mtet(4,i);
end;
%NOW LOOK AT THE FACES EXTERNAL TO THE NEW M-COMPLEX AS
%.WELL AS THE FACES INTERAL TO THE NEW M-COMPLEX
for i=1:m;
  newit=ntets(i);
  for iface=1:4;
    ind=ind+1;
    tempsort(1)=elems_buf(elems_offsets(newit)+hf_tet(iface,1));
    tempsort(2)=elems_buf(elems_offsets(newit)+hf_tet(iface,2));
    tempsort(3)=elems_buf(elems_offsets(newit)+hf_tet(iface,3));
    [tempsort]=sort(tempsort);
    isort(1,ind)=tempsort(1);
    isort(2,ind)=tempsort(2);
    isort(3,ind)=tempsort(3);
    isort(4,ind)=i;%THIS IS TO FIGURE OUT WHICH TET THE FACE ...
                   %BELONGS TO FOR MARKING
    isort(5,ind)=0; %This signals a mixed internal or external face
    isort(6,ind)=iface;
    isort(7,ind)=newit;
  end;
end;
%UPDATE HALFFACE
[isort]=hpsortim(ind,5,7,itemp,isort);
%
i=1;
%.....ESTABLISH NEW REG_SIBHFS ARRAY
while(i<=ind);
  %Our convention is as follows:
  %(1) element's face is unique  ==>  sibhfs = 0
  %(2) face is shared by a pair of elements  ==> sibhfs point at each
  %(3) If face is shared by more than two elements, this is an error

  nmatch=1;
  for j=i+1:ind;
    if((isort(1,i)~=isort(1,j))||(isort(2,i)~=isort(2,j))||...
      (isort(3,i)~=isort(3,j)))
      break; 
    end;
    nmatch=nmatch+1;
  end;

  %Case (1)
  if(nmatch==1) ;
    it=isort(7,i);
    iface=isort(6,i);
    reg_sibhfs(it,iface)=0;
    %Case (2)
  elseif(nmatch==2) ;
    it=isort(7,i); 
    iface=isort(6,i);
    it2=isort(7,i+1);
    iface2=isort(6,i+1);
    if(isort(5,i)==0 && isort(5,i+1)==0) ;
      %This is an internal face
      reg_sibhfs(it,iface) = clfids2hfid(it2, iface2);
      reg_sibhfs(it2,iface2) = clfids2hfid(it, iface);
    else
      %This is an external face
      reg_sibhfs(it,iface) = clfids2hfid(it2, iface2);
      reg_sibhfs(it2,iface2) = clfids2hfid(it, iface);
    end;
  else
   %Case (3)
    %IN 3D THIS IS IMPOSSIBLE AND ONLY OCCURS 1) WHERE VOLUMES ARE
    %SMALLER THAN EPSILONV; OR 2) WHERE SIBHFS ARRAY HAS BEEN CORRUPTED.
    %WHILE 2) IS EASIER TO COMPREHEND IS IS THE LESS LIKELY OF THE TWO.
    %THUS, THE BEST THING TO DO AT THIS POINT IS TO
    %REJECT THE FLIP AND RESET
    fprintf(1,'this is impossible in a 3D mesh. Probably there are\n');
    error('elements with vol << epsilsonv');
  end;
  i=i+nmatch;
end;


return;
end

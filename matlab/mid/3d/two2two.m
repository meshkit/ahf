function [nflips elems_buf,elems_type,elems_offsets,reg_sibhfs]=...
  two2two(inset,eltset,elems_buf,elems_type,elems_offsets,reg_sibhfs,...
  xs_hyb,lboundary_prisms,toldamage,node_constraints,ninset) %#codegen

% specifying input parameters types for eml
assert(isa(inset,'int32')&&(size(inset,2)==1)&&(size(inset,1)>=1));                             % inset is an integer column vector or scalar
assert(isa(eltset,'int32')&&(size(eltset,2)==1)&&(size(eltset,1)>=1));                          % eltset is an integer column vector or scalar
assert(isa(elems_buf,'int32')&&(size(elems_buf,2)==1)&&(size(elems_buf,1)>=1));                 % elems_buf is an integer column vector or scalar
assert(isa(elems_type,'int32')&&(size(elems_type,2)==1)&&(size(elems_type,1)>=1));              % elems_type is an integer column vector or scalar
assert(isa(elems_offsets,'int32')&&(size(elems_offsets,2)==1)&&(size(elems_offsets,1)>=1));     % elems_offsets is an integer column vector or scalar

assert(isa(reg_sibhfs,'int32')&&(size(reg_sibhfs,2)>=3)&&(size(reg_sibhfs,1)>=1)&&(size(reg_sibhfs,2)<=4));
% elems_offsets is an integer [nx4] matrix

assert(isa(xs_hyb,'double')&&(size(xs_hyb,2)==3)&&(size(xs_hyb,1)>=1));                         % xs_hyb is a double [nx4] matrix


assert(isa(lboundary_prisms,'int32') && isscalar(lboundary_prisms));                            % ninsets is an integer scalar
assert(isa(toldamage,'double') && isscalar(toldamage));                                         % toldamage is an integer scalar



assert(isa(node_constraints,'int32')&&(size(node_constraints,1)>=1)&&(size(node_constraints,2)==1));                         % xs_hyb is a double [nx4] matrix
assert(isa(ninset,'int32') && isscalar(ninset));                                                % ninsets is an integer scalar


coder.extrinsic('fprintf');


nflips=int32(0);
tetface_nodes=int32([1 3 2;1 2 4;2 3 4;3 1 4]);
tetface_edges=int32([-3 -2 -1;1 5 -4;2 6 -5;3 4 -6]);
tetedge_faces=int32([0 1 2 3; ...
               1 0 5 4; ...
               2 5 0 6; ...
               3 4 6 0]);
%OPPFACE IS THE NODE OPPOSITE THE FACE
oppface=int32([4 3 1 2]);
%OPPNODE IS THE FACE OPPOSITE THE NODE
oppnode=int32([3 4 2 1]);
tet_edges=int32([1 2;2 3;3 1;1 4;2 4;3 4]);
tempsort=int32([0 0 0]);
itemp=nullcopy(zeros(7,1,'int32'));
tet=4;
%prism=6;
ntet=nullcopy(zeros(4,4,'int32'));
mtet=nullcopy(zeros(4,4,'int32'));
ntets=nullcopy(zeros(4,1,'int32'));
isort=nullcopy(zeros(7,100,'int32'));
common1=nullcopy(zeros(3,1,'int32'));
common2=nullcopy(zeros(3,1,'int32'));
loci=nullcopy(zeros(3,1,'int32'));
nelements=int32(size(elems_type,1));
visited=zeros(nelements,1,'uint32');
i1=int32(0);
i2=i1;
i5=i1;
for iset=1:ninset;
  it=eltset(iset);
  hasBoundary=false;
  if(lboundary_prisms);
    hasBoundary=true;
  else
    onBoundary=find(hfid2cid(reg_sibhfs(it,1:4))==0, 1);
    if(~isempty(onBoundary));
      hasBoundary=true;
    end;
  end
  if(elems_type(it)~=tet || inset(it)<=0 || ~hasBoundary);continue;end
  nfpE = 4;
  for iface=1:nfpE;
    it2=hfid2cid(reg_sibhfs(it,iface));
    shared_face=hfid2lfid(reg_sibhfs(it,iface));
    if(it2<=0 || elems_type(it2)~=tet || inset(it2)<=0);continue;end
    %LOCAL ELEMENT NUMBERS FOR THE SHARED FACE IN IT
    loci(1)=tetface_nodes(iface,1);
    loci(2)=tetface_nodes(iface,2);
    loci(3)=tetface_nodes(iface,3);
    fi1=elems_buf(elems_offsets(it)+loci(1));
    fi2=elems_buf(elems_offsets(it)+loci(2));
    fi3=elems_buf(elems_offsets(it)+loci(3));
    %i3 IS THE THIRD BOUNDARY NODE OF IT
    i3=elems_buf(elems_offsets(it)+oppface(iface));
    %i4 IS THE THIRD BOUNDARY NODE OF IT2
    i4=elems_buf(elems_offsets(it2)+oppface(shared_face));
    %LOOP AROUND THE EDGES OF THE SHARED FACE
    for k=1:3;
      lqualify=false;
      %2TO2 FLIPS ONLY MAKE SENSE ON THE EXTERNAL BOUNDARY
      %AN EXCEPTION IS THE CASE WHERE WE FLIP A STACK OF
      %BOUNDARY PRISMS ABOVE THE TWO TETS
      lprismstack=false;
      if(lboundary_prisms);
      else
        onboundary1=false;
        onboundary2=false;
        ie=abs(tetface_edges(iface,k));
        isvisited=bitget(visited(it),ie);
        if(isvisited);
          continue;
        end;
        %MARK EDGE IN IT AS VISITED
        visited(it) = bitset( visited(it), ie, 1);
        i1=elems_buf(elems_offsets(it)+tet_edges(ie,1));
        i2=elems_buf(elems_offsets(it)+tet_edges(ie,2));
        %EDGES ARE ORIENTED
        if(tetface_edges(iface,k)<0)
          temp=i1;
          i1=i2;
          i2=temp;
        end
        %DETERMINE THE ELEMENT ACROSS THE SHARED EDGE FOR IT AND IT2
        %BECUASE THIS IS A SIMPLEX WE TAKE THE SUM OF THE LOCAL NODE
        %NUMBERS ON THE i'th FACE OF TET IT
        isum=sum(loci);
        lthird1=isum-tet_edges(ie,1)-tet_edges(ie,2);
        %ELEMENT OPPOSITE IT THAT CONTAINS EDGE i1-i2
        if(reg_sibhfs(it,oppnode(lthird1))==0);
          onboundary1=true;
        end
        isum=fi1 + fi2 + fi3;
        i5=isum-i1-i2;
        lthird2=0;
        for q=1:4
          nod=elems_buf(elems_offsets(it2)+q);
          if(nod==i5);
            lthird2=q;
            break;
          end
        end
        if(lthird2==0) ;
          fprintf(1,'stopped after %d flips\n',nflips);
          error('corrupted connectivity and neighborhood data');
        end;
        if(reg_sibhfs(it2,oppnode(lthird2))==0);
          onboundary2=true;
          %MARK EDGE IN IT2 AS VISITED
          iedge=tetedge_faces(shared_face,oppnode(lthird2));
          visited(it2) = bitset( visited(it2), iedge, 1);
        end
        if(onboundary1 && onboundary2);
          lqualify=true;
        end
      end
      %
      if(lqualify||lprismstack);
        %WE HAVE A TOPOLOGICALLY VALID BOUNDARY 2-COMPLEX
        %OPPOSITE THE BOUNDARY
        %TEST IF ALL HAVE THE SAME CONSTRAINTS
        if(node_constraints(i1)~=node_constraints(i2) || ...
           node_constraints(i1)~=node_constraints(i3) || ...
           node_constraints(i1)~=node_constraints(i4));
         continue;
        end;

          vol1=volume(i3,i4,i2,i5,xs_hyb);
          vol2=volume(i4,i3,i1,i5,xs_hyb);
          if(vol1>0.0 && vol2>0.0);
            %TEST DAMAGE ON EXTERNAL BOUNDARY
            if(lboundary_prisms && lprismstack);
              iflag=1;
            else
              [iflag,~]=...
                hybtestdamage(i3,i1,i4,i2,toldamage,xs_hyb);
            end;
            if(iflag==0)
              continue; 
            end;
            %THE OLD TETS
            n=2;
            ntets(1)=it;
            ntets(2)=it2;
            for j=1:n;
              ntet(1,j)=elems_buf(elems_offsets(ntets(j))+1);
              ntet(2,j)=elems_buf(elems_offsets(ntets(j))+2);
              ntet(3,j)=elems_buf(elems_offsets(ntets(j))+3);
              ntet(4,j)=elems_buf(elems_offsets(ntets(j))+4);
            end;
            %THE NEW TETS
            m=2;
            %THE MTET ARRAY HOLDS THE PROPOSED CONNECTIONS
            mtet(1,1)=i3;
            mtet(2,1)=i4;
            mtet(3,1)=i2;
            mtet(4,1)=i5;
            %............
            mtet(1,2)=i4;
            mtet(2,2)=i3;
            mtet(3,2)=i1;
            mtet(4,2)=i5;
            [real_vote,flip]=...
                    isometry_flip_energy_tet(n,ntet,m,mtet,xs_hyb);
            if(flip && ~isnan(real_vote) && isreal(real_vote));
              if(lprismstack);
                %I WILL DO THIS LATER
              else
                common1(1)=iface;common2(1)=iface;
                common1(2)=shared_face;common2(2)=shared_face;
                [elems_buf,elems_offsets,reg_sibhfs]=...
                     fliphybnxm(n,m,ntets,elems_buf,elems_offsets,...
                     reg_sibhfs,isort,common1,common2,mtet,tempsort,...
                     itemp,visited);
                nflips=nflips+1;
                break;
              end;
            end;
          end;
      end;
    end;
  end;
end;

return;
end



function vol=volume(v1,v2,v3,v4,xs)
  xs01 = xs(v2,1:3)-xs(v1,1:3); 
  xs02 = xs(v3,1:3)-xs(v1,1:3);
  xs03 = xs(v4,1:3)-xs(v1,1:3);
  n3 = cross_col( xs01, xs02);
  vol = xs03*n3;
end

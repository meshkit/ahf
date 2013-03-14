function [tets,reg_sibhfs,live_elements]=...
  fill_tetflip_holes(nflips,tets,reg_sibhfs,inset,eltset) %#codegen 

%
%PROPAGATE HOLES
%              
nelements=int32(size(tets,1));
italias=nullcopy(zeros(nelements,1,'int32'));
italiasinv=nullcopy(zeros(nelements,1,'int32'));
ndudded=int32(0);
ninset=int32(size(eltset,1));
itop=ninset;
breakout=false;
for iset=1:ninset;
  it=eltset(iset);
  if(inset(it)<0);
    %TAKE THE FIRST VALID ELEMENT OFF THE TOP OF THE STACK AND PUT 
    %IT IN THE HOLE
    
    while(inset(eltset(itop))<=0);
      %DON'T MEOVE A HOLE INTO A HOLE AND DON'T MOVE A NON-TET INTO THE HOLE
      itop=itop-1;
      if(itop<=ninset-nflips)
        breakout=true;
        break;
      end;
    end;
    if(breakout);break;end
    ndudded=ndudded+1;
    italias(ndudded)=it;
    inset(it)=1;
    it2=eltset(itop);
    italiasinv(ndudded)=it2;
    inset(it2)=-1;
%
    for i=1:4;
      tets(it,1)=tets(it2,i);
      if(reg_sibhfs(it2,i)==0) ;
        reg_sibhfs(it,i)=0;
      else
        neighbor=hfid2cid(reg_sibhfs(it2,i));
        localface=hfid2lfid(reg_sibhfs(it2,i));
        %THIS CORRECTS THE FACE ARRAY FOR IT BUT NOT FOR ITS NEIGHBOR 
        reg_sibhfs(it,i)=reg_sibhfs(it2,i);
        %HERE WE CORRECT FOR THE NEIGHBOR
        reg_sibhfs(neighbor,localface)=it*8+i-1;
      end;
    end;
    itop=itop-1;
    if(itop<=ninset-nflips)
      break; 
    end;
  end;
end;

%  reset number of live elements

live_elements=nelements-nflips;

return;
end




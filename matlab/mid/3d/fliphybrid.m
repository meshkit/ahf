function [inset,eltset,xs_hyb,elems_buf,elems_type,elems_offsets,...
  reg_sibhfs,cum_flips]=...
  fliphybrid(inset,eltset,xs_hyb,elems_buf,elems_type,elems_offsets,...
  reg_sibhfs,node_constraints,dothree2two,dotwo2three,dofour2four,...
  dotwo2two,lboundary_prisms,toldamage) %#codegen 

coder.extrinsic('fprintf');

nflipped_tot=int32(1);
cum_flips=int32(0);
while nflipped_tot>0
  nflipped_tot=int32(0);
  ninset=int32(size(eltset,1));
  nelements=int32(size(elems_type,1));
  length_elemsbuf=int32(size(elems_buf,1));
  live_elements=nelements;
  if(dothree2two)
    tic
    % DO THE 3TO2 FLIPS
    [live_elements,nflips,elems_buf,elems_type,elems_offsets,...
      reg_sibhfs,ninset]=...
       three2two(inset,eltset,elems_buf,elems_type,elems_offsets,...
       reg_sibhfs,xs_hyb,ninset);
    fprintf(1,'number of 3to2 flips in fliphybrid is %d\n',nflips);
    toc
    nflipped_tot=nflipped_tot+nflips;
  end

  % DO THE 2TO3 FLIPS
  if(dotwo2three)
    tic;
    [live_elements,nflips,elems_buf,elems_type elems_offsets,...
      reg_sibhfs,ninset]=...
      two2three(inset,eltset,elems_buf,elems_type,elems_offsets,...
      reg_sibhfs,xs_hyb,int32(live_elements),ninset,nelements);
    fprintf(1,'number of 2to3 flips in fliphybrid is %d\n',nflips);
    toc;
    nflipped_tot=nflipped_tot+nflips;
  end
  %
  %COMPRESS ARRAYS IF THE NUMBER OF ELEMENTS HAS CHANGED
  if(nflipped_tot>0) 
    %both 3-2 and 2-3 flips alter the number of elements
    length=nelements-live_elements;
    if(length>0)
      lenelbuf=int32(size(elems_buf,1));
      elems_buf(lenelbuf-length*4+1:end)=[];
    else
      fprintf(1,'How can I be here?\n');
      elems_buf(length_elemsbuf+abs(length)*4:end)=[];
    end
    elems_type(live_elements+1:end)=[];
    elems_offsets(live_elements+1:end)=[];
    inset(live_elements+1:end)=[];
    reg_sibhfs(live_elements+1:end,:)=[];
    eltset(ninset+1:end)=[];
  end
  
  %DO THE 4TO4 FLIPS
  if(dofour2four)
    tic
    [nflips elems_buf,elems_type,elems_offsets,reg_sibhfs]=...
      four2four(inset,eltset,elems_buf,elems_type,elems_offsets,...
      reg_sibhfs,xs_hyb,ninset);
    fprintf(1,'number of 4to4 flips in fliphybrid is %d\n',nflips);
    toc
    nflipped_tot=nflipped_tot+nflips;
  end
  
  %DO THE 2TO2 FLIPS
  if(dotwo2two)
    tic;
    [nflips elems_buf,elems_type,elems_offsets,reg_sibhfs]=...
     two2two(inset,eltset,elems_buf,elems_type,elems_offsets,reg_sibhfs,...
     xs_hyb,int32(lboundary_prisms),toldamage,node_constraints,ninset);
    fprintf(1,'number of 2to2 flips in fliphybrid is %d\n',nflips);
    toc;
    nflipped_tot=nflipped_tot+nflips;
  end
  cum_flips=cum_flips+nflipped_tot;
end

return
end

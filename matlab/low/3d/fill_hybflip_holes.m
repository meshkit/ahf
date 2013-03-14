function [elems_buf,elems_type,elems_offsets,reg_sibhfs,live_elements]=...
    fill_hybflip_holes(nflips,elems_buf,elems_type,elems_offsets,...
    reg_sibhfs,inset,eltset)  %#codegen
%WE CANNOT SIMPLY MOVE ELEMENTS FROM THE TOP OF THE STACK INTO THE HOLES
%BECAUSE THE ITETOFF AND JTETOFF ARRAYS ARE NOT NECESSARILY INTEGER
%MULTIPLES OF FOUR NOR WILL EACH INCREMENT BE THE SAME. THIS SHOWS THE
%FUTILITY OF THE JTETOFF, ITETOFF ARRAYS. YOU SAVE A BIT IN MEMORY BUT
%IT DOES NOT MAKE UP FOR THE COST IN PROCESSING.
%
coder.extrinsic('fprintf');

%PROPAGATE HOLES
%
lasttet = int32(0);
nelements = int32(size(elems_type,1));
italias = nullcopy(zeros(nelements,1,'int32'));
italiasinv = nullcopy(zeros(nelements,1,'int32'));
lbottomfil = false;
ndudded = int32(0);
ninset = int32(size(eltset,1));
itop = ninset;
breakout = false;
iset_res = int32(0);
for iset=1:ninset;
    it=eltset(iset);
    nvpE=elems_type(it);
    switch(nvpE)
        case {4,10} %TET
            nfpE = 4;
        case {5,14} %PYRAMID
            nfpE = 5;
        case {6,15,18} %PRISM
            nfpE = 5;
        case {8,20,27} %HEX
            nfpE = 6;
        otherwise
            error('Unrecognized element type.');
            nfpE = 0; %#ok<UNRCH>
    end
    if(inset(it)<0);
        %TAKE THE FIRST VALID ELEMENT OFF THE TOP OF THE STACK AND PUT
        %IT IN THE HOLE
        
        while(inset(eltset(itop))<=0||nfpE~=4);
            %DON'T MOVE A HOLE INTO A HOLE AND DON'T MOVE A NON-TET INTO THE HOLE
            itop=itop-1;
            if(itop<=ninset-nflips)
                breakout=true;
                break;
            end;
            if(elems_type(eltset(itop))~=4&& ~lbottomfil)
                %TRIGGER THE BOTTOM FILL ALGORITHM TO ACCOUNTlasttet FOR ANY REMAINING HOLES
                lbottomfil=true;
            end;
        end;
        if(breakout);break;end
        ndudded=ndudded+1;
        italias(ndudded)=it;
        inset(it)=1;
        it2=eltset(itop);
        italiasinv(ndudded)=it2;
        lasttet=it2;
        inset(it2)=-1;
        %
        for i=1:nfpE;
            elems_buf(elems_offsets(it) + i)=elems_buf(elems_offsets(it2) + i);
            if(reg_sibhfs(it2,i)==0) ;
                reg_sibhfs(it,i)=0;
            else
                neighbor = hfid2cid(reg_sibhfs(it2,i));
                localface = hfid2lfid(reg_sibhfs(it2,i));
                %THIS CORRECTS THE FACE ARRAY FOR IT BUT NOT FOR ITS NEIGHBOR
                reg_sibhfs(it,i) = reg_sibhfs(it2,i);
                %HERE WE CORRECT FOR THE NEIGHBOR
                reg_sibhfs(neighbor,localface) = clfids2hfid(it, i);
            end;
        end;
        itop=itop-1;
        if(itop<=ninset-nflips)
            break;
        end;
    end;
    iset_res=iset_res+1;
end;

if(lbottomfil);
    fprintf(1,'Bottom filling\n');
    %
    live_elements=lasttet-1;
    for it=lasttet:nelements;
        if(inset(it)>0);
            live_elements=live_elements+1;
            italias(live_elements)=it;
            italiasinv(it)=live_elements;
        end;
    end;
    last_element=lasttet;
    itoff=elems_offsets(lasttet);
    for it=lasttet:nelements;
        if(inset(it)>0);
            nvpE=elems_type(iset_res);
            switch(nvpE)
                case {4,10} %TET
                    nfpE = 4;
                case {5,14} %PYRAMID
                    nfpE = 5;
                case {6,15,18} %PRISM
                    nfpE = 5;
                case {8,20,27} %HEX
                    nfpE = 6;
                otherwise
                    error('Unrecognized element type.');
            end
            for iface=1:nfpE;
                if(reg_sibhfs(it,iface)==0) ;
                    reg_sibhfs(last_element,iface)=0;
                else
                    neighbor=hfid2cid(reg_sibhfs(it,iface));
                    localface=hfid2lfid(reg_sibhfs(it,iface));
                    neighbor=italiasinv(neighbor);
                    reg_sibhfs(it,iface) = clfids2hfid( neighbor, localface);
                end;
            end;
            elems_offsets(italiasinv(it))=itoff;
            itoff=itoff+elems_type(it);
            elems_type(italiasinv(it))=elems_type(it);
            inset(italiasinv(it))=1;
            for j=1:elems_type(it);
                elems_buf(elems_offsets(italiasinv(it))+j)=...
                    elems_buf(elems_offsets(it)+j);
            end;
            last_element=last_element+1;
        end;
    end;
end
%  reset number of live elements

live_elements=nelements-nflips;

return;
end

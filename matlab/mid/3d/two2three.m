function [live_elements nflips elems_buf,elems_type,...
    elems_offsets,reg_opphfs,ninset]=...
    two2three(inset,eltset,elems_buf,elems_type,elems_offsets,reg_opphfs,...
    xs_hyb,live_elements,ninset,nelements)  %#codegen

% specifying input parameters types for eml
assert(isa(inset,'int32')&&(size(inset,2)==1)&&(size(inset,1)>=1));                             % inset is an integer column vector or scalar
assert(isa(eltset,'int32')&&(size(eltset,2)==1)&&(size(eltset,1)>=1));                          % eltset is an integer column vector or scalar
assert(isa(elems_buf,'int32')&&(size(elems_buf,2)==1)&&(size(elems_buf,1)>=1));                 % elems_buf is an integer column vector or scalar
assert(isa(elems_type,'int32')&&(size(elems_type,2)==1)&&(size(elems_type,1)>=1));              % elems_type is an integer column vector or scalar
assert(isa(elems_offsets,'int32')&&(size(elems_offsets,2)==1)&&(size(elems_offsets,1)>=1));     % elems_offsets is an integer column vector or scalar

assert(isa(reg_opphfs,'int32')&&(size(reg_opphfs,2)==4)&&(size(reg_opphfs,1)>=1));              % elems_offsets is an integer [nx4] matrix
assert(isa(xs_hyb,'double')&&(size(xs_hyb,2)>=3)&&(size(xs_hyb,1)>=1));                         % xs_hyb is a double [nx4] matrix

assert(isa(live_elements,'int32') && isscalar(live_elements));                                  % live_elements is an integer scalar
assert(isa(ninset,'int32') && isscalar(ninset));                                                % ninsets is an integer scalar
assert(isa(nelements,'int32') && isscalar(nelements));                                          % nelements is an integer scalar

maxnef=int32(size(reg_opphfs,2));
tetface_nodes=[1 3 2;1 2 4;2 3 4;3 1 4];
local_tets = [1 3 5 4; 3 2 5 4; 2 1 5 4]';
%OPPFACE IS THE NODE OPPOSITE THE FACE
oppface=[4 3 1 2];
%OPPNODE IS THE FACE OPPOSITE THE NODE
%oppnode=[3 4 2 1];
tempsort=[0 0 0];
itemp=nullcopy(zeros(7,1,'int32'));
tet=4;
tets_old=nullcopy(zeros(4,4,'int32'));
ntets=nullcopy(zeros(4,1,'int32'));
isort=nullcopy(zeros(7,100,'int32'));
common1=nullcopy(zeros(3,1,'int32'));
common2=nullcopy(zeros(3,1,'int32'));
nflips=0;
visited=zeros(nelements,1,'uint32');

neighborhood1=nullcopy(zeros(4,2,'int32'));

for iset=1:ninset;
    it=eltset(iset);
    if(elems_type(it)~=tet && inset(it)<=0);continue;end;
    neighborhood1(1:4,1)=hfid2cid(reg_opphfs(it,1:4));
    neighborhood1(1:4,2)=hfid2lfid(reg_opphfs(it,1:4));
    nfpE = 4;
    for iface=1:nfpE
        isvisited=bitget(visited(it),iface);
        if(isvisited);
            continue;
        end;
        thisneighbor=neighborhood1(iface,1);
        if(thisneighbor == 0);continue;end%on the boundary
        if(elems_type(thisneighbor)~=tet && inset(thisneighbor)<=0);
            continue;
        end
        %NOTE WE CANNOT DETERMINE IF AN EDGE IS VISITED FOR THE 2-3 FLIP SINCE
        %THE FLIP CREATES AN EDGE RATHER THAN FLIPPING IT. IN FACT 2-3 FLIPS
        %ARE RARE. HOWEVER WE CAN HAVE A VISITED-FACE
        i1=elems_buf(elems_offsets(it) + tetface_nodes(iface,1));
        i2=elems_buf(elems_offsets(it) + tetface_nodes(iface,2));
        i3=elems_buf(elems_offsets(it) + tetface_nodes(iface,3));
        i4=elems_buf(elems_offsets(it) + oppface(iface));
        localface=hfid2lfid(reg_opphfs(it,iface));
        visited(it) = bitset( visited(it), iface, 1);
        visited(thisneighbor) = bitset( visited(thisneighbor), localface, 1);
        i5=elems_buf(elems_offsets(thisneighbor)+oppface(localface));
        vids_flip=[i1 i2 i3 i4 i5];
        valid_flip = positive_tets( vids_flip, xs_hyb);
        if ~valid_flip
            continue;
        end
        %THE OLD TETS
        ntets(1)=it;
        ntets(2)=thisneighbor;
        for k=1:2;
            tets_old(1,k)=elems_buf(elems_offsets(ntets(k))+1);
            tets_old(2,k)=elems_buf(elems_offsets(ntets(k))+2);
            tets_old(3,k)=elems_buf(elems_offsets(ntets(k))+3);
            tets_old(4,k)=elems_buf(elems_offsets(ntets(k))+4);
        end;
        tets_new = vids_flip(local_tets);
        
        %EVALUATE THE ERROR
        [real_vote,flip]=...
            isometry_flip_energy_tet(2,tets_old,3,tets_new,xs_hyb);
        if(~flip || isnan(real_vote) || ~isreal(real_vote)) ;
            continue
        end
        %CHECK TO MAKE SURE THERE IS ENOUGH OVERHEAD
        if(live_elements==nelements);
            inc = int32(ceil(nelements*0.2));
            nelements = nelements + inc;
            elems_buf = [elems_buf; nullcopy(zeros(4*inc,1,'int32'))]; %#ok<*AGROW>
            elems_type = [elems_type; nullcopy(zeros(inc,1,'int32'))];
            visited = [visited; zeros(inc,1, 'uint32')];
            elems_offsets = [elems_offsets; nullcopy(zeros(inc,1, 'int32'))];
            reg_opphfs = [reg_opphfs; nullcopy(zeros(4*inc, maxnef, 'int32'))];
            inset = [inset; nullcopy(zeros(inc,1, 'int32'))];
            eltset = [eltset; nullcopy(zeros(inc,1, 'int32'))];
        end;
        it3=live_elements+1;
        ntets(3)=it3;
        %MARK THE FOUR FACES OF EACH NEW TET AS UNVISITED
        visited(ntets(1:3)) = bitset( visited(ntets(1:3)), 1, 0);
        visited(ntets(1:3)) = bitset( visited(ntets(1:3)), 2, 0);
        visited(ntets(1:3)) = bitset( visited(ntets(1:3)), 3, 0);
        visited(ntets(1:3)) = bitset( visited(ntets(1:3)), 4, 0);
        %
        elems_offsets(it3)=elems_offsets(live_elements)+4;
        elems_type(it3)=tet;
        live_elements=live_elements+1;
        % FLIP IT
        common1(1)=iface;common2(1)=iface;
        common1(2)=localface;common2(2)=localface;
        [elems_buf,elems_offsets,reg_opphfs]=...
            fliphybnxm(2,3,ntets,elems_buf,elems_offsets,...
            reg_opphfs,isort,common1,common2,tets_new,tempsort,itemp);
        inset(ntets(3))=1;
        ninset=ninset+1;
        eltset(ninset)=it3;
        nflips=nflips+1;
    end;
end;


return;
end

function b = positive_tets( vids, xs)
% Check whether the configuration of the give six vertices
% form four valid tets
local_tets = [1 3 5 4; 3 2 5 4; 2 1 5 4];

b = true;
for i=1:3
    v1 = vids(local_tets(i,1));
    xs01 = xs(vids(local_tets(i,2)),1:3)-xs(v1,1:3);
    xs02 = xs(vids(local_tets(i,3)),1:3)-xs(v1,1:3);
    xs03 = xs(vids(local_tets(i,4)),1:3)-xs(v1,1:3);
    n3 = cross_col( xs01, xs02);
    vol = xs03*n3;
    
    if vol <= 0
        b = false; return
    end
end
end

function [nflips elems_buf,elems_type,elems_offsets,reg_opphfs]=...
    four2four(inset,eltset,elems_buf,elems_type,elems_offsets,reg_opphfs,...
    xs_hyb,ninset) %#codegen


% specifying input parameters types for eml
assert(isa(inset,'int32')&&(size(inset,2)==1)&&(size(inset,1)>=1));                             % inset is an integer column vector or scalar
assert(isa(eltset,'int32')&&(size(eltset,2)==1)&&(size(eltset,1)>=1));                          % eltset is an integer column vector or scalar
assert(isa(elems_buf,'int32')&&(size(elems_buf,2)==1)&&(size(elems_buf,1)>=1));                 % elems_buf is an integer column vector or scalar
assert(isa(elems_type,'int32')&&(size(elems_type,2)==1)&&(size(elems_type,1)>=1));              % elems_type is an integer column vector or scalar
assert(isa(elems_offsets,'int32')&&(size(elems_offsets,2)==1)&&(size(elems_offsets,1)>=1));     % elems_offsets is an integer column vector or scalar

assert(isa(reg_opphfs,'int32')&&(size(reg_opphfs,2)>=3)&&(size(reg_opphfs,1)>=1));              % elems_offsets is an integer [nx4] matrix
assert(isa(xs_hyb,'double')&&(size(xs_hyb,2)==3)&&(size(xs_hyb,1)>=1));                         % xs_hyb is a double [nx4] matrix

assert(isa(ninset,'int32') && isscalar(ninset));                                                % ninsets is an integer scalar


nflips=int32(0);

% List of connectivity of four tets given six vertices
local_tets = int32([1 2 3 4; 1 2 4 5; 1 2 5 6; 1 2 6 3]');
tetface_nodes = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
next = int32([2 3 1]);
tetface_edges=int32([3 2 1; 1 5 4; 2 6 5; 3 4 6]);

%OPPNODE IS THE FACE OPPOSITE THE NODE
oppnode=int32([3 4 2 1]);
tempsort=int32([0 0 0]);
itemp=nullcopy(zeros(7,1,'int32'));
tet=4;
tet_old=nullcopy(zeros(4,4,'int32'));
isort=nullcopy(zeros(7,100,'int32'));
common1=nullcopy(zeros(4,1,'int32'));
common2=nullcopy(zeros(4,1,'int32'));
neighborhood1=nullcopy(zeros(4,2,'int32'));
MAX=40;
elms_1ring = nullcopy(zeros(1, MAX,'int32'));
lvid_1ring = nullcopy(zeros(1, MAX,'int32'));
nelements=int32(size(elems_type,1));
visited=zeros(nelements,1,'uint32');

for iset=1:ninset;
    %THE MESH MAY BE HYBRID, BUT WE ONLY FLIP TETS.
    it=eltset(iset);
    breakout=false;
    if elems_type(it)~=tet || inset(it)<=0; continue; end
    
    neighborhood1(1:4,1)=hfid2cid(reg_opphfs(it,1:4));
    neighborhood1(1:4,2)=hfid2lfid(reg_opphfs(it,1:4));
    nfpE = 4;
    for iface=1:nfpE
        %LOOP OVER ALL OF THE EDGES OF THE SHARED FACE
        for j=1:3
            isvisited=bitget(visited(it),tetface_edges(iface,j));
            if(isvisited);
              continue;
            end;
            [ntets, elems_1ring, lvid_1ring,visited] = ...
                obtain_tets_around_edge(it, iface, j, elems_buf, ...
                elems_offsets, elems_type, inset, reg_opphfs,...     
                elms_1ring,lvid_1ring,MAX,visited,1);   
                %elms_1ring,lvid_1ring,MAX);  
            if ntets~=4; continue; end
            
            vids_1ring = [ elems_buf( elems_offsets( it) + tetface_nodes( iface, next(j)));
                elems_buf( elems_offsets( it) + tetface_nodes( iface, j));
                elems_buf( elems_offsets( elems_1ring(1)) + lvid_1ring(1));
                elems_buf( elems_offsets( elems_1ring(2)) + lvid_1ring(2));
                elems_buf( elems_offsets( elems_1ring(3)) + lvid_1ring(3));
                elems_buf( elems_offsets( elems_1ring(4)) + lvid_1ring(4))];

            vids_46 = vids_1ring([4 6 1 3 2 5]);
            vids_35 = vids_1ring([3 5 1 6 2 4]);
            
            valid_46 = positive_tets( vids_46, xs_hyb);
            valid_35 = positive_tets( vids_35, xs_hyb);
            if ~valid_46 && ~valid_35
                continue; 
            end
            
            %THE OLD TETS
            for k=1:4
                tet_old(1,k) = elems_buf(elems_offsets(elems_1ring(k))+1);
                tet_old(2,k) = elems_buf(elems_offsets(elems_1ring(k))+2);
                tet_old(3,k) = elems_buf(elems_offsets(elems_1ring(k))+3);
                tet_old(4,k) = elems_buf(elems_offsets(elems_1ring(k))+4);
            end;
            
            %
            %THERE ARE TWO CONFIGURATIONS TO TRY FOR THE 4TO4 FLIP
            flip1=false; flip2=false;
            vote1=0.0; vote2=0.0;
            
            %FIRST CONFIGURATION. Use edge v4-v6
            if valid_46
                %THE NEW TETS
                tet_new = vids_46(local_tets);
                
                %EVALUATE THE ERROR
                [real_vote,flip] = ...
                  isometry_flip_energy_tet(4,tet_old,4,tet_new,xs_hyb);
                if(flip && ~isnan(real_vote) && isreal(real_vote));
                    flip1=true; vote1=real_vote;
                end;
            end;
            
            %SECOND CONFIGURATION.Use edge v3-v5
            if valid_35
                %THE NEW TETS
                tet_new = vids_35(local_tets);
                
                %EVALUATE THE ERROR
                [real_vote,flip] = ...
                  isometry_flip_energy_tet(4,tet_old,4,tet_new,xs_hyb);
                if(flip && ~isnan(real_vote) && isreal(real_vote));
                    flip2=true; vote2=real_vote;
                end;
            end
            
            %FLIP THE BETTER OF THE TWO CONFIGURATIONS
            if(flip1 || flip2)
                common1(1)=iface;
                common2(1)=oppnode(lvid_1ring(1));
                
                common1(2)=neighborhood1(oppnode(lvid_1ring(1)),2);
                common2(2)=oppnode(lvid_1ring(2));
                
                common1(3)=hfid2lfid(reg_opphfs(elems_1ring(2),...
                  oppnode(lvid_1ring(2))));%
                common2(3)=oppnode(lvid_1ring(3));
                
                common1(4)=hfid2lfid(reg_opphfs(elems_1ring(3),...
                  oppnode(lvid_1ring(3))));
                common2(4)=neighborhood1(iface,2);%
                
                if flip1 && flip2
                    if vote1>vote2; flip2=false; else flip1=false; end
                end
            else
                continue;
            end
            
            if flip1
                %THE MTET ARRAY HOLDS THE NEW CONNECTIONS
                tet_new = vids_46(local_tets);
                
                [elems_buf,elems_offsets,reg_opphfs,visited]=...
                    fliphybnxm(4,4,elems_1ring,elems_buf,elems_offsets,...
                    reg_opphfs,isort,common1,common2,tet_new,tempsort,...
                    itemp,visited);
                
                nflips=nflips+1;
                breakout=true; break;
            elseif flip2
                %THE MTET ARRAY HOLDS THE NEW CONNECTIONS
                tet_new = vids_35(local_tets);
                
                [elems_buf,elems_offsets,reg_opphfs,visited]=...
                    fliphybnxm(4,4,elems_1ring,elems_buf,elems_offsets,...
                    reg_opphfs,isort,common1,common2,tet_new,tempsort,...
                    itemp,visited);
                
                nflips=nflips+1;
                breakout=true; break;
            end
        end
        
        if(breakout);break;end
    end
end

return;
end

function b = positive_tets( vids, xs)
% Check whether the configuration of the give six vertices
% form four valid tets
local_tets = int32([1 2 3 4; 1 2 4 5; 1 2 5 6; 1 2 6 3]);

b = true;
for i=1:4
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

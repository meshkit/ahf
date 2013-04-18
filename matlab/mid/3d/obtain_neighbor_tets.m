function ngbtets = obtain_neighbor_tets(cid,mesh)
% For every cell, obtain neighbor cells
n_ngbtets=0;
ngbtets=zeros(4,1);
for lfid = 1 : 4
    %hfid = clfids2hfid(cid, lfid);
    oppfid = mesh.opphfs(cid, lfid);
    if oppfid~=0
        n_ngbtets=n_ngbtets+1;
        ngbtets(n_ngbtets,1)=hfid2cid(oppfid);
    end
end
ngbtets(n_ngbtets+1:end)=[];

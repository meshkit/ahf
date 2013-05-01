function ngbtets = obtain_neighbor_tets(cid,sibhfs)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,4])}
% For every cell, obtain neighbor cells
n_ngbtets=0;
ngbtets=zeros(4,1);
coder.varsize('ngbtets',4);
for lfid = 1 : 4
    oppfid = sibhfs(cid, lfid);
    if oppfid~=0
        n_ngbtets=n_ngbtets+1;
        ngbtets(n_ngbtets,1)=hfid2cid(oppfid);
    end
end
ngbtets(n_ngbtets+1:end)=[];

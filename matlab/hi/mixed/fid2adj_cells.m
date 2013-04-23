function [clist,etags]=fid2adj_cells(fid,mesh,etags)

[hf, etags] = f2hf(fid,mesh.faces,mesh.tets,mesh.sibhfs, mesh.v2hf, etags);
hf_opp=mesh.sibhfs(hfid2cid(hf),hfid2lfid(hf));

if (hf_opp>0)
    clist=[hfid2cid(hf);hfid2cid(hf_opp)];
else
    clist(1,1)=hfid2cid(hf);
end


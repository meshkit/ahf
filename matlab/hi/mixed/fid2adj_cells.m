function [clist,etags]=fid2adj_cells(fid,faces,tets,sibhfs, v2hf, etags)

[hf, etags] = f2hf(fid,faces,tets,sibhfs,v2hf, etags);
hf_opp=mesh.sibhfs(hfid2cid(hf),hfid2lfid(hf));

if (hf_opp>0)
    clist=[hfid2cid(hf);hfid2cid(hf_opp)];
else
    clist(1,1)=hfid2cid(hf);
end


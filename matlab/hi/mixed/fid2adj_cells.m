function [clist,etags]=fid2adj_cells(fid,faces,tets,sibhfs, v2hf, etags)

[fid, lfid, etags] = f2hf(fid,faces,tets,sibhfs,v2hf, etags);
if fid==0
    clist=0;
    return;
end

hf_opp=sibhfs(fid,lfid);

if (hf_opp>0)
    clist=[fid;hfid2cid(hf_opp)];
else
    clist(1,1)=fid;
end


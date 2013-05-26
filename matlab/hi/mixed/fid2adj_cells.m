function [clist,etags]=fid2adj_cells(fid,faces,tets,sibhfs, v2hf, etags)

if ~isstruct(sibhfs)
    [fid, lfid, etags] = f2hf(fid,faces,tets,sibhfs,v2hf, etags);
else
    [fid, lfid, etags] = f2hf(fid,faces,tets,sibhfs,v2hf, etags, true);
end
if fid==0
    clist=int32(0);
    return;
end
if ~isstruct(sibhfs)
    hf_opp=sibhfs(fid,lfid);
    
    if (hf_opp>0)
        clist=[fid;hfid2cid(hf_opp)];
    else
        clist=fid;
    end
else
    fid2=sibhfs.cid(fid,lfid);
    
    if (fid2>0)
        clist=[fid;fid2];
    else
        clist=fid;
    end    
end

function [manifold,flist, nfaces] = check_he_manifold(he,sibhes,flist,nfaces)
manifold = false;

if isstruct(sibhes); type_struct = true; else  type_struct = false; end

if type_struct
    fid=he.fid; lid=he.leid;
else
    fid=heid2fid(he); lid=heid2leid(he);
end
if type_struct
    sibhe.fid=sibhes.fid(fid,lid); sibhe.leid=sibhes.leid(fid,lid);
    if (sibhe.fid ==0)
        manifold = true; flist(1,1) = int32(fid);nfaces = int32(1);
    else
        sib_sibhe.fid = sibhes.fid(sibhe.fid, sibhe.lid);
        if (sib_sibhe.fid == fid)
            manifold = true;
            flist(1,1) = int32(fid);
            flist(2,1) = int32(sibhe.fid);
            nfaces = int32(2);
        end
    end
else
    sibhe=sibhes(fid,lid);
    sibhe_fid = heid2fid(sibhe);sibhe_lid = heid2leid(sibhe);
    if (sibhe_fid ==0)
        manifold = true; flist(1,1) = int32(fid);nfaces = int32(1);
    else
        sib_sibhe = sibhes(sibhe_fid, sibhe_lid);
        sib_sibhe_fid = heid2fid(sib_sibhe);
        if (sib_sibhe_fid == fid)
            manifold = true;
            flist(1,1) = int32(fid);
            flist(2,1) = int32(sibhe_fid);
            nfaces = int32(2);
        end
    end
end



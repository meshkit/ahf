function [success,heid] = obtain_1ring_surf_he_manifold(vid, second_vid, elems, sibhes, v2he, flist, nfaces) %#codegen
success = false;
type_struct = false;
if isstruct(sibhes)
    type_struct = true;
end
if type_struct
    heid.fid = int32(0); heid.lid = int32(0);
else
    heid=int32(0);
end

if type_struct
    fid = v2he.fid(vid); lid = v2he.lid(vid);
else
    fid = heid2fid(v2he(vid)); lid = heid2leid(v2he(vid));
end

if ~fid; return; end;

if type_struct
    if sibhes.fid(fid,lid); fid_in = fid; else fid_in = int32(0); end
else
    if sibhes(fid, lid); fid_in = fid; else fid_in = int32(0); end
end

prv = int32([3 1 2]);
edg_map = int32([1 2; 2 3; 3 1]);

ledg_endpnts = elems(fid,edg_map(lid,:));
if (ledg_endpnts(2) == second_vid)
    if type_struct
        heid.fid = fid; heid.lid = lid; success = true; return
    else
        heid = int32(4*fid+lid-1); success = true; return
    end
else
    % Rotate in counter-clockwise order.
    while 1
        lid_prv = prv(lid);
        if type_struct
            opp.fid = sibhes.fid(fid,lid_prv); opp.lid = sibhes.lid(fid,lid_prv);
            ledg_endpnts = elems(opp.fid,edg_map(opp.lid,:));
            if (ledg_endpnts(2) == second_vid)
                heid.fid = fid; heid.lid = lid; success = true;break
            end
            manifold = check_he_manifold(opp,sibhes);
            if ~manifold
                break
            end
            
        else
            opp = sibhes(fid, lid_prv);
            fid = heid2fid(opp); lid = heid2leid(opp);
            ledg_endpnts = elems(fid,edg_map(lid,:));
            if (ledg_endpnts(2) == second_vid)
                heid = opp; success = true; break
            end
            manifold = check_he_manifold(opp,sibhes,flist,nfaces);
            if ~manifold
                break
            end
        end
        
        if fid == fid_in % Finished cycle
            break;
        end
    end   
end

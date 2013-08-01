function [success,heid] = obtain_1ring_surf_he_manifold(vid, second_vid, elems, sibhes, v2he) %#codegen
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
            if (opp.fid==0)
                break
            end
            ledg_endpnts = elems(opp.fid,edg_map(opp.lid,:));
            if collinear_edges(vid,second_vid,ledg_endpnts)
                heid.fid = fid; heid.lid = lid; success = true;break
            end
                      
            oppopp.fid = sibhes.fid(opp.fid,opp.lid); oppopp.lid = sibhes.lid(opp.fid,opp.lid);
            manifold = (oppopp.fid==fid)&&(oppopp.lid==lid);
            
            if ~manifold
                break
            end
            fid = opp.fid;
            lid = opp.lid;
        else
            opp = sibhes(fid, lid_prv);
            if (heid2fid(opp)==0); break; end;
            ledg_endpnts = elems(heid2fid(opp),edg_map(heid2leid(opp),:));
            if collinear_edges(vid,second_vid,ledg_endpnts)
                heid = opp; success = true; break
            end
            
            oppopp = sibhes(heid2fid(opp),heid2leid(opp)); 
            manifold = (heid2fid(oppopp)==fid)&&(heid2leid(oppopp)==lid);
                        
            if ~manifold
                break
            end
            fid = heid2fid(opp); lid = heid2leid(opp);
        end
        
        if fid == fid_in % Finished cycle
            break;
        end
    end
end
end


function match = collinear_edges(first_vid,second_vid,ledg_endpnts)
same_orientation=(first_vid==ledg_endpnts(1))&&(second_vid==ledg_endpnts(2));
opposite_orientation=(first_vid==ledg_endpnts(2))&&(second_vid==ledg_endpnts(1));
match=same_orientation||opposite_orientation;
end
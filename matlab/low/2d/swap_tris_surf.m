function [tris, opphes, v2he] = swap_tris_surf( fid1, fid2, tris, opphes, v2he) %#codegen 
%SWAP_TRIS_SURF    Swap two faces in a triangle mesh.
%   [tris, opphes, v2he] = SWAP_TRIS_SURF( FID1, FID2, TRIS, OPPHES, V2HE)
%       swaps two triangles in connecitivity table.
%

if fid1==fid2; return; end

% modify opposite edges if neccessary
for i=1:3
    opp = opphes(fid1,i);
    if opp
        fid_tmp = heid2fid(opp); lid_tmp = heid2leid(opp);
        if (opphes(fid_tmp,lid_tmp) == 4*fid1+i-1)
            opphes(fid_tmp,lid_tmp) = 4*fid2+i-1;
        end
    end
    
    if tris(fid1,i)>0 && (v2he(tris(fid1,i)) == 4*fid1+i-1)
        v2he(tris(fid1,i)) = 4*fid2+i-1;
    end
end

for i=1:3
    opp = opphes(fid2,i);
    if opp
        fid_tmp = heid2fid(opp); lid_tmp = heid2leid(opp);
        if (opphes(fid_tmp,lid_tmp) == 4*fid2+i-1)
            opphes(fid_tmp,lid_tmp) = 4*fid1+i-1;
        end
    end
    
    if tris(fid2,i)>0  && (v2he(tris(fid2,i)) == 4*fid2+i-1)
        v2he(tris(fid2,i)) = 4*fid1+i-1;
    end
end

% modify tris
tri_tmp = tris(fid1,1:3);
tris(fid1,1:3) = tris(fid2,1:3);
tris(fid2,1:3) = tri_tmp;

opphes_tmp = opphes(fid1,1:3);
opphes(fid1,1:3) = opphes(fid2,1:3);
opphes(fid2,1:3) = opphes_tmp;

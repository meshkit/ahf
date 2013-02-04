function [nv, nf, tris, opphes, v2he] = split_face_surf(fid, nv, nf, ...
    tris, opphes, v2he) %#codegen 
%SPLIT_FACE_SURF    Split a face and insert a new vertex into it.
%   SPLIT_FACE_SURF(FID, NV, NF, TRIS, OPPHES, V2HE) splits triangle FID into
%   three triangles by inserting a vertex into it and updates the connectivity
%   accordingly. The new vertex is appended to the end with ID NV+1, and
%   two new triangles are appended to the end of TRIS with IDs NE+1 and NE+2.
%   TRIS and OPPHES must be size Mx2 with M>NE+1, and V2HE is Nx1 with N>NV.

assert( size(tris,1)>nf+1 && size(opphes,1)>nf+1);
assert( size(v2he,1)>nv);

nv = nv + 1;
nf = nf + 2;

% Insert two new triangles at the end
tris(nf-1, :) = [nv, tris(fid, 2), tris(fid, 3)];
tris(nf, :) = [nv, tris(fid, 3), tris(fid, 1)];
tris(fid, 3) = nv;

% Update incident half-edges (v2he).
v2he(nv) = 4*fid + 2;


% Update opposite half-edges (opphes)

% Save information before making changes
heid_fv = opphes(fid,2);
fid_fv =  heid2fid(heid_fv); lid_fv = heid2leid(heid_fv);

heid_sx = opphes(fid,3);
fid_sx =  heid2fid(heid_sx); lid_sx = heid2leid(heid_sx);

% fid_sx <=> nf
if (heid_sx)
    opphes(fid_sx, lid_sx) = 4*nf + 1;
end
opphes(nf,2) = heid_sx;

% fid_fv <=> nf-1
if (heid_fv)
    opphes(fid_fv, lid_fv) = 4*(nf-1) + 1;
end
opphes(nf-1,2) = heid_fv;

% nf-1 <=> fid
opphes(nf-1,1) = fid*4 + 1;
opphes(fid,2) = 4*(nf-1);

% fid <=> nf
opphes(fid,3) = 4*nf + 2;
opphes(nf,3) = 4*fid + 2;

% nf <=> nf-1
opphes(nf,1) = 4*(nf-1) + 2;
opphes(nf-1,3) = 4*nf;


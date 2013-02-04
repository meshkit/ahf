function [ngbvs, nverts, ngbes, nfaces] = obtain_1ring_surf( vid, ...
    tris, opphes, v2he, ngbvs, ngbes) %#codegen
%OBTAIN_1RING_SURF Collect 1-ring neighbor vertices.
% [NGBVS,NVERTS,NGBES,NFACES] = OBTAIN_1RING_SURF(VID,TRIS,OPPHES,V2HE, ...
% NGBVS,NGBES) Collects 1-ring neighbor vertices of a vertex and saves them 
% into NGBVS.
% 
% See also OBTAIN_1RING_CURV, OBTAIN_1RING_VOL

vtags = false(0,1); etags = false(0,1);
if nargout > 2
    [ngbvs, nverts, vtags, etags, ngbes, nfaces] = obtain_nring_surf...
        ( vid, 1, int32(0), tris, opphes, v2he, ngbvs, vtags, etags, ngbes); %#ok<ASGLU>
else
    [ngbvs, nverts] = obtain_nring_surf( vid, 1, int32(0), tris, opphes, v2he, ngbvs);
end

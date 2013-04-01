function [ngbvs, nverts] = obtain_1ring_curv_NM...
    ( vid, edges, sibhvs, v2hv) %#codegen 
%OBTAIN_1RING_CURV Collect 1-ring vertices on non-manifold mesh.
% [NGBVS,NVERTS] = OBTAIN_1RING_CURV_NM(VID,EDGS,SIBHVS,V2HV) Collects 1-ring 
% vertices and edges of a vertex and saves them into NGBVS and NGBES. 
%
% See also OBTAIN_1RING_SURF, OBTAIN_1RING_VOL

assert( isa(vid, 'int32') && isa( edges, 'int32') && ...
    isa( sibhvs, 'int32') && isa( v2hv,'int32'));

eid = hvid2eid(v2hv(vid));
lid = hvid2lvid(v2hv(vid));

MAXVALENCE=10;
ngbvs = zeros(MAXVALENCE,1,'int32');
nverts = int32(0);

if ~eid; return; end

% Collect one-ring vertices and edges
v = edges(eid, 3-lid); % another end of the edge
nverts = int32(1); ngbvs( nverts) = v;

opp = sibhvs(eid, lid);
while opp && opp~=v2hv(vid)
    if (nverts==MAXVALENCE); warning('MATLAB:MAXVALENCE','vertex %d valence exceeds MAXVALENCE=%d',vid,MAXVALENCE); end;
    eid = hvid2eid(opp); lid = hvid2lvid(opp);  

    v = edges(eid, 3-lid); nverts = nverts+1; ngbvs( nverts) = v;
    
    % Next edge
    opp = sibhvs(eid, lid);
end
function [ngbvs, nverts] = obtain_1ring_curv...
    ( vid, edgs, opphvs, v2hv) %#codegen 
%OBTAIN_1RING_CURV Collect 1-ring vertices and edges.
% [NGBVS,NVERTS] = OBTAIN_1RING_CURV(VID,EDGS,OPPHVS,V2HV) Collects 1-ring 
% vertices and edges of a vertex and saves them into NGBVS and NGBES. 
%
% See also OBTAIN_1RING_SURF, OBTAIN_1RING_VOL

assert( isa(vid, 'int32') && isa( edgs, 'int32') && ...
    isa( opphvs, 'int32') && isa( v2hv,'int32'));

eid = hvid2eid(v2hv(vid));
lid = hvid2lvid(v2hv(vid));

ngbvs = int32([0;0]);
nverts = int32(0);

if ~eid; return; end

% Collect one-ring vertices and edges
v = edgs(eid, 3-lid);
nverts = int32(1); ngbvs( nverts) = v;

opp = opphvs(eid, lid);
if opp
    eid = hvid2eid(opp); lid = hvid2lvid(opp);

    v = edgs(eid, 3-lid); nverts = int32(2); ngbvs( nverts) = v;
end

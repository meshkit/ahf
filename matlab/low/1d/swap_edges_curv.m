function [edgs, sibhvs, v2hv] = swap_edges_curv( eid1, eid2, ...
    edgs, sibhvs, v2hv) %#codegen 
%SWAP_EDGES_CURV    Swap two edges in a curve.
%   [edgs, sibhvs, v2hv] = ...
%   SWAP_EDGES_CURV( EID1, EID2, EDGS, SIBHVS, V2HV) swaps two edges
%       in connecitivity table.
%

if eid1==eid2; return; end

% Swap vertices in edgs
vids = edgs(eid1,1:2);
edgs(eid1,1:2) = edgs(eid2,1:2);
edgs(eid2,1:2) = vids;

% Swap opposite half-vertices in sibhvs
hvs = sibhvs(eid1,1:2);
sibhvs(eid1,1:2) = sibhvs(eid2,1:2);
sibhvs(eid2,1:2) = hvs;

% Update opposite half-vertices in sibhvs
if edgs(eid1,1) && sibhvs(eid1,1)
    sibhvs(hvid2eid(sibhvs(eid1,1)),hvid2lvid(sibhvs(eid1,1))) = 2*eid1;
end
if edgs(eid1,2) && sibhvs(eid1,2)
    sibhvs(hvid2eid(sibhvs(eid1,2)),hvid2lvid(sibhvs(eid1,2))) = 2*eid1+1;
end

if edgs(eid2,1) && sibhvs(eid2,1)
    sibhvs(hvid2eid(sibhvs(eid2,1)),hvid2lvid(sibhvs(eid2,1))) = 2*eid2;
end
if edgs(eid2,2) && sibhvs(eid2,2)
    sibhvs(hvid2eid(sibhvs(eid2,2)),hvid2lvid(sibhvs(eid2,2))) = 2*eid2+1;
end

% Update incident half-vertices in v2hv
if edgs(eid1,1) && hvid2eid(v2hv(edgs(eid1,1)))==eid2
    v2hv(edgs(eid1,1)) = 2*eid1;
end

if edgs(eid1,2) && hvid2eid(v2hv(edgs(eid1,2)))==eid2
    v2hv(edgs(eid1,2)) = 2*eid1+1;
end

if edgs(eid2,1) && hvid2eid(v2hv(edgs(eid2,1)))==eid1
    v2hv(edgs(eid2,1)) = 2*eid2;
end

if edgs(eid2,2) && hvid2eid(v2hv(edgs(eid2,2)))==eid1
    v2hv(edgs(eid2,2)) = 2*eid2+1;
end

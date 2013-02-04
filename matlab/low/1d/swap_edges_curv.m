function [edgs, opphvs, v2hv] = swap_edges_curv( eid1, eid2, ...
    edgs, opphvs, v2hv) %#codegen 
%SWAP_EDGES_CURV    Swap two edges in a curve.
%   [edgs, opphvs, v2hv] = ...
%   SWAP_EDGES_CURV( EID1, EID2, EDGS, OPPHVS, V2HV) swaps two edges
%       in connecitivity table.
%

if eid1==eid2; return; end

% Swap vertices in edgs
vids = edgs(eid1,1:2);
edgs(eid1,1:2) = edgs(eid2,1:2);
edgs(eid2,1:2) = vids;

% Swap opposite half-vertices in opphvs
hvs = opphvs(eid1,1:2);
opphvs(eid1,1:2) = opphvs(eid2,1:2);
opphvs(eid2,1:2) = hvs;

% Update opposite half-vertices in opphvs
if edgs(eid1,1) && opphvs(eid1,1)
    opphvs(hvid2eid(opphvs(eid1,1)),hvid2lvid(opphvs(eid1,1))) = 2*eid1;
end
if edgs(eid1,2) && opphvs(eid1,2)
    opphvs(hvid2eid(opphvs(eid1,2)),hvid2lvid(opphvs(eid1,2))) = 2*eid1+1;
end

if edgs(eid2,1) && opphvs(eid2,1)
    opphvs(hvid2eid(opphvs(eid2,1)),hvid2lvid(opphvs(eid2,1))) = 2*eid2;
end
if edgs(eid2,2) && opphvs(eid2,2)
    opphvs(hvid2eid(opphvs(eid2,2)),hvid2lvid(opphvs(eid2,2))) = 2*eid2+1;
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

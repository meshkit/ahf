function [nv, ne, edgs, opphvs, v2hv] = split_edge_curv(eid, nv, ne, ...
    edgs, opphvs, v2hv) %#codegen 
%SPLIT_EDGE_CURV   Split an edge and insert a new vertex.
%   SPLIT_EDGE_CURV(EID, NV, NE, EDGS, OPPHVS, V2HV) splits edge EID into
%   two edges by inserting a vertex into it and updates the connectivity
%   accordingly. The new vertex is appended to the end with ID NV+1, and
%   the new edge with vertices (NV+1,EDGS(EID,2)) is appended to the end 
%   of EDGS with ID NE+1. EDGS and OPPHVS must be size Mx2, where M>NE, 
%   and V2HV is Nx1, where N>NV.

assert( size(edgs,1)>ne && size(opphvs,1)>ne);
assert( size(v2hv,1)>nv);

nv = nv + 1;
ne = ne + 1;

% Insert a new edge to the end of connectivity table.
trg = edgs( eid, 2);
edgs(ne,:) = [nv, trg];
edgs(eid,2) = nv;

% Update opposite half-vertices (opphvs).
opp = opphvs(eid,2);
opphvs(eid,2) = 2*ne;
opphvs(ne,1)  = 2*eid+1;

opphvs(ne,2) = opp;
if opp
    opphvs(hvid2eid(opp),hvid2lvid(opp)) = 2*ne+1;
end

% Update incident half-vertices (v2hv).
v2hv(nv) = opphvs(ne,1);
if v2hv(trg)==opphvs(ne,1); v2hv(trg) = 2*ne+1; end

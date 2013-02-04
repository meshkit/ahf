function [nv, ne, edgs, opphvs, v2hv, vvs, evs] = contract_edge_curv(eid, nv, ne, ...
    edgs, opphvs, v2hv, vvs, evs) %#codegen 
%CONTRACT_EDGE_CURV   Contract an edge and delete its origin vertex.
%   [NV, NE, EDGS, OPPHVS, V2HV, VVS, EVS] = ...
%   CONTRACT_EDGE_CURV(EID, NV, NE, EDGS, OPPHVS, V2HV, VVS, EVS) contracts edge
%   EID, removes its origin vertex, and updates the connectivity accordingly. 
%   If there is only one edge in an open curve or less than four edges in a
%   closed curve, then the vertices and edges of the whole curve will be removed. 
%   Caller can determine whether a curve is removed by checking whether nv 
%   is decreased by more than 1 before and after edge contration.
%   After removing some vertices and edges, those at the back of arrays 
%   are swapped to the position to avoid gaps. 
%   VVS contains the data associated with vertices and EVS contains data
%   associated with the edges. If present, these arrays will be updated.

if ~eid; return; end

prev_eid = hvid2eid(opphvs(eid,1)); prev_lid = hvid2lvid(opphvs(eid,1));
next_eid = hvid2eid(opphvs(eid,2)); next_lid = hvid2lvid(opphvs(eid,2));

% Open curve with a single edge
if ~opphvs(eid,1) && ~opphvs(eid,2) 
%TODO: Implement this branch
    assert(false);
elseif prev_eid == next_eid
    % Closed curve with only two edges
%TODO: Implement this branch
    assert(false);    
elseif edgs(hvid2eid(opphvs(eid,1)), 3-hvid2lvid(opphvs(eid,1))) == ...
        edgs(hvid2eid(opphvs(eid,2)), 3-hvid2lvid(opphvs(eid,2)))
    % Closed curve with only three edges
%TODO: Implement this branch
    assert(false);
else
%TODO: Debug this branch
    org = edgs(eid,1);
    % Swap origin of vertex with last vertex.
    [edgs, opphvs, v2hv] = swap_vertices_curv(org, nv, edgs, opphvs, v2hv);
    if nargin>6
        for ii=1:int32(size(vvs,2))
            t = vvs(nv,ii); vvs(nv,ii) = vvs(org,ii); vvs(org,ii) = t;
        end
    end
    % Swap edge eid with last edge.
    [edgs, opphvs, v2hv] = swap_edges_curv(eid, ne, edgs, opphvs, v2hv);
    if nargin>7
        for ii=1:int32(size(evs,2))
            t = evs(ne,ii); evs(ne,ii) = evs(eid,ii); evs(eid,ii) = t;
        end
    end
    
    % Remove last edge
    edgs( prev_eid, prev_lid) = edgs( ne, 2);
    opphvs(prev_eid, prev_lid) = 2*next_eid + next_lid-1;
    opphvs(next_eid, next_lid) = 2*prev_eid + prev_lid-1;
    
    if hvid2eid(v2hv( ne)) == ne
        v2hv( ne, 2) = 2*prev_eid + prev_lid-1;
    end
    ne = ne - 1;
    nv = nv - 1;
end

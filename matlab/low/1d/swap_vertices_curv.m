function [edgs, opphvs, v2hv] = swap_vertices_curv( vid1, vid2, edgs, opphvs, v2hv) %#codegen 
%SWAP_VERTICES_CURV    Swap two vertices in a curve.
%   [edgs, opphvs, v2hv] = ...
%   SWAP_VERTICES_CURV( VID1, VID2, EDGS, OPPHVS, V2HV) swaps two vertices
%       in connecitivity table.

% TODO: Debug this function.

if vid1==vid2; return; end

% Update edgs
if v2vh(vid1)
    eid = hvid2eid(v2vh( vid1)); lid = hvid2lvid(v2vh( vid1));
    edgs( eid, lid) = vid2;
    opp = opphvs( eid, lid);
    if opp
        edgs( hvid2eid(opp), hvid2lvid(opp)) = vid2;
    end
end

if v2vh(vid2)
    eid = hvid2eid(v2vh( vid2)); lid = hvid2lvid(v2vh( vid2));
    edgs( eid, lid) = vid1;
    opp = opphvs( eid, lid);
    if opp
        edgs( hvid2eid(opp), hvid2lvid(opp)) = vid1;
    end
end

% Swap v2hv
hv = v2hv(vid1);
v2hv(vid1) = v2hv(vid2);
v2hv(vid2) = hv;

function [nv, ne, edgs, sibhvs, v2hv, vvs, evs] = merge_curv(vid1, vid2, nv, ne, ...
    edgs, sibhvs, v2hv, vvs, evs) %#codegen 
%MERGE_CURV    Merge curves locally.
%   [NV, NE, EDGS, SIBHVS, V2HV, VVS, EVS] = ....
%   MERGE_CURV(HVID1, HVID2, NV, NE, EDGS, SIBHVS, V2HV, VVS, EVS)
%   merges curves locally at vertices specified by vid1 and vid2.
%   It removes the two vertices and merges the adjacent vertices on 
%   each side. After removing vertices and edges, those at the back 
%   of arrays are swapped to the positions of the removed vertices 
%   and edges to avoid gaps.
%   VVS contains the data associated with vertices and EVS contains data
%   associated with the edges. If present, these arrays will be updated.
%
%   Before calling this operation, the 1-ring neighborhood of vid1 and vid2
%   should have been zipped together to improve accuracy.
%   Note that after this operation, the IDs for some vertices, faces, and
%   edges may change.

assert( vid1~=id2);

%% Swap adjacent edges of vid1 and vid2 to the end
eid1 = incident_edge( vid1, v2hv);
if hvid2lvid(v2hv(vid1))==1; eid1 = prev_edge( eid1); end

eid2 = incident_edge( vid2, v2hv);
if hvid2lvid(v2hv(vid2))==1; eid2 = prev_edge( eid2); end

% We require at least 6 vertices to resolve a loop properly.
MAXDIST = 6+2;
% Check whether the distance from vid1 to vid2 is shorter than MAXDIST edges
d1 = distance( eid1, eid2, sibhvs, MAXDIST);
d2 = distance( eid2, eid1, sibhvs, MAXDIST);

if d1 <= MAXDIST || d2 <= MAXDIST
    if d1<= MAXDIST && d2 <= MAXDIST
        % Delete the whole curve
        eid = eid1; eid_last = 0;
    elseif d1<= MAXDIST 
        % Delete edges between eid1 and eid2
        %         ep1  eid1   en1   enn1
        %            vp1 ->vid1 -> vn1
        %
        %        _____o_____o_____o_____            ____
        %                                   ==>         \o
        %        _____o_____o_____o_____            ____/
        %           vn2 <-vid2 <- vp2                  vn2
        eid = eid1;
        eid_last = next_edge(eid2, sibhvs);
        
        vbuf = vvs(edgs(eid,1),:) + vvs(edgs(eid_last,2),:);
        vvs( edgs(eid_last,2),:) = 0.5*vbuf;
    else
        % Delete edges between eid2 and eid1,
        % Symmetric case of the above.
        eid = eid2;
        eid_last = next_edge(eid1, sibhvs);
        
        vbuf = vvs(edgs(eid,1),:) + vvs(edgs(eid_last,2),:);
        vvs( edgs(eid_last,2),:) = 0.5*vbuf;
    end
    
    while eid ~= eid_last
        eid_next = next_edge( eid);
        if eid_next==ne; eid_next = eid; end  % Prepare for swapping
        if eid_last==ne; eid_last = eid; end

        nv_old = nv;
        [nv, ne, edgs, sibhvs, v2hv, vvs, evs] = contract_edge_curv(eid, nv, ne, ...
            edgs, sibhvs, v2hv, vvs, evs);
        
        % If the connected component is removed, then stop.
        if nv<nv_old-1; return; end
        eid = eid_next;
        d = d-1;
    end
    return;
end

%% Perform actual topological change.
%
%         ep1  eid1   en1   enn1
%            vp1 ->vid1 -> vn1                             vn1
%
%        _____o_____o_____o_____            ____              _____
%                                   ==>         \o          o/
%        _____o_____o_____o_____            ____/            \_____
%           vn2 <-vid2 <- vp2                  vn2
%         enn2  en2   eid2   ep2

%% Swap vid1 and vid2 to the end
if vid1~=nv || vid2~=nv-1
    [edgs, sibhvs, v2hv] = swap_vertices_curv( vid1, nv-1, edgs, sibhvs, v2hv);
    vvs(vid1,:) = vvs(nv-1,:);
    [edgs, sibhvs, v2hv] = swap_vertices_curv( vid2, nv, edgs, sibhvs, v2hv);
    vvs(vid2,:) = vvs(nv,:);
end

if edgs(eid1,1)~=nv-2 || edgs(eid2,1) ~= nv-3
    vp1 = edgs(eid1,1);
    [edgs, sibhvs, v2hv] = swap_vertices_curv( vp1, nv-3, edgs, sibhvs, v2hv);
    vvs(vp1,:) = vvs(nv-3,:);
    
    vp2 = edgs(eid1,1);
    [edgs, sibhvs, v2hv] = swap_vertices_curv( vp2, nv-2, edgs, sibhvs, v2hv);
    vvs(vp2,:) = vvs(nv-2,:);
end

%% Swap eid1 and eid2 to end of edge list.
if eid1~=ne || eid2~=ne-1
    [edgs, sibhvs, v2hv] = swap_edges_curv( eid1, ne-1, edgs, sibhvs, v2hv);
    evs(eid1,:) = evs(ne-1,:); eid1 = ne-1;

    [edgs, sibhvs, v2hv] = swap_edges_curv( eid2, ne, edgs, sibhvs, v2hv);
    evs(eid2,:) = evs(ne,:);   eid2 = ne;
end

% Swap adjacent vertices to the end
en1 = next_edge( eid1, sibhvs); en2 = next_edge( eid2, sibhvs);

vbuf = vvs(edgs(eid2,1),:) + vvs(edgs(en1, 2),:);
vvs( edgs(en1, 2),:) = 0.5*vbuf;

vbuf = vvs(edgs(eid1,1),:) + vvs(edgs(en2, 2),:); 
vvs( edgs(en2, 2),:) = 0.5*vbuf;

% Swap indirectly connected edges to the end
if en1~=ne-2 || en2 ~= ne-3
    % Swap en1 to end of edge list.
    [edgs, sibhvs, v2hv] = swap_edges_curv( en1, ne-3, edgs, sibhvs, v2hv);
    evs(en1,:) = evs(ne-3,:); en1 = ne-3;

    % Swap en2 to end of edge list.
    [edgs, sibhvs, v2hv] = swap_edges_curv( en2, ne-2, edgs, sibhvs, v2hv);
    evs(en2,:) = evs(ne-2,:); en2 = ne-2;
end

%% Update edgs, sibhvs, and v2hv
ep1 = prev_edge( eid1, sibhvs); ep2 = prev_edge( eid2, sibhvs);
enn1 = next_edge( en1, sibhvs); enn2 = next_edge( en2, sibhvs);

edgs(ep1, 2)=edgs(enn2, 1); sibhvs(ep1, 2)=2*enn2; sibhvs(enn2, 1)=2*ep1+1;
edgs(ep2, 2)=edgs(enn1, 1); sibhvs(ep2, 2)=2*enn1; sibhvs(enn1, 1)=2*ep2+1;

v2hv(edgs(enn1,1)) = 2*enn1; v2hv(edgs(enn2,1)) = 2*enn2;

ne = ne - 4; nv = nv - 4;


function eid = incident_edge( vid, v2hv)
eid = hvid2eid(v2hv(vid));

function eid = prev_edge( eid, sibhvs)
eid = hvid2eid(sibhvs( eid, 1));

function eid = next_edge( eid, sibhvs)
eid = hvid2eid(sibhvs( eid, 2));

function d = distance( eid1, eid2, sibhvs, maxd)
% Count the number of edges between edges eid1 and eid2.
% Count up to maxd.
d = 0;
eid = eid1;

while d<=maxd && eid~=eid2; 
    opp = sibhvs( eid, 2);
    % Check whether the curve is open.
    if ~opp; return; end
    
    eid = hvid2eid(opp);
    d = d+1; 
end

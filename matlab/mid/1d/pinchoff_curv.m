function [nv, ne, edgs, sibhvs, v2hv, vvs] = pinchoff_curv(vid1, vid2, nv, ne, ...
    edgs, sibhvs, v2hv, vvs) %#codegen 
%PINCHOFF_CURV    Pinch-off a curve locally.
%   [NV, NE, EDGS, SIBHVS, V2HV, VVS] = ....
%   PINCHOFF_CURV(HVID1, HVID2, NV, NE, EDGS, SIBHVS, V2HV, VVS)
%   pinches off a curve locally at vertices specified by vid1 and vid2.
%   It is similar to merge_curv, except that it adds instead of removing 
%   vertices and edges during the operation. It makes a copy of vid1 and
%   vid2 and append them to the end of vertices, and it adds new edges
%   <vid1,vid2> and <copy vid2, copy vid1> and append them to the end
%   of edge list.

%% Precondition: vid1 and vid2 do not share a common edge.
assert(vid1 && vid2 && vid1 ~= vid2);

eid1 = incident_edge( vid1, v2hv);
if hvid2lvid(v2hv(vid1))==1; eid1 = prev_edge( eid1); end

eid2 = incident_edge( vid2, v2hv);
if hvid2lvid(v2hv(vid2))==1; eid2 = prev_edge( eid2); end

assert( eid1 ~= prev_edge(eid2) && eid2 ~= prev_edge(eid1));

%% Precondition: edgs, sibhvs, and v2hv must have enough space.
assert( size(edgs,1)>=ne+2 && size(sibhvs,1)>=ne+2 && size(v2hv,1)>=nv+2);

%% Perform actual topological change.
%
%        _____o_____o_____o_____            _____o_____oo_____o_____
%                                   ==>                ||
%        _____o_____o_____o_____            _____o_____oo_____o_____

% Make a copy of vid1 and vid2
vvs(nv+1,:) = vvs(vid1,:); vvs(nv+2,:) = vvs(vid2,:);

%% Update edgs, sibhvs, and v2hv
en1 = next_edge( eid1, sibhvs);
en2 = next_edge( eid2, sibhvs);

edgs(ne+1,:) = [vid1, vid2]; edgs(ne+2,:) = [nv+1, nv+2];
edgs(en1,1) = nv+1; edgs(en2,2) = nv+2;

sibhvs( eid1,2) = 2*(ne+1);  sibhvs( ne+1,1) = 2*eid1+1;
sibhvs( eid2,2) = 2*(ne+2);  sibhvs( ne+2,1) = 2*eid2+1;

sibhvs( en1, 1) = 2*(ne+2)+1; sibhvs( ne+2,2) = 2*en1;
sibhvs( en2, 1) = 2*(ne+1)+1; sibhvs( ne+1,2) = 2*en2;

v2hv(vid1) = 2*(ne+1);  v2hv(vid2) = 2*(ne+2);
v2hv(nv+1) = 2*en1;     v2hv(nv+2) = 2*en2;

ne = ne + 2; nv = nv + 2;

function eid = prev_edge( eid, sibhvs)
eid = hvid2eid(sibhvs( eid, 1));

function eid = next_edge( eid, sibhvs)
eid = hvid2eid(sibhvs( eid, 2));

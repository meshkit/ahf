function [ngbvs, nverts, vtags, etags, ngbes, nedges] = obtain_nring_curv( vid, ring, minpnts, ...
        edgs, sibhvs, v2hv, ngbvs, vtags, etags, ngbes) %#codegen 
%OBTAIN_NRING_CURV Collect n-ring vertices and edges.
% [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NEDGES] = OBTAIN_NRING_CURV(VID,RING, ...
% MINPNTS,EDGS,SIBHVS,V2HV,NGBVS,VTAGS,ETAGS,NGBES) Collects n-ring 
% vertices and edges of a vertex and saves into NGBVS and NGBES.
%
% See also OBTAIN_NRING_QUAD, OBTAIN_NRING_SURF, OBTAIN_NRING_VOL
MAXRING = 6;
MAXNPNTS = int32(13);

assert( islogical( vtags) && islogical(etags));

eid = hvid2eid(v2hv(vid)); lid = hvid2lvid(v2hv(vid));
nverts=int32(0); nedges=int32(0);

if ~eid; return; end

%% Collect one-ring vertices and edges
if ring>1 || minpnts || nargout>=5
    onering_only = false;
else
    onering_only = true;
end

% hvbuf stores the opposite half-vertex of last inserted vertex.
hvbuf = nullcopy(zeros(MAXNPNTS,1, 'int32'));

% ebuf is buffer space for storing ngbes
ebuf = nullcopy(zeros(MAXNPNTS,1, 'int32'));

% Insert incident vertx into list
v = edgs(eid, 3-lid);
nverts = int32(1); ngbvs( nverts) = v;
if ~onering_only;
    hvbuf(1) = sibhvs( eid, 3-lid);
    ebuf(1) = eid;
end
nedges = int32(1);

opp = sibhvs(eid, lid);
if opp
    eid = hvid2eid(opp); lid = hvid2lvid(opp);

    v = edgs(eid, 3-lid); nverts = int32(2); ngbvs( nverts) = v;
    assert( v ~= ngbvs(1));
    if ~onering_only;
        hvbuf(nverts) = sibhvs(eid, 3-lid);
        ebuf(2) = eid; nedges = int32(2);
    end
end

if ring<=1 && nverts>=minpnts
    if nargout>5; ngbes(1:nedges) = ebuf(1:nedges); end
    return;
end
vtags(vid) = true; vtags(ngbvs(1:nverts))=true;
etags(ebuf(1:nedges))=true;

%% Define buffers and prepare tags for further processing
nverts_pre = int32(0);

% Second, build full-size ring
minpnts = min(minpnts, MAXNPNTS);

cur_ring=int32(1); ring=min(MAXRING,ring);
while 1
    % Collect next level of ring
    nverts_last = nverts; nedges_pre = nedges;

    for ii = nverts_pre+1 : nverts_last
        eid = hvid2eid(hvbuf(ii));

        % If the edge has already been inserted, then the vertex must be
        % inserted already.
        if eid && ~etags(eid)
            % Insert edge into list
            nedges = nedges + 1; ebuf( nedges) = eid; etags(eid)=int32(1);

            lid = hvid2lvid(hvbuf(ii));
            v = edgs(eid, 3-lid);
            if ~vtags(v)
                nverts = nverts + 1; ngbvs( nverts) = v; vtags(v)=int32(1);

                % Insert opposite halfvertex
                hvbuf(nverts) = sibhvs( eid, 3-lid);
            else
                assert( false);
            end
        else
            assert( eid==0);
        end
    end

    cur_ring = cur_ring+1;
    if nverts>=minpnts && cur_ring>=ring || nedges==nedges_pre
        break;
    end

    nverts_pre = nverts_last;
end

% Reset flags
if nargout>5; ngbes(1:nedges)=ebuf(1:nedges); end
vtags(vid) = false; vtags(ngbvs(1:nverts)) = false;
etags(ebuf(1:nedges)) = false;


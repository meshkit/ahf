function buf = obtain_nring_tet( cid, lvid, tets, sibhfs, ring, buf, minpnts) %#codegen
% OBTAIN_NRING_TET collects n-ring neighbor of a vertex in a tetrahedral mesh.
%
%    BUF = OBTAIN_NRING_TET(CID, LVID, TETS, SIDHFS)
%    BUF = OBTAIN_NRING_TET(CID, LVID, TETS, SIDHFS, RING)
%    BUF = OBTAIN_NRING_TET(CID, LVID, TETS, SIDHFS, RING, BUF, MINPNTS)
% collects n-ring neighbor vertices and elements of vertex TETS(CID, LVID)
% and saves them into BUF.
%
% The BUF is a struct with the following variables:
%     nverts: integer scalar, to contain the number of vertices in the n-ring
%             neighborhood (excluding the center vertex itself).
%     ngbvs:  integer column array, where ngbvs(1:nverts) will include the
%             the vertex IDs in the n-ring neighborhood (excluding the center
%             vertex itself). It must be large enough to contain the
%             vertices, or the result will be truncated.
%     vtags:  a logical array of size equal to #vertices.
%
%     nelems: integer scalar, to contain the number of elements in the
%             n-ring neighborhood.
%     ngbes:  integer column array, where ngbes(1:nelems) will include the
%             the element IDs in the n-ring neighborhood. It must be large
%             enough to contain the elements, or the result will be truncated.
%     etags:  a logical array of size equal to #tets.
%
%   At input, BUF.vtags and BUF.etags must be initialized to false.
%             They will be reset to false at output.
%
% The RING is the level of rings in half increments (i.e., 1, 1,5, 2, 2.5,
%      etc.). The default is 1.
% The MINPNTS specifies the minimum number of points to be obtained. If the
%     ring is too small, the function will automatically expand the ring.

if nargin<5; ring = 1; end
if nargin<6;
    nv = max(tets(:));
    buf.nverts = int32(0);
    buf.ngbvs  = nullcopy( zeros(nv, 1, 'int32'));
    buf.vtags  = false( nv,1);
    
    buf.nelems = int32(0);
    buf.ngbes  = nullcopy( zeros(size(tets,1), 1, 'int32'));
    buf.etags  = false( size(tets,1),1);
elseif isempty(coder.target)
    % Check to make sure buf.vtags and buf.etags are initialized to false
    assert( islogical( buf.vtags) && ~any(buf.vtags));
    assert( islogical( buf.etags) && ~any(buf.etags));
end
if nargin<7; minpnts = int32(0); end

buf.nverts=int32(0); buf.nelems=int32(0);
minpnts = min(minpnts, int32(length(buf.ngbvs)));

% Obtain incident halfface of vid.
if ring<=0 && minpnts<=0
    % If finding 0-ring or there is no incident tets, then return.
    return;
end

% Build 1-ring
vid = tets( cid, lvid);
buf.vtags(vid) = true;
buf = append_one_ring( cid, lvid, tets, sibhfs, buf);

% If collected sufficient number of points, then return.
if ring<=1 && buf.nverts>=minpnts
    buf = reset_buffe(vid, buf, int32(0), int32(0));
    return;
end

cur_ring = 1;
nelems_pre = int32(0);
fvids_tet  = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);

% Extend to the rings
while 1
    nverts_last = buf.nverts; nelems_last = buf.nelems;
    
    if cur_ring+0.5>=ring
        % Expand by half a level
        % Append unvisited neighbor tets to the queue
        for ii = nelems_pre+1:nelems_last
            hfid = buf.ngbes(ii);
            hfid = sibhfs( hfid2cid( hfid), hfid2lfid( hfid));
            
            if hfid
                cid = hfid2cid( hfid); lfid = hfid2lfid( hfid);
                buf = insert_halfface( tets(cid,fvids_tet(lfid,1)), hfid, tets, buf);
            end
        end
        
        if cur_ring+0.5>=ring && buf.nverts>=minpnts || ...
                buf.nverts>=minpnts && cur_ring>=ring || nelems_last==buf.nelems
            % If reached goal or it no longer grows, stop.
            break;
        else
            buf = reset_buffe(vid, buf, nverts_last, nelems_last);
        end
    end
    
    % Expand by a level
    for ii = nelems_pre+1 : nelems_last
        hfid = buf.ngbes(ii);  
        hfid = sibhfs( hfid2cid( hfid), hfid2lfid( hfid));
        
        if hfid
            cid = hfid2cid( hfid); lfid = hfid2lfid( hfid);
            
            for jj=1:3
                buf = append_one_ring( cid, fvids_tet(lfid,jj), tets, sibhfs, buf);
            end
        end
    end
    
    cur_ring = cur_ring + 1;
    if buf.nverts>=minpnts && cur_ring>=ring || nelems_last==buf.nelems
        % If no longer grows, stop.
        break;
    end
    
    % Save the current status
    nelems_pre = nelems_last;
end
buf = reset_buffe(vid, buf, int32(0), int32(0));

function buf = append_one_ring( cid, lvid, tets, sibhfs, buf)
% Append the one-ring neighborhood of a vertex tets(cid,lvid)
%        into buf.ngbvs and buf.ngbes.
adjhfs_tet = int32([1,2,4; 1 2 3; 1 3 4; 2 3 4]);
% Opposite vertex of a face
oppvid_tet = int32([4; 3; 1; 2]);
% Opposite face of a vertex
oppfid_tet = int32([3; 4; 2; 1]);

hfid = clfids2hfid( cid, oppfid_tet(lvid));

% Insert element itself into queue.
if ~buf.etags(cid) && buf.nelems < length(buf.ngbes)
    buf.etags(cid) = true;
    buf.nelems = buf.nelems + 1;
    buf.ngbes(buf.nelems) = hfid;
    
    % Append vertices of the element
    for ii=int32(1):4
        v = tets(cid,ii);
        
        if ~buf.vtags( v)
            if buf.nverts<=length(buf.ngbvs);
                buf.vtags( v) = true;
                buf.nverts = buf.nverts + 1; buf.ngbvs(buf.nverts) = v;
            end
        end
    end
end

% Use unused part of buf.ngbes as queue.
queue_start = buf.nelems+1;
vid = tets(cid, lvid);

while 1
    % Append unvisited neighbor tets to the queue
    cid = hfid2cid( hfid);
    lvid = oppvid_tet(hfid2lfid( hfid));
    assert( tets(cid, lvid)==vid);
    for ii=int32(1):3
        hfid = sibhfs(cid, adjhfs_tet(lvid,ii));
        buf = insert_halfface(vid, hfid, tets, buf);
    end
    
    if queue_start<=buf.nelems
        hfid = buf.ngbes(queue_start);
        queue_start = queue_start+1;
    else
        break;
    end
end

function buf = insert_halfface(vid, hfid, tets, buf)
% Insert a halfface and its opposite vertex into buffer

if hfid<=0; return; end

% list of vertices of each face
fvids_tet  = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
% Opposite vertex of a face
oppvid_tet = int32([4; 3; 1; 2]);
% Opposite face of a vertex
oppfid_tet = int32([3; 4; 2; 1]);

cid = hfid2cid( hfid);
lfid = hfid2lfid( hfid);

% Insert element
if cid && ~buf.etags(cid) && buf.nelems<length(buf.ngbes)
    buf.etags(cid) = true;
    buf.nelems = buf.nelems + 1;
    
    s = fvids_tet(lfid,1);
    if tets(cid,s) == vid
        lvid = s;
    else
        s = fvids_tet(lfid,2);
        if tets(cid,s) == vid
            lvid = s;
        else
            lvid = fvids_tet(lfid,3);
            assert(tets(cid,lvid) == vid);
        end
    end
    
    buf.ngbes(buf.nelems) = clfids2hfid(cid, oppfid_tet(lvid));

    % Insert opposite vertex of halfface
    v = tets( cid, oppvid_tet(lfid));
    if ~buf.vtags(v)
        if buf.nverts<=length(buf.ngbvs);
            buf.vtags( v) = true;
            buf.nverts = buf.nverts + 1; buf.ngbvs(buf.nverts) = v;
        end
    end
end

function buf = reset_buffe(vid, buf, nverts_last, nelems_last)
% Reset flags in the buffer

buf.vtags(vid) = nverts_last~=0;

for i=nverts_last+1:buf.nverts
    v = buf.ngbvs(i);
    buf.vtags( v) = false;
end

for i=nelems_last+1:buf.nelems
    cid = hfid2cid(buf.ngbes(i));
    buf.ngbes(i) = cid;
    buf.etags( cid) = false;
end

if nverts_last==0 && isempty( coder.target)
    assert( length(unique( buf.ngbvs(1:buf.nverts)))==buf.nverts);
    assert( length(unique( buf.ngbes(1:buf.nelems)))==buf.nelems);
end

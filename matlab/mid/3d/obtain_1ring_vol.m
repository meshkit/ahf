function [ngbvs, nverts, vtags, etags, ngbes, nelems] = obtain_1ring_vol...
    ( vid, tets, opphfs, v2hf, ngbvs, vtags, etags, ngbes) %#codegen 
%OBTAIN_1RING_VOL Collects 1-ring neighbor vertices and elements.
% [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NELEMS] = OBTAIN_1RING_VOL(VID,TETS, ...
% OPPHFS,V2HF,NGBVS,VTAGS,ETAGS,NGBES) Collects 1-ring neighbor vertices 
% and elements of vertex VID and saves them into NGBVS and NGBES.  Note 
% that NGBVS does not contain VID itself.  At input, VTAGS and ETAGS must 
% be set to zeros. They will be reset to zeros at output.
%
% See also OBTAIN_1RING_SURF, OBTAIN_1RING_CURV

MAXNPNTS = int32(1024);
MAXTETS = int32(1024);

assert( numel(ngbvs) <= MAXNPNTS);
assert( numel(ngbes) <= MAXNPNTS);

nverts=int32(0); nelems=int32(0);

% Obtain incident tetrahedron of vid.
eid = hfid2cid(v2hf(vid));
if ~eid; return; end  % If no incident tets, then return.

% Initialize array
vtags(vid) = true;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXTETS,1,'int32'));
size_stack = int32(1); stack(1) = eid;

opphfs_tet = int32([1, 2, 4; 1 2 3; 1 3 4; 2 3 4]);

% Insert element itself into queue.
while size_stack>0
    % Pop the element from top of stack
    eid = stack(size_stack); size_stack = size_stack-1;
    etags(eid) = true;

    % Append element
    nelems = nelems + 1; ngbes(nelems) = eid;

    lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
    % Append vertices
    for ii=int32(1):4
        v = tets(eid,ii);
        if v == vid; lvid = ii; end

        if ~vtags( v)
            vtags( v) = true; nverts = nverts + 1; ngbvs(nverts) = v;
        end
    end

    % Push unvisited neighbor tets onto stack
    for ii=int32(1):3
        ngb = hfid2cid(opphfs(eid,opphfs_tet(lvid,ii)));
        if ngb && ~etags(ngb);
            size_stack = size_stack + 1; stack(size_stack) = ngb;
        end
    end
end

% Reset flags
vtags(vid) = false;
vtags(ngbvs(1:nverts)) = false;
etags(ngbes(1:nelems)) = false;


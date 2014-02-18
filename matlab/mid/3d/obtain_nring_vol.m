function [ngbvs, nverts, vtags, etags, ngbes, nelems] = obtain_nring_vol( vid, ring, minpnts, ...
        tets, sibhfs, v2hf, ngbvs, vtags, etags, ngbes) %#codegen 
    
%OBTAIN_NRING_VOL Collect 1-ring neighbor vertics and elements.
% [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NELEMS] = OBTAIN_NRING_VOL(VID,RING, ...
% MINPNTS,TETS,SIBHFS,V2HF,NGBVS,VTAGS,ETAGS,NGBES) Collects 1-ring 
% neighbor vertices and elements of vertex VID and saves them into NGBVS 
% and NGBES.  Note that NGBVS does not contain VID itself.  At input, VTAGS
% and ETAGS must be set to zeros. They will be reset to zeros at output.
%
% See also OBTAIN_NRING_QUAD, OBTAIN_NRING_SURF, OBTAIN_NRING_CURV

% FIXME: This function currently does not support half rings.

MAXRING = 4;
MAXNPNTS = 1024;
MAXNTETS = 1024;

assert( islogical( vtags) && islogical(etags));
assert( numel(ngbvs) <= MAXNPNTS);
assert( numel(ngbes) <= MAXNTETS);

nverts=int32(0); nelems=int32(0);

% Obtain incident tetrahedron of vid.
if ~v2hf(vid); return; end  % If no incident tets, then return.

% Initialize array
vtags(vid) = true;
[ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
    append_one_ring( vid, tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags, ngbes, nelems);

if ring == 1 && nverts>=minpnts
    % Reset flags
    vtags(vid) = false;
    vtags(ngbvs(1:nverts)) = false; etags(ngbes(1:nelems)) = false;
    return;
end

% Second, build full-size ring
nverts_pre = int32(1);
minpnts = min(minpnts, MAXNPNTS);
cur_ring=1; ring=min(MAXRING,ring);

while 1
    % Collect next level of ring
    nverts_last = nverts; nelems_pre = nelems;

    for ii = nverts_pre+1 : nverts_last
        [ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
            append_one_ring( ngbvs(ii), tets, sibhfs, v2hf, ngbvs, ...
            nverts, vtags, etags, ngbes, nelems);
    end

    cur_ring = cur_ring+1;
    if nverts>=minpnts && cur_ring>=ring || nelems_pre==nelems
        break;
    end

    nverts_pre = nverts_last;
end

% Reset flags
vtags(vid) = false;
vtags(ngbvs(1:nverts)) = false; etags(ngbes(1:nelems)) = false;

function [ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
    append_one_ring( vid, tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags, ngbes, nelems)
if ~v2hf(vid); return; end

rid = hfid2cid(v2hf(vid)); % Element (region) ID
MAXNTETS = 1024;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXNTETS,1,'int32'));
size_stack = int32(1); stack(1) = rid;

% Insert element itself into queue.
sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
while size_stack>0
    % Pop the element from top of stack
    rid = stack(size_stack); size_stack = size_stack-1;
    if ~etags(rid)
        etags(rid) = 1;

        % Append element
        nelems = nelems + 1; ngbes(nelems) = rid;

        lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
        % Append vertices
        for ii=int32(1):4
            v = tets(rid,ii);
            if v == vid; lvid = ii; end

            if ~vtags( v)
                vtags( v) = true; nverts = nverts + 1; ngbvs(nverts) = v;
            end
        end

        % Push unvisited neighbor tets onto stack
        for ii=int32(1):3
            ngb = hfid2cid(sibhfs(rid,sibhfs_tet(lvid,ii)));
            if ngb && ~etags(ngb);
                size_stack = size_stack + 1; stack(size_stack) = ngb;
            end
        end
    end
end


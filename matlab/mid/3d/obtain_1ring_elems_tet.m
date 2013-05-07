function [ngbes, nelems, etags] = obtain_1ring_elems_tet( vid, ...
    tets, sibhfs, v2hf, ngbes, etags)  %#codegen
%OBTAIN_1RING_ELEMS_TET Collects 1-ring neighbor elements of tet mesh.
% [NGBES, NELEMS, ETAGS] = OBTAIN_1RING_ELEMS_TET( VID, ...
%         TETS, SIBHFS, V2HF, NGBES, ETAGS)
% Collects 1-ring neighbor elements of given vertex and saves them into 
% NGBES. At input, ETAGS must be set to false. It is reset to false
% at output.

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,4]),coder.typeof(int32(0), [inf,4]),coder.typeof(int32(0), [inf,1]),
%#codegen     coder.typeof(int32(0), [inf,1]), coder.typeof(false, [inf,1])}

coder.extrinsic('warning');

MAXTETS = 1024;
assert( numel(ngbes) <= MAXTETS);

nelems=int32(0);

% Obtain incident tetrahedron of vid.
eid = hfid2cid(v2hf(vid));
if ~eid; return; end

sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
maxne = min(MAXTETS,length(ngbes));
overflow = false;

% Create a stack for storing tets and insert element itself into stack
stack = nullcopy(zeros(MAXTETS,1, 'int32'));
size_stack = int32(1); stack(1) = eid;

while size_stack>0
    % Pop the element from top of stack
    eid = stack(size_stack); size_stack = size_stack-1;
    etags(eid) = true;

    % Append element
    if nelems<maxne
        nelems = nelems + 1; ngbes(nelems) = eid;
    else
        overflow = true;
    end

    lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
    for ii=int32(1):4
        v = tets(eid,ii);
        if v==vid; lvid = ii; end
    end

    % Push unvisited neighbor tets onto stack
    for ii=1:3
        ngb = hfid2cid(sibhfs(eid,sibhfs_tet(lvid,ii)));
        if ngb && ~etags(ngb);
            size_stack = size_stack + 1; stack(size_stack) = ngb;
        end
    end
end

% Reset etags
etags(ngbes(1:nelems)) = false;

if overflow
    warning('Buffers are too small to contain neighborhood in obtain_nring_elems_tet.m.');
end

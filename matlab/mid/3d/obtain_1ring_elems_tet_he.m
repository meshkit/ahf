function [hfid,etags] = obtain_1ring_elems_tet_he( origin, terminal_vertex, mesh, etags)  %#codegen
%OBTAIN_1RING_ELEMS_TET Examins 1-ring tet neighborhood of vid for edge [origin,terminal_vertex].
% [HFID,ETAGS] = OBTAIN_1RING_ELEMS_TET_HE( ORIGIN, TERMINAL_VERTEX, ETAGS)
% Looks through 1-ring neighbor elements of given vertex and finds half-face containing given edge.
% At input, ETAGS must be set to false. It is reset to false at output.

coder.extrinsic('warning');

MAXTETS = 1024;
nelems=int32(0);
if nargin<4; etags=false(size(mesh.xs,1)); end;
% Obtain incident tetrahedron of vid.
eid = hfid2cid(mesh.v2hf(origin));
if ~eid; return; end

sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
lookup_lfid = int32([0,2,1,4;1,0,3,2;4,1,0,3;2,3,4,0]);
maxne = MAXTETS;
overflow = false;

% Create a stack for storing tets and insert element itself into stack
% stack = nullcopy(zeros(MAXTETS,1, 'int32'));
queue = zeros(MAXTETS,1, 'int32'); 
queue_top = int32(1);  queue_size = int32(1); 
queue(1) = eid;

while queue_top<=queue_size
    % Pop the element from top of stack
    eid = queue(queue_top); queue_top = queue_top+1;
    etags(eid) = true;

    % Append element
    if nelems<maxne
        nelems = nelems + 1;
    else
        overflow = true;
    end
    
    found=false;
    lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
    for ii=1:4
        v = mesh.cells(eid,ii);
        if v==origin; 
            lvid = ii;             
        else
            if v==terminal_vertex
                % found tetrahedra containing edge <vid,terminal_vertex>
                found=true;
                ltv=ii;
            end
        end
    end
     
    if found
        hfid=clfids2hfid(eid,lookup_lfid(lvid,ltv));
        etags(queue(1:queue_size)) = false;
        return;
    end
    
    % Push unvisited neighbor tets onto stack
    for ii=1:3
        ngb = hfid2cid(mesh.sibhfs(eid,sibhfs_tet(lvid,ii)));
        if ngb && ~etags(ngb);
            queue_size = queue_size + 1; queue(queue_size) = ngb;
        end
    end
end

% Reset etags
etags(queue(1:queue_size)) = false;

if overflow
    warning('MATLAB:obtain_nring_elems_tet_he','Buffers are too small to contain neighborhood.');
end

function [ngbes, nelems] = obtain_1ring_elems_surf( vid, ...
    elems, opphes, v2he, ngbes) %#codegen
% OBTAIN_1RING_ELEMS_SURF Collect 1-ring neighbor elements of surface mesh.
% [NGBES, NELEMS] = OBTAIN_1RING_ELEMS_SURF( VID, ELEMS, OPPHES,V2HE,NGBES)
% Collects 1-ring neighbor elements of given vertex and saves them 
% into NGBES. It supports triangle and quadrilateral meshes.

assert( isa(vid,'int32') && isa(elems,'int32') && isa(opphes,'int32') && ...
    isa(v2he,'int32') && isa(ngbes,'int32'));

MAXNE = 128;
assert( numel(MAXNE)<=MAXNE);

nelems=int32(0);

fid = heid2fid(v2he(vid)); 
if ~fid; return; end

lid = heid2leid(v2he(vid));
if opphes( fid, lid); fid_in = fid; else fid_in = int32(0); end

prv = int32([3 1 2 0; 4 1 2 3]);
maxnf = min(size(ngbes,1), MAXNE);
overflow = false;

% Rotate in counter-clockwise order.
while 1
    nedges = 3 + int32(size(elems,2)==4 && elems(fid,end)~=0);
    lid_prv = prv(nedges-2, lid);

    % Append element
    if nelems<maxnf
        nelems = nelems + 1; ngbes( nelems) = fid;
    else
        overflow = true;
    end

    % Go to next element
    opp = opphes(fid, lid_prv);
    fid = heid2fid(opp);

    if fid == fid_in % Finished cycle
        break;
    else
        lid = heid2leid(opp);
    end
end

if overflow
    error('Buffers are too small to contain neighborhood in obtain_nring_elems_surf.m.');
end

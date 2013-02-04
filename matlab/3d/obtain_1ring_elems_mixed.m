function [ngbes, nelems, etags,eltypes] = ...
  obtain_1ring_elems_mixed(vid, elems_buf, elems_offsets, elems_type,... 
  reg_opphfs, v2hf, ngbes, etags,eltypes) %#codegen
%OBTAIN_1RING_ELEMS_MIXED Collects 1-ring neighbor elements of mixed mesh.
% [NGBES, NELEMS, ETAGS] = OBTAIN_1RING_ELEMS_TET( VID, ...
%         ELEMS_HYB, OPPHFS, V2HF, NGBES, ETAGS)
% Collects 1-ring neighbor elements of given vertex and saves them into 
% NGBES. At input, ETAGS must be set to false. It is reset to false
% at output.

coder.extrinsic('warning');

MAXTETS = 1024;
assert( numel( ngbes)<=MAXTETS);

nelems=int32(0);

% Obtain incident element of vid.
eid = hfid2cid(v2hf(vid));
if ~eid; return; end

opphfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);

opphfs_pyr = int32([1 2 5 0; 1 3 2 0; 1 4 3 0; 1 5 4 0; 2 3 4 5]);

opphfs_pri = int32([4 3 1; 4 1 2; 4 2 3; 5 1 3; 5 2 1; 5 3 2]);

opphfs_hex = int32([1 5 2; 1 2 3; 1 3 4; 1 4 5;6 2 5; 6 3 2;6 4 3; 6 5 4 ]);
%ADD THE OTHERS LATER


maxne = min(MAXTETS,length(ngbes));
overflow = false;

% Create a stack for storing tets and insert element itself into stack
stack = nullcopy(zeros(MAXTETS,1,'int32'));
size_stack = int32(1); stack(1) = eid;

while size_stack>0
    % Pop the element from top of stack
    eid = stack(size_stack); size_stack = size_stack-1;
    if(etags(eid)); continue;end
    etags(eid) = true;
    nvpE=elems_type(eid);

    % Append element
    if nelems<maxne
        nelems = nelems + 1; 
        ngbes(nelems) = eid;
        eltypes(nelems) = nvpE;
    else
        overflow = true;
    end

    lvid = int32(0); % Stores which vertex vid is within the element.
    for ii=1:nvpE
        v = elems_buf(elems_offsets(eid)+ii);
        if v==vid; lvid = ii; end
    end

    % Push unvisited neighbor elements onto stack
    for ii=1:4%We have to consider a potential of 4 faces due to the 
              %single degnerate pyramid node
        ngb=int32(0);
        if(nvpE==4)
          if(ii==4);continue;end;
          ngb = hfid2cid(reg_opphfs(eid,opphfs_tet(lvid,ii)));
        elseif(nvpE==5)
          if(opphfs_pyr(lvid,ii))>0
            ngb = hfid2cid(reg_opphfs(eid,opphfs_pyr(lvid,ii)));
          end
        elseif(nvpE==6)
          if(ii==4);continue;end;
          ngb = hfid2cid(reg_opphfs(eid,opphfs_pri(lvid,ii)));
        elseif(nvpE==8)
          if(ii==4);continue;end;
          ngb = hfid2cid(reg_opphfs(eid,opphfs_hex(lvid,ii)));
        else
          error('Not implemented yet for this type');
        end
        if ngb && ~etags(ngb);
            size_stack = size_stack + 1; stack(size_stack) = ngb;
        end
    end
end

% Reset etags
etags(ngbes(1:nelems)) = false;

if overflow
    warning('MATLAB:overflow',...
      'Buffers are too small to contain neighborhood in obtain_nring_elems_tet.m.');
end

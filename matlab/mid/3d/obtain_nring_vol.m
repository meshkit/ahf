function [ngbvs, nverts, vtags, etags, etags_elem, ngbes, nelems] = obtain_nring_vol( vid, ring, minpnts, ...
        tets, sibhfs, v2hf, ngbvs, ngbes, vtags, etags, etags_elem)
    
%#codegen -args {int32(0), double(0), int32(0), coder.typeof(int32(0), [inf,4]), coder.typeof(int32(0), [inf,4]),
%#codegen     coder.typeof(int32(0), [inf,1]), coder.typeof(int32(0), [inf,1]),
%#codegen     coder.typeof(int32(0), [inf,1]), coder.typeof(false, [inf,1]),
%#codegen     coder.typeof(false, [inf,1]), coder.typeof(false, [inf,1])}

%OBTAIN_NRING_VOL Collect n-ring neighbor vertics and elements.
% [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NELEMS] = OBTAIN_NRING_VOL(VID,RING, ...
% MINPNTS,TETS,SIBHFS,V2HF,NGBVS,VTAGS,ETAGS,NGBES) 

% This function collects n-ring neighbor vertices and elements of vertex VID
% and saves them into NGBVS and NGBES.  Note that NGBVS does not contain VID
% itself.  At input, VTAGS and ETAGS must be set to false. They will be 
% reset to false at output.
%
% VTAGS is marked true when a vertex is added to NGBVS.
% ETAGS is marked true when a vertex from that element is added to NGBVS
%   (and thus the elemement is added to NGBES)
% ETAGS_ELEM is for use with the subfunctions elem_one_ring and
%   append_one_ring.
%   Calling these functions using ETAGS (instead of ETAGS_ELEM) will
%   result in missing vertices in rings larger than 1.
%
% This function supports 1/3 rings.  Use RING = 1.3 for the 1 1/3 ring 
%   Use RING = 1.7 for the 1 2/3 ring. Etc

coder.extrinsic('warning');

overflow = false;

MAXRING = 4;
MAXNPNTS = 1024;
MAXNTETS = 1024;

assert( islogical( vtags) && islogical(etags));
assert( numel(ngbvs) <= MAXNPNTS);
assert( numel(ngbes) <= MAXNTETS);

% Initialize variables
vtags(vid) = true;
nverts=int32(0); nelems=int32(0);

% If no incident tets, then return.
if ~v2hf(vid); return; end  

% Obtain the 1-ring
[ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
    append_one_ring( vid, tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags, ngbes, nelems);

% If only a 1-ring is needed, return
if ring == 1 && nverts>=minpnts
    vtags(vid) = false;
    vtags(ngbvs(1:nverts)) = false; etags(ngbes(1:nelems)) = false;
    return;
end

% Prepare to build larger rings
nverts_pre = int32(0); 
nelems_pre = int32(0); 
minpnts = min(minpnts, MAXNPNTS);
cur_ring=1; ring=min(MAXRING,ring);
ring_full = fix( ring); 

onethird = false;
twothird = false;
if ring ~= ring_full
    if round(ring - ring_full) == 0
        onethird = true;
    else
        twothird = true;
    end
end;

while 1
    
    if cur_ring>ring_full || (cur_ring==ring_full && onethird)
        % Collect one-third-ring

        nverts_last = nverts;
        
        temp_verts = int32(zeros(12*nelems,1));
        ntemp = int32(0);
        
        %Check currently listed neighboring elements
        %for ii = int32(1):nelems
        for ii = nelems_pre+1:nelems
            eid = ii;   
            numv =  int32(vtags(tets(eid,1)) + vtags(tets(eid,2)) + vtags(tets(eid,3)) + vtags(tets(eid,4)));
            if numv == 3 
                for kk = int32(1):4
                    ntemp = ntemp + 1; 
                    temp_verts( ntemp) = tets(eid,kk);
                end
            end
             
        end
        
        %Check latest ring of neighboring elements
        for ii = nverts_pre+1 : nverts
            ngbes_lcl = zeros(64,1);
            nelems_lcl = 0;
            [etags_elem, ngbes_lcl, nelems_lcl] = elem_one_ring(...
                ngbvs(ii), tets, sibhfs, v2hf, etags_elem, ngbes_lcl, nelems_lcl);

            if nelems+nelems_lcl > MAXNTETS
                overflow = true;
                break
            else
                for jj = int32(1):nelems_lcl
                    eid = ngbes_lcl(jj);
                    etags_elem(eid) = false;
                    if etags(eid) ~= true
                        numv =  int32(vtags(tets(eid,1)) + vtags(tets(eid,2)) + vtags(tets(eid,3)) + vtags(tets(eid,4)));
                        if numv == 3 
                            for kk = int32(1):4
                                if ~vtags(tets(eid,kk))
                                    ntemp = ntemp + 1; 
                                    temp_verts( ntemp) = tets(eid,kk);
                                end
                            end
                        end
                    end
                end     
            end 
        end
        

        for ii = int32(1):ntemp
            if nverts>=MAXNPNTS
                printf('Overflow in 1/3 ring in obtain_nring_vol_edited.m \n');
                overflow = true;
            elseif ~vtags(temp_verts(ii))
                nverts = nverts + 1; ngbvs( nverts) = temp_verts(ii);
                vtags(temp_verts(ii)) = true;
            end
        end
        
        
        if nverts>=minpnts || nverts>=MAXNPNTS 
            break; % Do not need further expansion
        else
            % If needs to expand, then undo the last third ring
            for i=nverts_last+1:nverts; vtags(ngbvs(i)) = false; end
            nverts = nverts_last;
            twothird = true;
            %If the 1/3 ring is not big enough, we will try a 2/3 rings to
            %   see if we can get minpnts.

        end
    end
    
    if cur_ring>ring_full || (cur_ring==ring_full && twothird)
        % Collect two-third-ring
                
        nverts_last = nverts;
        
        temp_verts = int32(zeros(24*nelems,1));
        ntemp = int32(0);
        
        %Check currently listed neighboring elements
        % for ii = int32(1):nelems
        for ii = nelems_pre+1:nelems
            eid = ii;   
            numv =  int32(vtags(tets(eid,1)) + vtags(tets(eid,2)) + vtags(tets(eid,3)) + vtags(tets(eid,4)));
            if numv ==2 || numv == 3 
                for kk = int32(1):4
                    ntemp = ntemp + 1; 
                    temp_verts( ntemp) = tets(eid,kk);
                end
            end
             
        end
        
        %Check latest ring of neighboring elements
        for ii = nverts_pre+1 : nverts
            ngbes_lcl = zeros(64,1);
            nelems_lcl = 0;
            [etags_elem, ngbes_lcl, nelems_lcl] = elem_one_ring(...
                ngbvs(ii), tets, sibhfs, v2hf, etags_elem, ngbes_lcl, nelems_lcl);

            if nelems+nelems_lcl > MAXNTETS
                overflow = true;
                break
            else
                for jj = int32(1):nelems_lcl
                    eid = ngbes_lcl(jj);
                    etags_elem(eid) = false;
                    if etags(eid) ~= true
                        numv =  int32(vtags(tets(eid,1)) + vtags(tets(eid,2)) + vtags(tets(eid,3)) + vtags(tets(eid,4)));
                        if numv ==2 || numv == 3
                            for kk = int32(1):4
                                if ~vtags( tets(eid,kk))
                                    ntemp = ntemp + 1; 
                                    temp_verts( ntemp) = tets(eid,kk);
                                end
                            end
                        end
                    end
                end     
            end 
        end
        

        for ii = int32(1):ntemp
            if nverts>=MAXNPNTS
                printf('Overflow in 1/3 ring in obtain_nring_vol_edited.m \n');
                overflow = true;
            elseif ~vtags(temp_verts(ii))
                nverts = nverts + 1; ngbvs( nverts) = temp_verts(ii);
                vtags(temp_verts(ii)) = true;
            end
        end
        
        
        if nverts>=minpnts || nverts>=MAXNPNTS 
            break; % Do not need further expansion
        else
            % If needs to expand, then undo the last third ring
            for i=nverts_last+1:nverts; vtags(ngbvs(i)) = false; end
            nverts = nverts_last;

        end
    end
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Collect next level of ring
    nverts_last = nverts; nelems_pre = nelems;

    for ii = nverts_pre+1 : nverts_last
        ngbes_lcl = zeros(64,1);
        nelems_lcl = 0;
        [ngbvs, nverts, vtags, etags_elem, ngbes_lcl, nelems_lcl] = append_one_ring(...
            ngbvs(ii), tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags_elem, ngbes_lcl, nelems_lcl);
        
        if nelems+nelems_lcl > MAXNTETS
            overflow = true;
            break
        else
            for jj = int32(1):nelems_lcl
                eid = ngbes_lcl(jj);
                etags_elem(eid) = false;
                if etags(eid) ~= true
                    etags(eid) = true;
                    nelems = nelems+1;
                    ngbes(nelems) = eid;
                end
            end     
        end    
        
        if nverts >= MAXNPNTS
            overflow = true;
            break
        end
    end

    cur_ring = cur_ring+1;
    if (nverts>=minpnts && cur_ring>=ring) || nelems_pre==nelems || overflow
        break;
    end

    nverts_pre = nverts_last;
end


% Reset flags
vtags(vid) = false;
vtags(ngbvs(1:nverts)) = false; 
etags(ngbes(1:nelems)) = false;  

if overflow
    warning('MATLAB:overflow',...
      'Buffers are too small to contain neighborhood in obtain_1ring_elems.m.');
end

end

function [ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
    append_one_ring( vid, tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags, ngbes, nelems)

% This determines the 1-ring of vertices aroung the element VID

coder.extrinsic('warning');

if ~v2hf(vid); return; end

rid = hfid2cid(v2hf(vid)); % Element (region) ID
MAXNTETS = 1024;

overflow = false;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXNTETS,1,'int32'));

% Insert element itself into queue.
size_stack = int32(1); stack(1) = rid;

% sibhfs_tet(lvid, :) gives the faces that border on local vertex lvid.
% This is used with sibhfs to find the neighboring tets.
sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);

while size_stack>0
    % Pop the element from top of stack
    rid = stack(size_stack); size_stack = size_stack-1;

    % Append element
    if nelems >= MAXNTETS
        printf('Overflow in elements in append_one_ring.m \n');           
        overflow = true;
    elseif ~etags(rid)
        etags(rid) = 1;
        nelems = nelems + 1;
        ngbes(nelems) = rid;

        lvid = int32(0); % Stores the local vertex of vid
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
            if lvid == 0
                break
            else
                ngb = hfid2cid(sibhfs(rid,sibhfs_tet(lvid,ii)));
                if ngb && ~etags(ngb);
                    if size_stack >= MAXNTETS
                        printf('Overflow in stack in append_one_ring.m \n');
                        overflow = true;
                    else
                        size_stack = size_stack + 1; stack(size_stack) = ngb;
                    end
                end
            end
        end
        
    end
    
    if overflow
        break
    end
end


if overflow
    warning('MATLAB:overflow',...
      'Buffers are too small to contain neighborhood in append_one_ring.m.');
end

end

function [etags, ngbes, nelems] = elem_one_ring( vid, tets, sibhfs, v2hf, etags, ngbes, nelems)

% This is similar to append_one_ring.m but this function only finds the 1-ring of elements.
% This is called when finding the 1/3 or 2/3 rings.

coder.extrinsic('warning');

if ~v2hf(vid); return; end

rid = hfid2cid(v2hf(vid)); % Element (region) ID

MAXNTETS = 1024; 
overflow = false;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXNTETS,1,'int32'));

% Insert element itself into queue.
size_stack = int32(1); stack(1) = rid;

% sibhfs_tet(lvid, :) gives the faces that border on local vertex lvid.
% This is used with sibhfs to find the neighboring tets.
sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);

while size_stack>0
    % Pop the element from top of stack
    rid = stack(size_stack); size_stack = size_stack-1;

    % Append element
    if nelems >= MAXNTETS
        printf('Overflow in elements in append_one_ring.m \n');
        overflow = true;
    elseif ~etags(rid)
        etags(rid) = 1;
        nelems = nelems + 1;
        ngbes(nelems) = rid;
        
        lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
        for ii=int32(1):4
            v = tets(rid,ii);
            if v == vid; lvid = ii; end
        end

        % Push unvisited neighbor tets onto stack
        for ii=int32(1):3
            if lvid == 0
                break
            else
                ngb = hfid2cid(sibhfs(rid,sibhfs_tet(lvid,ii)));
                if ngb && ~etags(ngb);
                    if size_stack >= MAXNTETS
                        printf('Overflow in stack in append_one_ring.m \n');
                        overflow = true;
                    else
                        size_stack = size_stack + 1; stack(size_stack) = ngb;
                    end
                end
            end
        end
    end
    
    if overflow
        break
    end
end


if overflow
    warning('MATLAB:overflow',...
      'Buffers are too small to contain neighborhood in append_one_ring.m.');
end

end

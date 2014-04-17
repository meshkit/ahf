function [ngbvs, nverts, vtags, etags, ngbes, nelems] = obtain_nring_vol( vid, ring, minpnts, ...
        tets, sibhfs, v2hf, ngbvs, ngbes, vtags, etags)
    
%#codegen -args {int32(0), double(0), int32(0), coder.typeof(int32(0), [inf,4]), coder.typeof(int32(0), [inf,4]),
%#codegen     coder.typeof(int32(0), [inf,1]), coder.typeof(int32(0), [inf,1]),
%#codegen     coder.typeof(int32(0), [inf,1]), coder.typeof(false, [inf,1]),
%#codegen     coder.typeof(false, [inf,1])}
    
%OBTAIN_NRING_VOL Collect n-ring neighbor vertics and elements.
% [NGBVS,NVERTS,VTAGS,ETAGS,NGBES,NELEMS] = OBTAIN_NRING_VOL(VID,RING, ...
% MINPNTS,TETS,SIBHFS,V2HF,NGBVS,VTAGS,ETAGS,NGBES) 

% This function collects n-ring neighbor vertices and elements of vertex VID
% and saves them into NGBVS and NGBES.  Note that NGBVS does not contain VID
% itself.  At input, VTAGS and ETAGS must be set to false. They will be 
% reset to false at output.
%
% This function supports 1/3 rings.  Use RING = 1.3 for the 1 1/3 ring 
%   Use RING = 1.7 for the 1 2/3 ring. Etc

coder.extrinsic('warning');

etags_elem = etags;

overflow = false;

MAXRING = 4;
MAXNPNTS = 1024;
MAXNTETS = 3000;  %This is for 3-ring

face = int32([1 2 3; 1 2 4; 2 3 4; 1 3 4;]);

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
    vtags(vid) = false;
    vtags(ngbvs(1:nverts)) = false; etags(ngbes(1:nelems)) = false;
    return;
end

% Second, build full-size ring
nverts_pre = int32(0); 
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
        for ii = int32(1):nelems
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
        for ii = 1:nverts
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
                printf('nverts = %d \n',nverts);
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
    
    if cur_ring>ring_full || (cur_ring==ring_full && twothird)
        % Collect two-third-ring
        
        
        nverts_last = nverts;
        
        temp_verts = int32(zeros(24*nelems,1));
        ntemp = int32(0);
        
        %Check currently listed neighboring elements
        for ii = int32(1):nelems
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
        for ii = 1:nverts
            %etags_elem(:) = false;
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
                printf('nverts = %d \n',nverts);
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
etags(:) = false; %etags(ngbes(1:nelems)) = false;  %FIXME

if overflow
    warning('MATLAB:overflow',...
      'Buffers are too small to contain neighborhood in obtain_1ring_elems.m.');
end

end

function [ngbvs, nverts, vtags, etags, ngbes, nelems] = ...
    append_one_ring( vid, tets, sibhfs, v2hf, ngbvs, nverts, vtags, etags, ngbes, nelems)

coder.extrinsic('warning');

if ~v2hf(vid); return; end

rid = hfid2cid(v2hf(vid)); % Element (region) ID
%MAXNTETS = 1024;  %This is too small for 3 rings
MAXNTETS = 3000;

overflow = false;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXNTETS,1,'int32'));
size_stack = int32(1); stack(1) = rid;

% Insert element itself into queue.
sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
while size_stack>0
    % Pop the element from top of stack
    rid = stack(size_stack); size_stack = size_stack-1;

        % Append element
        if nelems >= MAXNTETS
            printf('Overflow in elements in append_one_ring.m \n');
            
            % Delete this, for testing
            nelems = nelems + 1;
            printf('nelems = %d \n', nelems);
            
            overflow = true;
        elseif ~etags(rid)
            etags(rid) = 1;
            nelems = nelems + 1;
            ngbes(nelems) = rid;
        end

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
            if lvid == 0
                printf('lvid = 0 \n');
                overflow = true;  %not really overflow and I don't think this happens, but error testing
                break
            else
            ngb = hfid2cid(sibhfs(rid,sibhfs_tet(lvid,ii)));
            if ngb && ~etags(ngb);
                if size_stack >= MAXNTETS
                    printf('Overflow in stack in append_one_ring.m \n');
                    overflow = true;
                    
                    % Delete this, for testing
                    size_stack = size_stack + 1;
                    printf('size_stack = %d \n', size_stack);
                else
                    size_stack = size_stack + 1; stack(size_stack) = ngb;
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

% 6 March 2014 - This is similar to append_one_ring.m but this function
% only finds the 1-ring of elements.


coder.extrinsic('warning');

if ~v2hf(vid); return; end

rid = hfid2cid(v2hf(vid)); % Element (region) ID
%MAXNTETS = 1024;  %This is too small for 3 rings
MAXNTETS = 3000;

overflow = false;

% Create a stack for storing tets
stack = nullcopy(zeros(MAXNTETS,1,'int32'));
size_stack = int32(1); stack(1) = rid;

% Insert element itself into queue.
sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
while size_stack>0
    % Pop the element from top of stack
    rid = stack(size_stack); size_stack = size_stack-1;

        % Append element
        if nelems >= MAXNTETS
            printf('Overflow in elements in append_one_ring.m \n');
            
            % Delete this, for testing
            nelems = nelems + 1;
            printf('nelems = %d \n', nelems);
            
            overflow = true;
        elseif ~etags(rid)
            etags(rid) = 1;
            nelems = nelems + 1;
            ngbes(nelems) = rid;
        end

        lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
        for ii=int32(1):4
            v = tets(rid,ii);
            if v == vid; lvid = ii; end
        end

        % Push unvisited neighbor tets onto stack
        for ii=int32(1):3
            if lvid == 0
                printf('lvid = 0 \n');
                overflow = true;  %not really overflow and I don't think this happens, but it's here for error testing
                break
            else
            ngb = hfid2cid(sibhfs(rid,sibhfs_tet(lvid,ii)));
            if ngb && ~etags(ngb);
                if size_stack >= MAXNTETS
                    printf('Overflow in stack in append_one_ring.m \n');
                    overflow = true;
                    
                    % Delete this, for testing
                    size_stack = size_stack + 1;
                    printf('size_stack = %d \n', size_stack);
                else
                    size_stack = size_stack + 1; stack(size_stack) = ngb;
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

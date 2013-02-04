function [ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_nring_surf...
    ( vid, ring, minpnts, tris, opphes, v2he, ngbvs, vtags, ftags, ngbfs) %#codegen
%OBTAIN_NRING_SURF Collect n-ring vertices and faces of a triangle mesh.
% [NGBVS,NVERTS,VTAGS,FTAGS,NGBFS,NFACES] = OBTAIN_NRING_SURF(VID,RING, ...
% MINPNTS,TRIS,OPPHES,V2HE,NGBVS,VTAGS,FTAGS,NGBFS)  Collects n-ring
% vertices and faces of a vertex and saves them into NGBVS and NGBFS,
% where n is a floating point number with 0.5 increments (1, 1.5, 2, etc.)
% We define the n-ring verticse as follows:
%  - 0-ring: vertex itself
%  - k-ring vertices: vertices that share an edge with (k-1)-ring vertices
%  - (k+0.5)-ring vertices: k-ring plus vertices that share an element
%           with two vertices of k-ring vertices.
% For triangle meshes, the k-ring vertices always form some triangles.
%
% Input arguments
%   vid: vertex ID
%   ring: the desired number of rings (it is a float as it can have halves)
%   minpnts: the minimum number of points desired
%   tris: element connectivity
%   opphes: opposite half-edges
%   v2he: vertex-to-halfedge mapping
%   ngbvs: buffer space for neighboring vertices (not including vid itself)
%   vtags: vertex tags (boolean, of length equal to number of vertices)
%   ftags: face tags (boolean, of length equal to number of elements)
%   ngbfs: buffer space for neighboring faces
%
% Output arguments
%   ngbvs: buffer space for neighboring vertices
%   nverts: number of vertices in the neighborhood
%   vtags: vertex tags (boolean, of length equal to number of vertices)
%   ftags: face tags (boolean, of length equal to number of elements)
%   ngbfs: buffer space for neighboring faces
%   nfaces: number of elements in the neighborhood
%
% Notes
%  1. vtags and ftags must be set to false at input. They are reset to
%     false at output.
%  2. Since the vertex itself is always in ring, we do not include it in
%     the output array ngbvs.
%  3. If NGBVS or NGBFS is not enough to store the whole neighborhood,
%     then only a subset of the neighborhood will be returned.
%     The maximum number of points returned is numel(NGBVS) if NGBVS is
%     given as part of the input, or 128 if not an input arguement.
%     The maximum number of faces returned is numel(NGBFS) if NGBFS is
%     given as part of the input, or 256 if not an input arguement.
%
% See also OBTAIN_NRING_SURF, OBTAIN_NRING_QUAD, OBTAIN_NRING_CURV, OBTAIN_NRING_VOL

coder.extrinsic('warning');

MAXNPNTS = int32(128);

assert(ring>=1 && floor(ring*2)==ring*2);
if nargin>=8; assert( islogical( vtags)); end
if nargin>=9; assert( islogical(ftags)); end

fid = heid2fid(v2he(vid)); lid = heid2leid(v2he(vid));
nverts=int32(0); nfaces=int32(0); overflow = false;

if ~fid; return; end

prv = int32([3 1 2]);
nxt = int32([2 3 1]);

if nargin>=7 && ~isempty(ngbvs)
    maxnv = int32(numel(ngbvs));
else
    maxnv = MAXNPNTS; ngbvs=nullcopy(zeros(MAXNPNTS,1,'int32'));
end

if nargin>=10 && ~isempty(ngbfs)
    maxnf = int32(numel(ngbfs));
else
    maxnf = 2*MAXNPNTS; ngbfs = nullcopy(zeros(maxnf,1, 'int32'));
end

oneringonly = ring==1 && minpnts==0 && nargout<5;
hebuf = nullcopy(zeros(maxnv,1, 'int32'));

% Optimized version for collecting one-ring vertices
if opphes( fid, lid)
    fid_in = fid;
else
    fid_in = int32(0);
    
    v = tris(fid, nxt(lid));
    nverts = int32(1); ngbvs( 1) = v;
    
    if ~oneringonly; hebuf(1) = 0; end
end

% Rotate counterclockwise order around vertex and insert vertices
while 1
    % Insert vertx into list
    lid_prv = prv(lid);
    v = tris(fid, lid_prv);
    
    if nverts<maxnv && nfaces<maxnf
        nverts = nverts + 1; ngbvs( nverts) = v;
        
        if ~oneringonly
            % Save starting position for next vertex
            hebuf(nverts) = opphes( fid, prv(lid_prv));
            nfaces = nfaces + 1; ngbfs( nfaces) = fid;
        end
    else
        overflow = true;
    end
    
    opp = opphes(fid, lid_prv);
    fid = heid2fid(opp);
    
    if fid == fid_in % Finished cycle
        break;
    else
        lid = heid2leid(opp);
    end
end

if ring==1 && (nverts>=minpnts || nverts>=maxnv || nfaces>=maxnf || nargout<=2)
    if overflow
        warning('MATLAB:OVERFLOW', 'Buffers are too small to contain neighborhood in obtain_nring_surf.m.');
    end
    return;
end

vtags(vid) = true;
for i=1:nverts; vtags(ngbvs(i))=true; end
for i=1:nfaces; ftags(ngbfs(i))=true; end

% Define buffers and prepare tags for further processing
nverts_pre = int32(0);
nfaces_pre = int32(0);

% Second, build full-size ring
ring_full = fix( ring);
minpnts = min(minpnts, maxnv);

cur_ring=1;
while true
    if cur_ring>ring_full || (cur_ring==ring_full && ring_full~=ring)
        % Collect halfring
        nfaces_last = nfaces; nverts_last = nverts;
        for ii = nfaces_pre+1 : nfaces_last
            % take opposite vertex in opposite face
            for jj=int32(1):3
                oppe = opphes( ngbfs(ii), jj);
                fid = heid2fid(oppe);
                
                if oppe && ~ftags(fid)
                    lid = heid2leid(oppe);
                    v = tris( fid, prv(lid));
                    
                    overflow = overflow || ~vtags(v) && nverts>=length(ngbvs) || ...
                        ~ftags(fid) && nfaces>=length(ngbfs);
                    if ~ftags(fid) && ~overflow
                        nfaces = nfaces + 1; ngbfs( nfaces) = fid;
                        ftags(fid) = true;
                    end
                    
                    if ~vtags(v) && ~overflow
                        nverts = nverts + 1; ngbvs( nverts) = v;
                        vtags(v) = true;
                    end
                    break;
                end
            end
        end
        
        if nverts>=minpnts || nverts>=maxnv || nfaces>=maxnf || nfaces==nfaces_last
            break; % Do not need further expansion
        else
            % If needs to expand, then undo the last half ring
            for i=nverts_last+1:nverts; vtags(ngbvs(i)) = false; end
            nverts = nverts_last;
            
            for i=nfaces_last+1:nfaces; ftags(ngbfs(i)) = false; end
            nfaces = nfaces_last;
        end
    end
    
    % Collect next full level of ring
    nverts_last = nverts; nfaces_pre = nfaces;
    for ii=nverts_pre+1 : nverts_last
        v = ngbvs(ii); fid = heid2fid(v2he(v)); lid = heid2leid(v2he(v));
        
        % Allow early termination of the loop if an incident halfedge
        % was recorded and the vertex is not incident on a border halfedge
        allow_early_term = hebuf(ii) && opphes(fid,lid);
        if allow_early_term
            fid = heid2fid(hebuf(ii)); lid = heid2leid(hebuf(ii));
        end
        
        %
        if opphes( fid, lid)
            fid_in = fid;
        else
            fid_in = cast(0,class(fid));
            
            v = tris(fid, nxt(lid));
            overflow = overflow || ~vtags(v) && nverts>=length(ngbvs);
            if ~overflow
                nverts = nverts + 1; ngbvs( nverts) = v; vtags(v)=true;
                % Save starting position for next vertex
                hebuf(nverts) = 0;
            end
        end
        
        % Rotate counterclockwise around the vertex.
        isfirst=true;
        while true
            % Insert vertx into list
            lid_prv = prv(lid);
            
            % Insert face into list
            if ftags(fid)
                if allow_early_term && ~isfirst; break; end
            else
                % If the face has already been inserted, then the vertex
                % must be inserted already.
                v = tris(fid, lid_prv);
                overflow = overflow || ~vtags(v) && nverts>=length(ngbvs) || ...
                    ~ftags(fid) && nfaces>=length(ngbfs);
                
                if ~vtags(v) && ~overflow
                    nverts = nverts + 1; ngbvs( nverts) = v; vtags(v)=true;
                    
                    % Save starting position for next ring
                    hebuf(nverts) = opphes( fid, prv(lid_prv));
                end
                
                if ~ftags(fid) && ~overflow
                    nfaces = nfaces + 1; ngbfs( nfaces) = fid; ftags(fid)=true;
                end
                isfirst = false;
            end
            
            opp = opphes(fid, lid_prv);
            fid = heid2fid(opp);
            
            if fid == fid_in % Finished cycle
                break;
            else
                lid = heid2leid(opp);
            end
        end
    end
    
    cur_ring = cur_ring+1;
    if (nverts>=minpnts && cur_ring>=ring) || nfaces==nfaces_pre || overflow
        break;
    end

    nverts_pre = nverts_last;
end

% Reset flags
vtags(vid) = false; 
for i=1:nverts; vtags(ngbvs(i))=false; end
if ~oneringonly; for i=1:nfaces; ftags(ngbfs(i))=false; end; end
if overflow
    warning('MATLAB:OVERFLOW', 'Buffers are too small to contain neighborhood in obtain_nring_surf.m.');
end

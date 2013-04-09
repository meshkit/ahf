function [sibhfs,manifold,oriented] = determine_sibling_halffaces_tet( nv, elems, varargin)
%DETERMINE_SIBLING_HALFFACE_TET Determine the sibling half-faces.
% DETERMINE_SIBLING_HALFFACE_TET(NV,ELEMS,SIBHFS) Determines the
% sibling half-faces.
%
%    SIBHFS = DETERMINE_SIBLING_HALFFACE_TET(NV,ELEMS)
%    SIBHFS = DETERMINE_SIBLING_HALFFACE_TET(NV,ELEMS,SIBHFS)
% computes mapping from each half-face to its sibling half-face.
%
%    SIBHFS = DETERMINE_SIBLING_HALFFACE_TET(NV,ELEMS,USESTRUCT)
% It will use struct for sibhfs if a logical variable USESTRUCT is present.
%  Otherwise, it uses integers for SIBHFS, and we assign three bits to local_face_id.

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html
%       for numbering convention of faces.

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,17],[1,1]),
%#codegen coder.typeof(int32(0), [inf,4],[1,1])}

% Table for vertices of each face.
hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
% Table for mapping each vertex to adjacent vertices.
v2av_tet  = int32([2,4,3; 1 3 4; 4 2 1; 3 1 2]);
% Table for local IDs of incident faces of each vertex.
v2f_tet   = int32([2 4 1; 1 3 2; 3 1 4; 4 2 3]);

next = int32([2,3,1]);
prev = int32([3 1 2]);

manifold=true; oriented=true;

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1, 'int32');
nelems = int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems=ii-1; break; end
    
    for jj=1:4
        vs = elems(ii,hf_tet(jj,:));
        v = max( vs, [], 2);
        is_index(v+1) = is_index(v+1)+1;
    end
end
is_index(1) = 1;
for ii=1:nv; is_index(ii+1) = is_index(ii) + is_index(ii+1); end

% Store dimensions of objects.
nf = nelems*12;

% v2hf stores mapping from each vertex to half-face ID.
v2hf_cid = nullcopy(zeros(nf,1, 'int32'));
v2hf_lfid = nullcopy(zeros(nf,1, 'int8'));
v2oe_v1 = nullcopy(zeros(nf, 1, 'int32'));
v2oe_v2 = nullcopy(zeros(nf, 1, 'int32'));

for ii=1:nelems
    for jj=1:4
        v = elems(ii,jj);
        av = elems(ii,v2av_tet(jj,:));
        
        for kk=1:3
            if v>av(kk) && v>av(next(kk))
                v2oe_v1(is_index(v)) = av(kk);
                v2oe_v2(is_index(v)) = av(next(kk));
                v2hf_cid(is_index(v)) = ii; 
                v2hf_lfid(is_index(v)) = v2f_tet(jj,kk);
                is_index(v) = is_index(v) + 1;
            end
        end
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

% Fill in sibhfs for each half-face.
if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    sibhfs = zeros(size(elems), 'int32');
elseif islogical(varargin{1})
    sibhfs = struct( 'cid', zeros(size(elems), 'int32'), ...
        'lfid', zeros(size(elems), 'int8'));
else
    sibhfs = varargin{1};
    assert( size(sibhfs,1)>=nelems && size(sibhfs,2)>=4);
    sibhfs(:,:) = 0;
end

for ii=1:nelems
    for jj=int32(1):4 % local face ID
        if isstruct(sibhfs) && sibhfs.cid(ii,jj) || ...
                ~isstruct(sibhfs) && sibhfs(ii,jj); 
            continue; 
        end
        
        vs = elems(ii, hf_tet(jj,:));     % list of vertices of face
        [v,imax] = max( vs, [], 2);
        
        first_cid = ii; first_lfid = int8(jj);
        prev_cid = first_cid; prev_lfid = first_lfid; 
        nhfs = int32(0);
        
        % Search for half-face in the opposite orientation
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == vs(prev(imax)) && v2oe_v2(index) == vs(next(imax))
                if isstruct(sibhfs)
                    sibhfs.cid(prev_cid, prev_lfid) = v2hf_cid(index);
                    sibhfs.lfid(prev_cid,prev_lfid) = v2hf_lfid(index);
                else
                    sibhfs( prev_cid, prev_lfid) = ...
                        clfids2hfid( v2hf_cid(index),v2hf_lfid(index));
                end
                prev_cid = v2hf_cid(index); prev_lfid = v2hf_lfid(index);
                nhfs = nhfs+1;
            end
        end
        
        % Check for halfface in the same orientation
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == vs(next(imax)) && v2oe_v2(index) == vs(prev(imax)) && ...
                    v2hf_cid(index)~=ii                
                if isstruct(sibhfs)
                    sibhfs.cid(prev_cid, prev_lfid) = v2hf_cid(index);
                    sibhfs.lfid(prev_cid,prev_lfid) = v2hf_lfid(index);
                else
                    sibhfs( prev_cid, prev_lfid) = ...
                        clfids2hfid( v2hf_cid(index),v2hf_lfid(index));
                end
                
                prev_cid = v2hf_cid(index); prev_lfid = v2hf_lfid(index);
                nhfs = nhfs+1;
                oriented = false;
            end
        end
        
        if prev_cid ~= first_cid
            % Close up the cycle
            if isstruct(sibhfs)
                sibhfs.cid(prev_cid, prev_lfid) = first_cid;
                sibhfs.lfid(prev_cid,prev_lfid) = first_lfid;
            else
                sibhfs( prev_cid, prev_lfid) = clfids2hfid( first_cid,first_lfid);
            end

            nhfs = nhfs+1;
        end
        
        if nargout>1 && manifold && nhfs>2
            manifold = false; oriented = false;
        end
    end
end
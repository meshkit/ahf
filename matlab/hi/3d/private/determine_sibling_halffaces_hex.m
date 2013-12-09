function sibhfs = determine_sibling_halffaces_hex( nv, elems, varargin) %#codegen
%DETERMINE_SIBLING_HALFFACES_HEX Determine the sibling half-face.
% DETERMINE_SIBLING_HALFFACES_HEX( NV, ELEMS, SIBHFS) Determines the
% sibling half-face.
%
% SIBHFS = DETERMINE_SIBLING_HALFFACE_HEX(NV,ELEMS)
% SIBHFS = DETERMINE_SIBLING_HALFFACE_HEX(NV,ELEMS,SIBHFS)
% computes mapping from each half-face to its sibling half-face.
%
% We assign three bits to local_face_id.

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering
%       convention of faces.
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,17],[1,1]),
%#codegen coder.typeof(int32(0), [inf,6],[1,1])}

% Table for vertices of each face.
hf_hex    = int32([1,4,3,2; 1,2,6,5; 2,3,7,6; 3,4,8,7; 1,5,8,4; 5,6,7,8]);

next = int32([2,3,4,1]);
prev = int32([4,1,2,3]);

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
nelems = int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems=ii-1; break; end
    
    for jj=1:6
        vs = elems(ii,hf_hex(jj,:));
        v = max( vs, [], 2);
        is_index(v+1) = is_index(v+1)+1;
    end
end
is_index(1) = 1;
for ii=1:nv; is_index(ii+1) = is_index(ii) + is_index(ii+1); end

% v2hf stores mapping from each vertex to half-face ID.
% v2oe stores mapping from each vertex to the encoding of the sibling
%     edges of each half-face.
%v2hf = nullcopy(zeros(is_index(nv+1),1,'int32'));
v2hf_cid = nullcopy(zeros(is_index(nv+1),1,'int32'));
v2hf_lfid = nullcopy(zeros(is_index(nv+1),1,'int8'));
v2oe_v1 = nullcopy(zeros(is_index(nv+1),1, 'int32'));
v2oe_v2 = nullcopy(zeros(is_index(nv+1),1, 'int32'));

for ii=1:nelems
    for jj=int32(1):6
        vs = elems(ii,hf_hex(jj,:));
        [v,kk] = max( vs, [], 2);
        
        v2oe_v1(is_index(v)) = vs( next(kk));
        v2oe_v2(is_index(v)) = vs( prev(kk));
        %v2hf(is_index(v)) = clfids2hfid(ii,jj);
        v2hf_cid(is_index(v))=ii;
        v2hf_lfid(is_index(v))=jj;
        is_index(v) = is_index(v)+1;
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

% Fill in sibhfs for each half-face.
if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    sibhfs = zeros(nelems,6, 'int32');
elseif islogical(varargin{1})
    sibhfs = struct( 'cid', zeros(size(elems), 'int32'), ...
        'lfid', zeros(nelems,6, 'int8'));
else
    sibhfs = varargin{1};
    assert( size(sibhfs,1)>=nelems && size(sibhfs,2)==6);
    sibhfs(:,:) = 0;
end

for ii=1:nelems
    for jj=int32(1):6 % local face ID
        if isstruct(sibhfs) && sibhfs.cid(ii,jj) || ...
                ~isstruct(sibhfs) && sibhfs(ii,jj); 
            continue; 
        end
        vs = elems(ii, hf_hex(jj,:));     % list of vertices of face
        [v,imax] = max( vs, [], 2);
        
        found = false;
        v1 = vs(prev(imax)); v2 = vs(next(imax));
        % Search for sibling half-face.
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == v1 && v2oe_v2(index) == v2
                if ~isstruct(sibhfs)
                    sibhfs(ii,jj) = clfids2hfid(v2hf_cid(index),v2hf_lfid(index));
                    sibhfs(v2hf_cid(index),v2hf_lfid(index)) = clfids2hfid(ii,jj);
                else
                    sibhfs.lfid(ii,jj) = v2hf_lfid(index);
                    sibhfs.cid(ii,jj) = v2hf_cid(index);
                    
                    sibhfs.lfid(v2hf_cid(index),v2hf_lfid(index)) = jj;
                    sibhfs.cid(v2hf_cid(index),v2hf_lfid(index)) = ii;
                end
                found = true;
                break;
            end
        end
        
        if ~found
            for index = is_index( v):is_index( v+1)-1
                if v2oe_v1(index) == v2 && v2oe_v2(index)==v1 && ...
                        v2hf_cid(index)~=ii
                    if nargin==3
                        error( 'Input mesh is not oriented.');
                    else
                        if ~isstruct(sibhfs)
                            sibhfs = zeros(0, 6, 'int32'); return;
                        else
                            sibhfs.lfid = zeros(size(elems), 'int8');
                            sibhfs.fid = zeros(size(elems), 'int32');
                        end
                    end
                end
            end
        end
    end
end
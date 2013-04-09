function sibhfs = determine_sibling_halffaces_pyramid( nv, elems, varargin) %#codegen
%DETERMINE_SIBLING_HALFFACE_PYRAMID Determine the sibling half-face.
% DETERMINE_SIBLING_HALFFACE_PYRAMID(NV,ELEMS,SIBHFS) Determines
% the sibling half-face.
%
% SIBHFS = DETERMINE_SIBLING_HALFFACE_PYRAMID(NV,ELEMS)
% SIBHFS = DETERMINE_SIBLING_HALFFACE_PYRAMID(NV,ELEMS,SIBHFS)
% computes mapping from each half-face to its sibling half-face.
%
% We assign three bits to local_face_id.
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,17],[1,1]),
%#codegen coder.typeof(int32(0), [inf,5],[1,1])}

% Table for vertices of each face.
hf_pyr    = int32([1,4,3,2; 1,2,5,0; 2,3,5,0; 3,4,5,0; 4,1,5,0]);

next = int32([2,3,1 0; 2,3,4,1]);
prev = int32([3 1 2 0; 4,1,2,3]);

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1, 'int32');
nelems = int32(size(elems,1));

for ii=1:nelems
    if elems(ii,1)==0; nelems=ii-1; break; end

    for jj=1:5
        nvpf = 3+(jj==1);
        vs = elems(ii,hf_pyr(jj,1:nvpf));
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
v2hf_cid = nullcopy(zeros(is_index(nv+1),1, 'int32'));
v2hf_lfid = nullcopy(zeros(is_index(nv+1),1, 'int8'));

v2oe_v1 = nullcopy(zeros(is_index(nv+1),1, 'int32'));
v2oe_v2 = nullcopy(zeros(is_index(nv+1),1, 'int32'));

for ii=1:nelems
    for jj=1:5
        nvpf = 3+(jj<4);
        vs = elems(ii,hf_pyr(jj,1:nvpf));
        [v,kk] = max( vs, [], 2);
        
        v2oe_v1(is_index(v)) = vs( next(nvpf-2,kk)); 
        v2oe_v2(is_index(v)) = vs( prev(nvpf-2,kk));
        %v2hf(is_index(v)) = clfids2hfid(ii,jj);
        
        v2hf_cid(is_index(v)) = ii;
        v2hf_lfid(is_index(v)) = jj;

        is_index(v) = is_index(v)+1;
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
    assert( size(sibhfs,1)>=nelems && size(sibhfs,2)==5);
    sibhfs(:,:) = int32(0);
end

for ii=1:nelems
    for jj=int32(1):5 % local face ID
       if isstruct(sibhfs) && sibhfs.cid(ii,jj) || ...
                ~isstruct(sibhfs) && sibhfs(ii,jj); 
            continue; 
        end
        nvpf = 3+(jj==1);
        vs = elems(ii, hf_pyr(jj,1:nvpf));  % list of vertices of face
        [v,imax] = max( vs, [], 2);

        found = false;
        v1 = vs(prev(nvpf-2,imax)); v2 = vs(next(nvpf-2,imax));
        % Search for sibling half-face.
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == v1 && v2oe_v2(index) == v2 
                
                if isstruct(sibhfs)
                    sibhfs.lfid(ii,jj) = v2hf_lfid(index);
                    sibhfs.cid(ii,jj) = v2hf_cid(index);
                    
                    sibhfs.lfid(v2hf_cid(index),v2hf_lfid(index)) = ii;
                    sibhfs.cid(v2hf_cid(index),v2hf_lfid(index)) = jj;
                else
                    sibhfs(ii,jj) = clfids2hfid(v2hf_cid(index),v2hf_lfid(index));
                    sibhfs(v2hf_cid(index),v2hf_lfid(index)) = clfids2hfid(ii,jj);
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
                            sibhfs = zeros(0, 5, 'int32'); return;
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
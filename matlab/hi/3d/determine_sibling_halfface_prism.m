function sibhfs = determine_sibling_halfface_prism( nv, elems, sibhfs) %#codegen
%DETERMINE_SIBLING_HALFFACE_PRISM Determine the sibling half-face.
% DETERMINE_SIBLING_HALFFACE_PRISM(NV,ELEMS,SIBHFS) Determines
% the sibling half-face.
%
% SIBHFS = DETERMINE_SIBLING_HALFFACE_PRISM(NV,ELEMS)
% SIBHFS = DETERMINE_SIBLING_HALFFACE_PRISM(NV,ELEMS,SIBHFS)
% Computes mapping from each half-face to its sibling half-face.
%
% We assign three bits to local_face_id.

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering
%       convention of faces.

% Table for vertices of each face.
hf_pri = int32([1,2,5,4; 2,3,6,5; 3,1,4,6; 1 3 2 0; 4 5 6 0]);

next = int32([2,3,1 0; 2,3,4,1]);
prev = int32([3 1 2 0; 4,1,2,3]);

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
nelems = int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems=ii-1; break; end

    for jj=1:5
        nvpf = 3+(jj<4);
        vs = elems(ii,hf_pri(jj,1:nvpf));
        v = max( vs, [], 2);
        is_index(v+1) = is_index(v+1)+1;
    end
end
is_index(1) = 1;
for ii=1:nv; is_index(ii+1) = is_index(ii) + is_index(ii+1); end

% v2hf stores mapping from each vertex to half-face ID.
% v2oe stores mapping from each vertex to the encoding of the sibling
%     edges of each half-face.
v2hf = nullcopy(zeros(is_index(nv+1),1,'int32'));
v2oe_v1 = nullcopy(zeros(is_index(nv+1),1, 'int32'));
v2oe_v2 = nullcopy(zeros(is_index(nv+1),1, 'int32'));

for ii=1:nelems
    for jj=int32(1):5
        nvpf = 3+(jj<4);
        vs = elems(ii,hf_pri(jj,1:nvpf));
        [v,kk] = max( vs, [], 2);
        
        v2oe_v1(is_index(v)) = vs( next(nvpf-2,kk)); 
        v2oe_v2(is_index(v)) = vs( prev(nvpf-2,kk));
        v2hf(is_index(v)) = clfids2hfid(ii,jj);
        is_index(v) = is_index(v)+1;
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

% Fill in sibhfs for each half-face.
if nargin<3 || isempty(sibhfs)
    sibhfs = zeros(size(elems,1), 5, 'int32');
else
    assert( size(sibhfs,1)>=nelems && size(sibhfs,2)>=5);
    sibhfs(:) = 0;
end

for ii=1:nelems
    for jj=int32(1):5 % local face ID
        if sibhfs(ii,jj); continue; end
        nvpf = 3+(jj<4);
        vs = elems(ii, hf_pri(jj,1:nvpf));  % list of vertices of face
        [v,imax] = max( vs, [], 2);
        
        found = false;
        v1 = vs(prev(nvpf-2,imax)); v2 = vs(next(nvpf-2,imax));
        % Search for sibling half-face.
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == v1 && v2oe_v2(index) == v2 
                sib = v2hf(index);
                sibhfs(ii,jj) = sib;
                
                sibhfs(hfid2cid(sib),hfid2lfid(sib)) = clfids2hfid(ii,jj);
                found = true;
                break;
            end
        end

        if ~found
            for index = is_index( v):is_index( v+1)-1
                if v2oe_v1(index) == v2 && v2oe_v2(index)==v1 && ...
                        hfid2cid(v2hf(index))~=ii
                    if nargin==3
                        error( 'Input mesh is not oriented.');
                    else
                        sibhfs = zeros(0, 5, 'int32'); return;
                    end
                end
            end
        end
    end
end

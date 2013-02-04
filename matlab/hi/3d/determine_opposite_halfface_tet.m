function opphfs = determine_opposite_halfface_tet( nv, elems, opphfs) %#codegen
%DETERMINE_OPPOSITE_HALFFACE_TET Determine the opposite half-face.
% DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS,OPPHFS) Determines the
% opposite half-face.
%
% OPPHFS = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS)
% OPPHFS = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS,OPPHFS)
% computes mapping from each half-face to its opposite half-face.
%
% We assign three bits to local_face_id.

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering
%       convention of faces.

% Table for vertices of each face.
hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);

next = int32([2,3,1]);
prev = int32([3 1 2]);

%% First, build is_index to store starting position for each vertex.
is_index = zeros(nv+1,1,'int32');
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

% v2hf stores mapping from each vertex to half-face ID.
% v2oe stores mapping from each vertex to the encoding of the opposite
%     edge of each half-face..
v2hf = nullcopy(zeros(is_index(nv+1),1,'int32'));
v2oe_v1 = nullcopy(zeros(is_index(nv+1),1, 'int32'));
v2oe_v2 = nullcopy(zeros(is_index(nv+1),1, 'int32'));

for ii=1:nelems
    for jj=int32(1):4
        vs = elems(ii,hf_tet(jj,:));
        [v,kk] = max( vs, [], 2);
        
        v2oe_v1(is_index(v)) = vs( next(kk)); 
        v2oe_v2(is_index(v)) = vs( prev(kk));
        v2hf(is_index(v)) = ii*8 + jj-1;
        is_index(v) = is_index(v)+1;
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

% Fill in opphfs for each half-face.
if nargin<3 || isempty(opphfs)
    opphfs = zeros(size(elems,1),4,'int32');
else
    assert( size(opphfs,1)>=nelems && size(opphfs,2)>=4);
    opphfs(:) = 0;
end

for ii=1:nelems
    for jj=int32(1):4 % local face ID
        if opphfs(ii,jj); continue; end
        vs = elems(ii, hf_tet(jj,:));     % list of vertices of face
        [v,imax] = max( vs, [], 2);

        found = false;
        v1 = vs(prev(imax)); v2 = vs(next(imax));
        % Search for opposite half-face.
        for index = is_index( v):is_index( v+1)-1
            if v2oe_v1(index) == v1 && v2oe_v2(index) == v2 
                opp = v2hf(index);
                opphfs(ii,jj) = opp;
                
                % opphfs(hfid2cid(opp),hfid2lfid(opp)) = ii*8+jj-1;
                lfid0=mod(opp,8); opphfs(bitshift(uint32(opp),-3),lfid0+1) = ii*8+jj-1;
                
                found = true;
                break;
            end
        end

        if ~found
            for index = is_index( v):is_index( v+1)-1
                % if v2oe(index) == code && hfid2cid(v2hf(index))~=ii
                if v2oe_v1(index) == v2 && v2oe_v2(index)==v1 && ...
                        ( v2hf(index)<ii*8 || v2hf(index)>ii*8+7)
                    if nargin==3
                        error( 'Input mesh is not oriented.');
                    else
                        opphfs = zeros(0, 4, 'int32'); return;
                    end
                end
            end
        end
    end
end

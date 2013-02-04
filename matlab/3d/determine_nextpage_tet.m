function nxtpg = determine_nextpage_tet( nv, elems, nxtpg) %#codegen
%DETERMINE_OPPOSITE_HALFFACE_TET Determine the opposite half-face.
% DETERMINE_NEXTPAGE_TET(NV,ELEMS,NXTPG) Determines the opposite
% half-face. The following explains the input and output arguments
%
% NXTPG = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS)
% NXTPG = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS,NXTPG)
% Computes mapping from each half-face to its opposite half-face.
%
% See also DETERMINE_OPPOSITE_HALFFACE_TET.

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering
%       convention of faces.

% Table for vertices of each face.
hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
% Table for mapping each vertex to adjacent vertices.
v2av_tet  = int32([2,4,3; 1 3 4; 4 2 1; 3 1 2]);
% Table for local IDs of incident faces of each vertex.
v2f_tet   = int32([2 4 1; 1 3 2; 3 1 4; 4 2 3]);

next = int32([2,3,1]);
prev = int32([3 1 2]);

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
for ii=1:nv
    is_index(ii+1) = is_index(ii) + is_index(ii+1);
end

% Hard limits on the number of elems due to the use of double.
assert( nv<2^26 && nelems<2^26);

% Store dimensions of objects.
nf = nelems*12;

% v2hf stores mapping from each vertex to half-face ID.
v2hf = nullcopy(zeros(nf,1, 'int32'));
% v2oe stores mapping from each vertex to the encoding of the opposite
%     edge of each half-face..
v2oe  = nullcopy(zeros(nf,1, 'double'));

% Edges are encoded using double-precision floating-point numbers, which
% have 52 digits of accuracy, so each vertex would have 26 digits.
EC_SHIFT = double(67108864);   % 2^26.
for ii=1:nelems
    for jj=1:4
        v = elems(ii,jj);
        av = elems(ii,v2av_tet(jj,:));
        
        for kk=1:3
            if v>av(kk) && v>av(next(kk))
                v2oe(is_index(v)) = double(av(kk))*EC_SHIFT+double(av(next(kk)));
                v2hf(is_index(v)) = ii*8 + v2f_tet(jj,kk)-1;
                is_index(v) = is_index(v) + 1;
            end
        end
    end
end
for ii=nv-1:-1:1; is_index(ii+1) = is_index(ii); end
is_index(1)=1;

% Fill in nxtpg for each half-face.
if nargin<3 || isempty(nxtpg)
    nxtpg = zeros(size(elems), 'int32');
else
    assert( size(nxtpg,1)>=nelems && size(nxtpg,2)>=4);
    nxtpg(:,:) = 0;
end

for ii=1:nelems
    for jj=1:4 % local face ID
        if nxtpg(ii,jj); continue; end
        vs = elems(ii, hf_tet(jj,:));     % list of vertices of face
        [v,imax] = max( vs, [], 2);
        
        first_pageid = ii*8+jj-1;
        prev_pageid = first_pageid;
        
        code = double(vs(prev(imax)))*EC_SHIFT+double(vs(next(imax)));
        % Search for opposite half-face.
        for index = is_index( v):is_index( v+1)-1
            if v2oe(index) == code
                nxtpg(hfid2cid(prev_pageid),hfid2lfid(prev_pageid)) = v2hf(index);
                prev_pageid = v2hf(index);
            end
        end
        
        code = double(vs(next(imax)))*EC_SHIFT+double(vs(prev(imax)));
        for index = is_index( v):is_index( v+1)-1
            if v2oe(index) == code && hfid2cid(v2hf(index))~=ii
                nxtpg(hfid2cid(prev_pageid),hfid2lfid(prev_pageid)) = v2hf(index);
                prev_pageid = v2hf(index);
            end
        end
        
        if prev_pageid ~= first_pageid
            % Close up the cycle
            nxtpg(hfid2cid(prev_pageid),hfid2lfid(prev_pageid)) = first_pageid;
        end
    end
end

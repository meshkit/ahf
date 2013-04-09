function sibhfs = determine_sibling_halffaces_mixed( nv, elems, sibhfs) %#codegen
% Determine the sibling half-faces of a mixed mesh.
%
% SIBHFS = DETERMINE_SIBLING_HALFFACE_MIXED(NV,ELEMS)
% SIBHFS = DETERMINE_SIBLING_HALFFACE_MIXED(NV,ELEMS,SIBHFS)
%    computes a mapping from each half-face to its sibling half-face.
%
% At input, ELEMS is a column vector, with format
%     [e1_nv, e1_v1,e1_v2,..., e2_nv, e2_v1,e2_v2, ...].
% At output, SIBHFS is a column vector, with format
%     [e1_nf, e1_opphf1,e1_opphf2,..., e2_nf, e2_opphf1, e2_opphf2, ...].
%
% A half-face ID is a two-tuple <element_ID,local_face_ID-1> encoded 
%     in an integer. The element_ID uses the higher bits and
%     (local_face_ID-1) uses the last three bits.
%
% See also DETERMINE_INCIDENT_HALFFACES, DETERMINE_OFFSETS_MIXED_ELEMS, 

% Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering
%       convention of faces.

%% Tetrahedral element
% Table for vertices of each face.
hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
% Table for mapping each vertex to adjacent vertices.
v2av_tet  = int32([2,4,3; 1,3,4; 4,2,1; 3,1,2]);
% Table for local IDs of incident faces of each vertex.
v2f_tet   = int32([2,4,1; 1,3,2; 3,1,4; 4,2,3]);

%% Pyramid element
% Table for vertices of each face.
hf_pyr    = int32([1,4,3,2; 1,2,5,0; 2,3,5,0; 3,4,5,0; 4,1,5,0]);
% Table for mapping each vertex to incident vertices
v2av_pyr  = int32([2,5,4,0; 3,5,1,0; 4,5,2,0; 1,5,3,0; 1,2,3,4]);
% Table for local IDs of incident faces of each vertex.
v2f_pyr   = int32([2,5,1,0; 3,2,1,0; 4,3,1,0; 5,4,1,0; 2,3,4,5]);

%% Prismatic element
% Table for vertices of each face.
hf_pri    = int32([1,2,5,4; 2,3,6,5; 3,1,4,6; 1 3 2 0; 4 5 6 0]);
% Table for mapping each vertex to incident vertices
v2av_pri  = int32([2,4,3; 3,5,1; 1,6,2; 6,1,5; 4,2,6; 5,3,4]);
% Table for local IDs of incident faces of each vertex.
v2f_pri   = int32([1,3,4; 2,1,4; 3,2,4; 3,1,5; 1,2,5; 2,3,5]);

%% Hex element
% Table for vertices of each face.
hf_hex    = int32([1,4,3,2; 1,2,6,5; 2,3,7,6; 3,4,8,7; 1,5,8,4; 5,6,7,8]);
% Table for mapping each vertex to incident vertices
v2av_hex  = int32([2,5,4; 3,6,1; 4,7,2; 1,8,3; 6,8,1; 7,5,2; 8,6,3; 5,7,4]);
% Table for local IDs of incident faces of each vertex.
v2f_hex   = int32([2,5,1; 3,2,1; 4,3,1; 5,4,1; 6,5,2; 6,2,3; 6,3,4; 6,4,5]);

if nargin<3; 
    sibhfs = zeros(size(elems,1),1,'int32'); 
else
    sibhfs(:) = 0;
end

%% First, build is_index_v to store starting position for each vertex.
nf = int32(0);
is_index_v = zeros(nv+1,1,'int32'); 
offset=int32(1); nelems=int32(0);
while offset<size(elems,1)
    vs_elem = elems(offset+1:offset+elems(offset));
    is_index_v(vs_elem+1) = is_index_v(vs_elem+1) + 3;
    nf = nf + 3*elems(offset);
    
    if elems(offset)==5 || elems(offset)==14 %pyramid
        is_index_v(vs_elem(5)+1) = is_index_v(vs_elem(5)+1) + 1;
        nf = nf + 1;
    end
    
    nelems = nelems + 1;
    offset = offset+elems(offset)+1;
end
is_index_v(1) = 1;
for ii=1:nv
    is_index_v(ii+1) = is_index_v(ii) + is_index_v(ii+1);
end

% v2hf stores mapping from each vertex to half-face ID.
% v2oe_v1 && v2oe_v2 stores mapping from each vertex to the encoding of 
%     the sibling edges in its incident half-face.
v2hf = nullcopy(zeros(nf,1,'int32'));
v2oe_v1 = nullcopy(zeros(nf, 1, 'int32'));
v2oe_v2 = nullcopy(zeros(nf, 1, 'int32'));

is_index_f = zeros(nelems+1,1,'int32'); is_index_f(1) = 1;
is_index_o = zeros(nelems+1,1,'int32'); is_index_o(1) = 1;

offset=int32(1); nopphf = int32(0);
for ii=1:nelems
    nvpE = elems(offset);
    
    switch (nvpE)
        case {4,10}
            vs_elem = elems(offset+1:offset+4);
            start_index = is_index_v( vs_elem);
            is_index_v( vs_elem) = is_index_v( vs_elem) + 3;
            
            for jj=1:4
                vs = vs_elem(v2av_tet(jj,:));
                
                v2oe_v1(start_index(jj):start_index(jj)+2)  = [vs(1); vs(2); vs(3)];
                v2oe_v2(start_index(jj):start_index(jj)+2)  = [vs(2); vs(3); vs(1)];
                v2hf(start_index(jj):start_index(jj)+2) = clfids2hfid(ii, v2f_tet(jj,:));
            end
            
            nfpE = int32(4);
        case {5,14}
            vs_elem = elems(offset+1:offset+5);
            start_index = is_index_v( vs_elem);
            is_index_v( vs_elem) = is_index_v( vs_elem) + 3;
            
            for jj=1:4
                vs = vs_elem(v2av_pyr(jj,1:3));
                
                v2oe_v1(start_index(jj):start_index(jj)+2)  = [vs(1); vs(2); vs(3)];
                v2oe_v2(start_index(jj):start_index(jj)+2)  = [vs(2); vs(3); vs(1)];
                v2hf(start_index(jj):start_index(jj)+2) = clfids2hfid(ii, v2f_pyr(jj,1:3));
            end
            
            is_index_v( vs_elem(5)) = is_index_v(vs_elem(5)) + 1;
            vs = vs_elem(v2av_pyr(5,:));
            v2oe_v1(start_index(5):start_index(5)+3)  = [vs(1); vs(2); vs(3); vs(4)];
            v2oe_v2(start_index(5):start_index(5)+3)  = [vs(2); vs(3); vs(4); vs(1)];
            v2hf(start_index(5):start_index(5)+3) = clfids2hfid(ii, v2f_pyr(5,:));
            
            nfpE = int32(5);
        case {6,15,18}
            vs_elem = elems(offset+1:offset+6);
            start_index = is_index_v( vs_elem);
            is_index_v( vs_elem) = is_index_v( vs_elem) + 3;
            
            for jj=1:6
                vs = vs_elem(v2av_pri(jj,:));
                
                v2oe_v1(start_index(jj):start_index(jj)+2)  = [vs(1); vs(2); vs(3)];
                v2oe_v2(start_index(jj):start_index(jj)+2)  = [vs(2); vs(3); vs(1)];
                v2hf(start_index(jj):start_index(jj)+2) = clfids2hfid(ii, v2f_pri(jj,:));
            end
            
            nfpE = int32(5);
        case {8,20,27}
            vs_elem = elems(offset+1:offset+8);
            start_index = is_index_v( vs_elem);
            is_index_v( vs_elem) = is_index_v( vs_elem) + 3;
            
            for jj=1:8
                vs = vs_elem(v2av_hex(jj,:));
                
                v2oe_v1(start_index(jj):start_index(jj)+2)  = [vs(1); vs(2); vs(3)];
                v2oe_v2(start_index(jj):start_index(jj)+2)  = [vs(2); vs(3); vs(1)];
                v2hf(start_index(jj):start_index(jj)+2) = clfids2hfid(ii, v2f_hex(jj,:));
            end
            nfpE = int32(6);
        otherwise
            nfpE = int32(0); %#ok<NASGU>
            error('Unrecognized element type.');
    end
    
    offset = offset+nvpE+1;
    nopphf = nopphf + nfpE;
    is_index_o(ii+1) = is_index_o(ii) + nfpE+1;
    is_index_f(ii+1) = is_index_f(ii) + nvpE+1;
end
is_index_v(2:nv) = is_index_v(1:nv-1); is_index_v(1)=1;

% Fill in sibhfs for each half-face.
if isempty(sibhfs)
    sibhfs = zeros(nopphf+nelems,1,'int32');
else
    assert(int32(size(sibhfs,1))>=nopphf+nelems);
    sibhfs(:) = int32(0);
end

offset=int32(1); offset_ohf=int32(1);
for ii=1:nelems
    nvpE = elems(offset);
    
    switch (nvpE)
        case {4,10}
            vs_elem = elems(offset+1:offset+4);
            nfpE = int32(4);
            for jj=1:nfpE % local face ID
                if sibhfs(offset_ohf+jj); continue; end
                vs = vs_elem(hf_tet(jj,:));     % list of vertices of face
                
                found = false;
                % Search for sibling half-face.
                for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                    if v2oe_v1(index) == vs(3) && v2oe_v2(index) == vs(2) 
                        sib = v2hf(index);
                        sibhfs(offset_ohf+jj) = sib;
                        
                        k = is_index_o(hfid2cid(sib)) + hfid2lfid(sib);
                        if sibhfs(k)~=0
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                        sibhfs(k) = clfids2hfid(ii,jj);
                        
                        found = true;
                        break;
                    end
                end
                
                % check whether the surface is oriented
                if ~found
                    for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                        if v2oe_v1(index) == vs(2) && v2oe_v2(index) == vs(3) && ...
                                hfid2cid(v2hf(index))~=ii
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                    end
                end
            end
        case {5,14}
            vs_elem = elems(offset+1:offset+5);
            
            nfpE = int32(5);
            for jj=1:nfpE % local face ID
                if sibhfs(offset_ohf+jj); continue; end
                nvpf = 3+(jj==1);
                
                vs = vs_elem(hf_pyr(jj,1:nvpf));  % list of vertices of face
                
                found = false;
                % Search for sibling half-face.
                for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                    if v2oe_v1(index) == vs(nvpf) && v2oe_v2(index) == vs(2) 
                        sib = v2hf(index);
                        sibhfs(offset_ohf+jj) = sib;
                        
                        k = is_index_o(hfid2cid(sib)) + hfid2lfid(sib);
                        if sibhfs(k)~=0
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                        sibhfs(k) = clfids2hfid(ii,jj);
                        
                        found = true;
                        break;
                    end
                end
                
                % check whether the surface is oriented
                if ~found
                    for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                        if v2oe_v1(index) == vs(2) && v2oe_v2(index) == vs(nvpf) && ...
                                hfid2cid(v2hf(index))~=ii
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                    end
                end
            end
        case {6,15,18}
            nfpE = int32(5);
            vs_elem = elems(offset+1:offset+6);
            
            for jj=1:nfpE % local face ID
                if sibhfs(offset_ohf+jj); continue; end
                nvpf = 3+(jj<4);
                vs = vs_elem(hf_pri(jj,1:nvpf));  % list of vertices of face
                
                found = false;
                % Search for sibling half-face.
                for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                    if v2oe_v1(index) == vs(nvpf) && v2oe_v2(index) == vs(2) 
                        sib = v2hf(index);
                        sibhfs(offset_ohf+jj) = sib;
                        
                        k = is_index_o(hfid2cid(sib)) + hfid2lfid(sib);
                        if sibhfs(k)~=0
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                        sibhfs(k) = clfids2hfid(ii,jj);
                        
                        found = true;
                        break;
                    end
                end
                
                if ~found
                    for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                        if v2oe_v1(index) == vs(2) && v2oe_v2(index) == vs(nvpf) && ...
                                hfid2cid(v2hf(index))~=ii
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                    end
                end
            end
        case {8,20,27}
            nfpE = int32(6);
            vs_elem = elems(offset+1:offset+8);
            
            for jj=1:nfpE % local face ID
                if sibhfs(ii,jj); continue; end
                vs = vs_elem(hf_hex(jj,:));     % list of vertices of face
                
                found = false;
                % Search for sibling half-face.
                for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                    if v2oe_v1(index) == vs(4) && v2oe_v2(index) == vs(2)
                        sib = v2hf(index);
                        sibhfs(offset_ohf+jj) = sib;
                        
                        k = is_index_o(hfid2cid(sib)) + hfid2lfid(sib);
                        if sibhfs(k)~=0
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                        sibhfs(k) = clfids2hfid(ii,jj);
                        
                        found = true;
                        break;
                    end
                end
                
                if ~found
                    for index = is_index_v( vs(1)):is_index_v( vs(1)+1)-1
                        if v2oe_v1(index) == vs(2) && v2oe_v2(index) == vs(4) && ...
                                hfid2cid(v2hf(index))~=ii
                            if nargin==3
                                error( 'Input mesh is not oriented.');
                            else
                                sibhfs = zeros(0,1,'int32'); return;
                            end
                        end
                    end
                end
            end
        otherwise
            nfpE = int32(0); %#ok<NASGU>
            error('Unrecognized element type.');
    end
    
    offset = offset + nvpE + 1;
    sibhfs(offset_ohf) = nfpE;
    offset_ohf = offset_ohf + nfpE + 1;
end

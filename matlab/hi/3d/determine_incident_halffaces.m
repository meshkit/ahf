function v2hf = determine_incident_halffaces(elems, sibhfs, v2hf)  %#codegen
%DETERMINE_INCIDENT_HALFFACES Determine an incident half-faces.
% DETERMINE_INCIDENT_HALFFACES(ELEMS,SIBHFS,V2HF) Determines an
% incident half-faces of each vertex. Give higher priorities to border
% faces. The following explains the inputs and outputs.
%
% Input:  ELEMS:  matrix of size mx4 storing element connectivity
%         SIBHFS: matrix of size mx4 storing opposite half-faces
%
% Output: V2HF:   array of size equal to number of vertices.
%
% See also DETERMINE_INCIDENT_HALFEDGES, DETERMINE_INCIDENT_HALFVERTS

% Table for local IDs of incident faces of each vertex.
v2f_tet   = int32([2 4 1; 1 3 2; 3 1 4; 4 2 3]);
v2f_pyr   = int32([2,5,1,0; 3,2,1,0; 4,3,1,0; 5,4,1,0; 2,3,4,5]);
v2f_pri   = int32([1,3,4; 2,1,4; 3,2,4; 3,1,5; 1,2,5; 2,3,5]);
v2f_hex   = int32([2,5,1; 3,2,1; 4,3,1; 5,4,1; 6,5,2; 6,2,3; 6,3,4; 6,4,5]);

% We use three bits for local-face ID.
SHIFT = int32(8);

if size(elems,2)==1
    assert( size(sibhfs,2)==1);
    % Mixed elements
    if nargin<3;
        % Set nv to maximum value in elements
        nv = int32(0); offset=int32(1);
        while offset < size(elems,1)
            for jj=1:elems(offset)
                if elems(offset+jj)>nv; nv = elems(offset+jj); end
            end
            
            offset = offset+elems(offset)+1;
        end
        
        v2hf = zeros( nv, 1, 'int32');
    else
        nv = length(v2hf);
        v2hf(:) = 0;
    end
    
    isborder = determine_border_vertices_vol(nv, elems, sibhfs);
    
    offset=int32(1); offset_o=int32(1); ii = int32(1);
    while offset < size(elems,1)
        switch elems(offset)
            case {4,10}
                % Tetrahedral
                for jj=1:4
                    v = elems(offset+jj);
                    
                    if v2hf(v)==0
                        for kk=1:3
                            if ~isborder(v) || sibhfs( offset_o+v2f_tet(jj,kk))==0
                                v2hf(v) = ii*SHIFT + v2f_tet(jj,kk) - 1;
                            end
                        end
                    end
                end
            case {5,14}
                % Pyramid
                for jj=1:5
                    v = elems(offset+jj);
                    
                    if v2hf(v)==0
                        for kk=1:3+(jj==4)
                            if ~isborder(v) || sibhfs( offset_o+v2f_pyr(jj,kk))==0
                                v2hf(v) = ii*SHIFT + v2f_pyr(jj,kk) - 1;
                            end
                        end
                    end
                end
            case {6,15,18}
                % Prism
                for jj=1:6
                    v = elems(offset+jj);
                    
                    if v2hf(v)==0
                        for kk=1:3
                            if ~isborder(v) || sibhfs( offset_o+v2f_pri(jj,kk))==0
                                v2hf(v) = ii*SHIFT + v2f_pri(jj,kk) - 1;
                            end
                        end
                    end
                end
            case {8,20,27}
                % Hexahedral
                for jj=1:8
                    v = elems(offset+jj);
                    
                    if v2hf(v)==0
                        for kk=1:4
                            if ~isborder(v) || sibhfs( offset_o+v2f_hex(jj,kk))==0
                                v2hf(v) = ii*SHIFT + v2f_hex(jj,kk) - 1;
                            end
                        end
                    end
                end
            otherwise
                error('unsupported element type');
        end
        
        ii = ii + 1;
        offset = offset+elems(offset)+1;
        offset_o = offset_o + sibhfs(offset_o) + 1;
    end
else
    nvpE = int32(size(elems,2));
    % Construct a vertex to halfedge mapping.
    if nargin<3;
        % Set nv to maximum value in elements
        nv = int32(0);
        ii = int32(1);
        while ii<=int32(size(elems,1))
            if elems(ii,1)==0; break; end
            
            for jj=1:nvpE
                if elems(ii,jj)>nv; nv = elems(ii,jj); end
            end
            ii = ii + 1;
        end
        
        v2hf = zeros( nv, 1, 'int32');
    else
        nv = length(v2hf);
        v2hf(:) = 0;
    end
    
    % Table for local IDs of incident faces of each vertex.
    switch nvpE
        case {4,10}
            ncvpE = int32(4);
            v2f = v2f_tet;
        case {5,14}
            ncvpE = int32(5);
            v2f = v2f_pyr;
        case {6,15,18}
            ncvpE = int32(6);
            v2f = v2f_pri;
        case {8,20,27}
            ncvpE = int32(8);
            v2f = v2f_hex;
        otherwise
            error('Unsupported element type');
            ncvpE = int32(0); v2f = v2f_hex; %#ok<UNRCH>
    end
    
    isborder = determine_border_vertices_vol(nv, elems, sibhfs);
    
    % Construct a vertex-to-halfface mapping.
    ii = int32(1);
    while ii<=int32(size(elems,1))
        if elems(ii,1)==0; break; end
        for jj=1:ncvpE
            v = elems(ii,jj);
            if v==0; break; end
            
            if v2hf(v)==0
                for kk=1:(3+(size(v2f,2)>3 && v2f(jj,end)))
                    if ~isborder(v) || sibhfs( ii,v2f(jj,kk))==0
                        v2hf(v) = ii*SHIFT + v2f(jj,kk) - 1;
                    end
                end
            end
        end
        ii=ii+1;
    end
end

function isborder = determine_border_vertices_surf(nv, elems, varargin) %#codegen
%DETERMINE_BORDER_VERTICES Determine border vertices of a surface mesh.
% DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,SIBHES,ISBORDER) Determines
% border vertices of a surface mesh. Returns bitmap of border vertices.
%
% Example
%   ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS)
%   ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,SIBHES)
%   ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,SIBHES,ISBORDER)
%
% See also DETERMINE_BORDER_VERTICES_CURV, DETERMINE_BORDER_VERTICES_VOL

if nargin<3; 
    sibhes = determine_sibling_halfedges(nv, elems); 
else
    sibhes = varargin{1};
end
if nargin<4; 
    isborder = false(nv,1); 
else
    isborder = varargin{2};
end

he_tri3 = int32([1,2; 2 3; 3 1]);
he_tri6 = int32([1,4,2; 2,5,3; 3,6,1]);
he_tri10 = int32([1,4,5,2; 2,6,7,3; 3,8,9,1]);

switch size(elems,2)
    case 3 % TRI-3
        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            for jj=1:3
                if sibhes(ii,jj) == 0
                    isborder( elems(ii,he_tri3(jj,:))) = true;
                end
            end
        end
    case 6 % TRI-6
        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            for jj=1:3
                if sibhes(ii,jj) == 0
                    isborder( elems(ii,he_tri6(jj,:))) = true;
                end
            end
        end
    case 10 % TRI-10
        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            for jj=1:3
                if sibhes(ii,jj) == 0
                    isborder( elems(ii,he_tri10(jj,:))) = true;
                end
            end
        end
    case 4 % QUAD-4
        he_quad4 = int32([1,2; 2 3; 3, 4; 4, 1]);

        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            if elems(ii,4)==0
                for jj=1:3
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_tri3(jj,:))) = true;
                    end
                end
            else
                for jj=1:4
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_quad4(jj,:))) = true;
                    end
                end
            end
        end
    case 9 % QUAD-9
        he_quad9 = int32([1,5,2; 2,6,3; 3,7,4; 4,8,1]);
        
        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            if elems(ii,7)==0
                for jj=1:3
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_tri6(jj,:))) = true;
                    end
                end
            else
                for jj=1:4
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_quad9(jj,:))) = true;
                    end
                end
            end
        end
    case 16 % QUAD-16
        he_quad16 = int32([1,5,6,2; 2,7,8,3; 3,9,10,4; 4,11,12,1]);
        
        for ii=1:int32(size(elems,1))
            if elems(ii,1)==0; break; end

            if elems(ii,11)==0
                for jj=1:3
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_tri10(jj,:))) = true;
                    end
                end
            else
                for jj=1:4
                    if sibhes(ii,jj) == 0
                        isborder( elems(ii,he_quad16(jj,:))) = true;
                    end
                end
            end
        end
    otherwise
        
end
end

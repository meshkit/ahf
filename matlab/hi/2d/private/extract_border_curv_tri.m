function [b2v, bdedgs, edgmap, v2b] = extract_border_curv_tri...
    (nv, tris, flabel, sibhes, inwards) %#codegen
%EXTRACT_BORDER_CURV_TRI Extract border vertices and edges. 
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_TRI(NV,TRIS,FLABEL,SIBHES,INWARDS)
% Extract border vertices and edges of triangle mesh. Return list of border 
% vertex IDs and list of border edges. Edges between faces with different 
% labels are also considered as border edges, and in this case only the 
% halfedge with smaller label IDs are returned. The following explains the
% input and output arguments.
%
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_TRI(NV,TRIS)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_TRI(NV,TRIS,FLABEL)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_TRI(NV,TRIS,FLABEL,SIBHES)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_TRI(NV,TRIS,FLABEL,SIBHES,INWARDS)
% NV: specifies the number of vertices.
% TRIS: contains the connectivity.
% FLABEL: contains a label for each face.
% SIBHES: contains the opposite half-edges.
% INWARDS: specifies whether the edge normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDEDGS: is connectivity of border edges.
% EDGMAP: stores mapping to halfedge ID
%
% See also EXTRA_BORDER_CURV

isborder = false(nv,1);
visited=false(nv,1);

if nargin>=5 && inwards
    % List vertices in counter-clockwise order, so that edges are inwards.
    he_tri = int32([1,2; 2,3; 3,1]);
else
    % List vertices in counter-clockwise order, so that edges are outwards.
    he_tri = int32([2,1; 3,2; 1,3]);
end

if nargin<3; flabel=0; end
if nargin<4; sibhes = determine_sibling_halfedges(nv, tris); end

nbdedgs = 0; ntris=int32(size(tris,1));
for ii=1:ntris
    if tris(ii,1)==0; ntris=ii-1; break; end
    for jj=1:3
        if sibhes(ii,jj) == 0 || size(flabel,1)>1 && ...
                flabel(ii)~=flabel(heid2fid(sibhes(ii,jj)))
            if(~visited(tris(ii,he_tri(jj,1))))
              visited(tris(ii,he_tri(jj,1)))=true;
              isborder( tris(ii,he_tri(jj,1))) = true; nbdedgs = nbdedgs +1;
            end
            if(~visited(tris(ii,he_tri(jj,2))))
              visited(tris(ii,he_tri(jj,2)))=true;
              isborder( tris(ii,he_tri(jj,2))) = true; nbdedgs = nbdedgs +1;
            end
        end
    end
end

% Define new numbering for border vertices
v2b = zeros(nv,1,'int32'); % Allocate and initialize to zeros.
b2v = nullcopy(zeros(sum(isborder),1,'int32'));
k = int32(1);

if nv<ntris*3
    for ii=1:nv
        if isborder(ii);
            b2v(k) = ii; v2b(ii) = k; k = k+1;
        end
    end
else
    % If there are too many vertices, then loop through connectivity table
    for ii=1:ntris
        for jj=1:3
            v = tris(ii,jj);
            if isborder(v) && v2b(v)==0
                b2v(k) = v; v2b(v) = k; k = k+1;
            end
        end
    end
end

if nargout>1
    bdedgs = nullcopy(zeros(nbdedgs,2,'int32'));
    if nargout>2; edgmap = nullcopy(zeros(size(bdedgs,1),1,'int32')); end
    
    count = int32(1);
    for ii=1:ntris
        for jj=1:3
            if sibhes(ii,jj) == 0 || size(flabel,1)>1 && ...
                    flabel(ii)<flabel(heid2fid(sibhes(ii,jj)))
                
                bdedgs(count, :) = v2b(tris(ii,he_tri(jj,:)));

                if nargout>2; edgmap(count) = ii*4+jj-1; end
                count = count + 1;
            end
        end
    end
end

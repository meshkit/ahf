function [b2v, bdedgs, edgmap] = extract_border_curv_quad...
    (nv, elems, flabel, opphes, inwards) %#codegen 
%EXTRACT_BORDER_CURV_QUAD Extract border vertices and edges.
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_QUAD(NV,ELEMS,FLABEL, ...
% OPPHES,INWARDS) Extracts border vertices and edges of a quadrilateral or
% mixed mesh. Return list of border vertex IDs and list of border edges.
% Edges between faces with different labels are also considered as border
% edges, and in this case only the halfedge with smaller label IDs are
% returned. The following explains the input and output arguments.
%
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_QUAD(NV,QUADS)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_QUAD(NV,QUADS,FLABELS)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_QUAD(NV,QUADS,FLABELS,OPPHES)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV_QUAD(NV,QUADS,FLABELS,OPPHES,INWARDS)
% NV: specifies the number of vertices.
% QUADS: contains the connectivity.
% FLABEL: contains a label for each face.
% OPPHES: contains the opposite half-edges.
% NQUADS: is the number of elemets. If missing, it is set to nnz_elements(QUADS,1)
% INWARDS: specifies whether the edge normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDEDGS: is connectivity of border edges.
% EDGMAP: stores mapping to halfedge ID
%
% See also EXTRACT_BORDER_CURV

isborder = false(nv,1);
visited=false(nv,1);

if nargin>=5 && inwards
    % List vertices in counter-clockwise order, so that edges are inwards.
    he_tri = int32([1,2; 2,3; 3,1]);
    he_quad = int32([1,2; 2,3; 3,4; 4,1]);
else
    % List vertices in counter-clockwise order, so that edges are outwards.
    he_tri = int32([2,1; 3,2; 1,3]);
    he_quad = int32([2,1; 3,2; 4,3; 1,4]);
end

if nargin<3; flabel=0; end
if nargin<4; opphes = determine_opposite_halfedge_quad(nv, elems); end

nbdedgs = int32(0); nelems=int32(size(elems,1));
for ii=1:nelems
    if elems(ii,1)==0; nelems=ii-1; break; end
    
    if elems(ii,4)==0
        for jj=1:3
            if opphes(ii,jj) == 0 || size(flabel,1)>1 && ...
                    flabel(ii)~=flabel(heid2fid(opphes(ii,jj)))
                if(~visited(elems(ii,he_tri(jj,1))))
                    visited(elems(ii,he_tri(jj,1)))=true;
                    isborder( elems(ii,he_tri(jj,1))) = true; nbdedgs = nbdedgs +1;
                end
                if(~visited(elems(ii,he_tri(jj,2))))
                    visited(elems(ii,he_tri(jj,2)))=true;
                    isborder( elems(ii,he_tri(jj,2))) = true; nbdedgs = nbdedgs +1;
                end
            end
        end
    else
        for jj=1:4
            if opphes(ii,jj) == 0 || size(flabel,1)>1 && ...
                    flabel(ii)~=flabel(heid2fid(opphes(ii,jj)))
                if(~visited(elems(ii,he_quad(jj,1))))
                    visited(elems(ii,he_quad(jj,1)))=true;
                    isborder( elems(ii,he_quad(jj,1))) = true; nbdedgs = nbdedgs +1;
                end
                if(~visited(elems(ii,he_quad(jj,2))))
                    visited(elems(ii,he_quad(jj,2)))=true;
                    isborder( elems(ii,he_quad(jj,2))) = true; nbdedgs = nbdedgs +1;
                end
            end
        end
    end
end

% Define new numbering for border nodes
v2b = zeros(nv,1,'int32'); % allocate and initialize to zeros
b2v = nullcopy(zeros(sum(isborder),1,'int32'));
k = int32(1);
for ii=1:nv
    if isborder(ii);
        b2v(k) = ii; v2b(ii) = k; k = k+1;
    end
end

if nargout>1
    bdedgs = nullcopy(zeros(nbdedgs,2,'int32'));
    if nargout>2; edgmap = nullcopy(zeros(size(bdedgs,1),1,'int32')); end
    
    count = int32(1);
    for ii=1:nelems
        if elems(ii,4)==0
            for jj=1:3
                if opphes(ii,jj) == 0 || ...
                        size(flabel,1)>1 && flabel(ii)<flabel(heid2fid(opphes(ii,jj)))
                    bdedgs(count, :) = v2b(elems(ii,he_tri(jj,:)));
                    
                    if nargout>2; edgmap(count) = ii*4+jj-1; end
                    count = count + 1;
                end
            end
        else
            for jj=1:4
                if opphes(ii,jj) == 0 || ...
                        size(flabel,1)>1 && flabel(ii)<flabel(heid2fid(opphes(ii,jj)))
                    bdedgs(count, :) = v2b(elems(ii,he_quad(jj,:)));
                    
                    if nargout>2; edgmap(count) = ii*4+jj-1; end
                    count = count + 1;
                end
            end
        end
    end
end

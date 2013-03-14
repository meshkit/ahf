function [b2v, bdedgs, edgmap] = extract_border_curv...
    (nv, elems, flabel, sibhes, inwards) %#codegen 
%EXTRACT_BORDER_CURV Extract border vertices and edges.
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV(NV,ELEMS,FLABEL,SIBHES,NF)
% Extracts border vertices and edges of triangle, quadrilateral, or mixed 
% mesh. Return list of border vertex IDs and list of border edges. Edges 
% between faces with different labels are also considered as border edges.
% The following explains the input and output arguments.
%
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV(NV,ELEMS)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV(NV,ELEMS,FLABEL)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV(NV,ELEMS,FLABEL,SIBHES)
% [B2V,BDEDGS,EDGMAP] = EXTRACT_BORDER_CURV(NV,ELEMS,FLABEL,SIBHES,INWARDS)
% NV: specifies the number of vertices.
% ELEMS: contains the connectivity.
% FLABEL: contains a label for each face.
% SIBHES: contains the opposite half-edges.
% INWARDS: specifies whether the edge normals should be inwards (false by default)
% B2V: is a mapping from border-vertex ID to vertex ID.
% BDEDGS: is connectivity of border edges.
% EDGMAP: stores mapping to halfedge ID
%
% See also DETERMINE_OPPOSITE_HALFEDGE, EXTRACT_BORDER_CURV_TRI, and
% EXTRACT_BORDER_CURV_QUAD

if nargin<3; flabel=0; end
if nargin<4; sibhes = determine_opposite_halfedge(nv, elems); end
if nargin<6; inwards = 0; end

if nargin<3
    if size(elems,2)==3
        [b2v, bdedgs, edgmap] = extract_border_curv_tri(nv, elems, flabel, sibhes, inwards);
    else
        [b2v, bdedgs, edgmap] = extract_border_curv_quad(nv, elems, flabel, sibhes, inwards);
    end
else
    if size(elems,2)==3
        [b2v, bdedgs, edgmap] = extract_border_curv_tri(nv, elems, flabel, sibhes, inwards);
    else
        [b2v, bdedgs, edgmap] = extract_border_curv_quad(nv, elems, flabel, sibhes, inwards);
    end
end

function isborder = determine_border_vertices_curv(nv, edgs, opphvs, isborder) %#codegen
%DETERMINE_BORDER_VERTICES_CURV Determine border vertices of a curve.
%
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,OPPHVS,ISBORDER) 
% determines border vertices of a curve. Returns bitmap of border vertices.
%
% Example:
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS)
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,OPPHVS)
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,OPPHVS,ISBORDER)
%
% See also DETERMINE_BORDER_VERTICES_SURF, DETERMINE_BORDER_VERTICES_VOL

if nargin<3; opphvs = determine_opposite_halfvert(nv, edgs); end
if nargin<4; isborder = false(nv,1); end

nedgs = nnz_elements(edgs);
for ii=1:nedgs
    for jj=1:2
        if opphvs(ii,jj) == 0
            isborder( edgs(ii,jj)) = true;
        end
    end
end

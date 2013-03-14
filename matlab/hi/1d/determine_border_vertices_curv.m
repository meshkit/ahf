function isborder = determine_border_vertices_curv(nv, edgs, varargin)
%DETERMINE_BORDER_VERTICES_CURV Determine border vertices of a curve.
%
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS)
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,SIBHVS) 
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,SIBHVS,ISBORDER)
% determines border vertices of a curve. Returns bitmap of border vertices.
%
% Example:
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS)
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,SIBHVS)
% ISBORDER = DETERMINE_BORDER_VERTICES_CURV(NV,EDGS,SIBHVS,ISBORDER)
%
% See also DETERMINE_BORDER_VERTICES_SURF, DETERMINE_BORDER_VERTICES_VOL

%#codegen -args {int32(0), coder.typeof( int32(0), inf, 2)}

if nargin<3; 
    sibhvs = determine_sibling_halfvert(nv, edgs); 
else
    sibhvs = varargin{1};
end
if nargin<4; 
    isborder = false(nv,1); 
else
    isborder = varargin{2};
end

nedgs = nnz_elements(edgs);
for ii=1:nedgs
    for jj=1:2
        if sibhvs(ii,jj) == 0
            isborder( edgs(ii,jj)) = true;
        end
    end
end

function v2he = determine_incident_halfedges(nv, elems, sibhes, varargin)
%DETERMINE_INCIDENT_HALFEDGES Determine an incident halfedges.
%    V2HE = DETERMINE_INCIDENT_HALFEDGES(NV, ELEMS, SIBHES)
%    V2HE = DETERMINE_INCIDENT_HALFEDGES(NV, ELEMS, SIBHES, V2HE)
% Determines incident halfedges of each vertex for a triangular, 
% quadrilateral, or mixed mesh. It gives higher priorities to border edges.
%
% Input:
%     NV specifies the number of vertices.
%     ELEMS is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     SIBHES is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
% Output:
%     V2HE is an array of size equal to number of vertices.
%
% See also DETERMINE_INCIDENT_HALFFACES, DETERMINE_INCIDENT_HALFVERTS

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, inf]),
%#codegen        coder.typeof( int32(0), [inf, 3])}
%#codegen determine_incident_halfedges_usestruct -args {int32(0), coder.typeof( int32(0), [inf, inf]),
%#codegen        struct('fid',coder.typeof( int32(0), [inf, 3]),'leid',coder.typeof( int8(0), [inf, 3])), false}
 
coder.inline('never');

if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
        v2he = zeros( nv, 1, 'int32');
else
        v2he = struct( 'fid', zeros(nv, 1, 'int32'), ...
        'leid', zeros(nv, 1, 'int8'));
end

for kk=1:int32(size(elems,1))
    if elems(kk,1)==0; break; end
    
    for lid=1:int32(size(elems,2))
        v = elems(kk,lid);
        
        if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
            if v>0 && (v2he(v)==0 || sibhes( kk,lid) == 0 || ...
                (sibhes( heid2fid(v2he(v)), heid2leid(v2he(v))) && sibhes( kk, lid)<0))
                v2he(v) = 4*kk + lid - 1;
            end
        elseif v>0 && ((v2he.fid(v)==0) || (sibhes.fid(kk,lid)==0))
            v2he.fid(v) = kk;
            v2he.leid(v)=int8(lid);
        end
    end
end
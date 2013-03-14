function v2hv = determine_incident_halfverts(nv, edgs, varargin)
% DETERMINE_INCIDENT_HALFVERTS Determine an incident half-vertex.
%
%     V2HV = DETERMINE_INCIDENT_HALFVERTS(NV, EDGS) 
%     V2HV = DETERMINE_INCIDENT_HALFVERTS(NV, EDGS,V2HV)
% Determines an incident half-vertex of each vertex. 
% 
% Input:  NV:      number fo vertices
%         EDGS:    integer array of size mx2 storing element connectivity
% Output: V2HV:    integer array of size nx1, storing mapping from each
%                  vertex to an incident half-vertex.
%
% See also DETERMINE_SIBLING_HALFVERT, DETERMINE_INCIDENT_HALFEDGES, DETERMINE_INCIDENT_HALFFACES

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2])}

nedgs = int32(size(edgs,1));

% Construct a vertex to halfedge mapping.
if nargin<3 || isempty( varargin{1})
    v2hv = zeros( nv, 1, 'int32');
else
    v2hv = varargin{1};
    v2hv(:) = 0;
end

% Compute v2hv.
for kk=1:nedgs
    for lid=1:2
        v = edgs(kk,lid);
        if v>0 && v2hv(v)==0
            v2hv(v) = elvids2hvid( kk, lid);
        end
    end
end

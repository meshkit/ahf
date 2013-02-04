function v2hv = determine_incident_halfverts(edgs, opphvs, v2hv, nedgs) %#codegen
%DETERMINE_INCIDENT_HALFVERTS Determine an incident half-vertex.
% DETERMINE_INCIDENT_HALFVERTS(EDGS,OPPHVS,V2HV,NEDGS) Determines an
% incident half-vertex of each vertex. The following explains the input and
% output arguments.
% 
% Input:  edgs:    matrix of size mx2 storing element connectivity
%         opphvs:  matrix of size mx2 storing opposite vertices
% Output: v2hv:    an array of size equal to number of vertices.
%
% See also DETERMINE_INCIDENT_HALFEDGES, DETERMINE_INCIDENT_HALFFACES

%% Declare types and sizes
assert( isa(edgs,'int32') && size(edgs,2)==2);
assert( isa(opphvs,'int32') && size(opphvs,2)==2);
if nargin>2; assert( isa(v2hv, 'int32') && size(v2hv,1)>=1); end

if nargin>3;
    assert( isa(nedgs, 'int32')); 
else
    nedgs = nnz_elements(edgs);
end

% Construct a vertex to halfedge mapping.
if nargin<3;
    nv = int32(0);
    for ii=1:nedgs
        for jj=1:2
            if edgs(ii,jj)>nv; nv = edgs(ii,jj); end
        end
    end

    v2hv = zeros( nv, 1, 'int32');
else
    v2hv(:) = 0;
end

% Compute v2hv.
for kk=1:nedgs
    for lid=0:1
        v = edgs(kk,lid+1);
        if v>0 && v2hv(v)==0
            v2hv(v) = 2*kk + lid;
        end
    end
end

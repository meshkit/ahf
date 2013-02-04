function v2he = determine_incident_halfedges(elems, opphes, v2he) %#codegen
%DETERMINE_INCIDENT_HALFEDGES Determine an incident halfedges.
% DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE) Determines incident
% halfedges of each vertex for a triangular, quadrilateral, or mixed mesh. 
% It gives higher priorities to border edges. The following explains inputs
% and outputs.
%
% V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES)
% V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE)
% V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE)
%     ELEMS is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     OPPHES is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     V2HE is an array of size equal to number of vertices.
%          It is passed by reference.
%
% See also DETERMINE_INCIDENT_HALFFACES, DETERMINE_INCIDENT_HALFVERTS

coder.inline('never');

if nargin<3;
    % Set nv to maximum value in elements
    nv = int32(0);
    for ii=1:int32(size(elems,1))
        if elems(ii,1)==0; break; end

        for jj=1:int32(size(elems,2))
            if elems(ii,jj)>nv; nv = elems(ii,jj); end
        end
    end

    v2he = zeros( nv, 1, 'int32');
else
    v2he(:) = 0;
end

for kk=1:int32(size(elems,1))
    if elems(kk,1)==0; break; end
    
    for lid=1:int32(size(elems,2))
        v = elems(kk,lid);
        if v>0 && (v2he(v)==0 || opphes( kk,lid) == 0 || ...
	     (opphes( int32( bitshift( uint32(v2he(v)),-2)), mod(v2he(v),4)+1) && opphes( kk, lid)<0))
            v2he(v) = 4*kk + lid - 1;
        end
    end
end

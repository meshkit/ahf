function heid = update_incident_halfedge(heid, elems, opphes) %#codegen 
% UPDATE_INCIDENT_HALFEDGE    Update the incident halfedge of a vertex.
%
%    It determines a unique incident halfedge ID of the origin vertex of
%    heid. If the vertex is a border vertex, then a border halfedge is
%    returned. Otherwise, the halfedge with the smallest ID is returned.
%
% HEID = UPDATE_INCIDENT_HALFEDGE(HEID, ELEMS, OPPHES)
%     ELEMS is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     OPPHES is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     HEID is a half-edge ID, for whose origin vertex a (unique) incident 
%          halfedge is determined. 
%
% See also DETERMINE_INCIDENT_HALFEDGES

nvpE = int32(size(elems,2));  % Number of vertices per element
next4 = int32([2,3,4,1]);
next3 = int32([2,3,1]);

% Rotate around the origin vertex in clockwise order to find 
%    the unique incident halfedge.
fstart = heid2fid(heid); lstart=heid2leid(heid);
f=fstart; l=lstart;

while 1
    opp = opphes(f,l);
    
    if opp==0; heid = 4*f+l-1; return; end
    
    f = heid2fid(opp); 
    if nvpE==3 || elems(f,4)==0
        l=next3(heid2leid(opp));
    else
        l=next4(heid2leid(opp));
    end
    if 4*f<heid; heid = 4*f+l-1; end
    
    if f==fstart; break; end
end

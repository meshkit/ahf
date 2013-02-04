function correct = verify_incident_halfedges(elems, opphes, v2he, nf) %#codegen 
% VERIFY_INCIDENT_HALFEDGES    Check whether v2he is correct.
%
% B = VERIFY_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE,NF) Checks whether 
% v2he is correct for a triangular, quadrilateral, or mixed mesh. 
%
%     ELEMS is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     OPPHES is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
%     V2HE is the vertex to half-edge map.
%     NF is the number of faces. If not given, then it is set to 
%        nnz_elements(ELEMS,1).
%
% See also DETERMINE_INCIDENT_HALFEDGES

% Initialize nf
if nargin<4; nf = nnz_elements(elems); end

% Set nv to maximum value in elements
nv = int32(0);
for i=1:nf
    for j=1:int32(size(elems,2))
        if elems(i,j)>nv; nv = elems(i,j); end
    end
end

correct=true;

% First, check halfedge indeed originates from vertex.
for i=1:nv
    if v2he(i) && elems(heid2fid(v2he(i)), heid2leid(v2he(i)))~=i
        correct=false;
        return;
    end
end

% Second, check to make sure each vertex in the elems is mapped to to a
% halfedeg, and each border vertex is mapped to a border halfedge
for i=1:nf
    for lid=1:int32(size(elems,2))
        v = elems(i,lid);
        if v>0 && (v2he(v)==0 || opphes( i,lid) <= 0 && ...
                opphes( heid2fid(v2he(v)), heid2leid(v2he(v))))
            correct = false;
            return;
        end
    end
end

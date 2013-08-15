function   [nTris, tris_1ring, leids_1ring] = obtain_tri_edges_around_implicit_edge(trisID,edgeID,sibhes)
% This function takes an implicit edge and returns the list of incident
% triangles and local id's of the edge wrt to the incident triangles

% Input:
%     trisID:  element ID of a triangle
%     edgeID: local edge ID within the triangle
%     sibhfs: opposite halfedges
% Output:
%     nTris: number of incident triangles
%     tris_1ring: array of element IDs of the incident triangles
%     leids_1ring: array of local edge IDs whthin the triangles
%
%  Note that the lengths of triss_1ring and leids_1ring may be larger than
%     nTris, so only the first nTets entries contain nonzero values.


%This basically calls loop_sbihes

MAXFACES=int32(50);
tris_1ring=zeros(MAXFACES,1,'int32');
leids_1ring=zeros(MAXFACES,1,'int32');
nTris=int32(1);



tris_1ring(1)=trisID;
leids_1ring(1)=edgeID;

%First obtain a halfedge
%If the original edge is on the boundary, simply return trisID and edgeID

datatype=isstruct(sibhes);

if datatype
    fid=sibhes.fid(trisID,edgeID);
    leid=sibhes.leid(trisID,edgeID);
    if fid==0
        return
    end
else
    fid=heid2fid(sibhes(trisID,edgeID));
    leid=heid2leid(sibhes(trisID,edgeID));
    if fid==0
        return
    end
end

%If it's not on the boundary, then call loop_sbihes. The remaining part is
%a cleaner copy of that function

while fid
    if fid~=trisID
        % We have not returned to the original triangle
        nTris=nTris+1;
        tris_1ring(nTris)=fid;
        leids_1ring(nTris)=leid;
    else
        break;
    end
    if ~datatype
        sibhe=sibhes(fid,leid);
        fid = heid2fid(sibhe);
        assert(fid~=0); % fid can not be zero if the algorithm is correct   
        leid= heid2leid(sibhe);
    else
        sibhe.fid=sibhes.fid(fid,leid);
        sibhe.leid=sibhes.leid(fid,leid);
        fid = sibhe.fid;
        assert(fid~=0); % fid can not be zero if the algorithm is correct
        leid= sibhe.leid;
    end
end

end


function heid = hv2he(hvid, mesh, mode)
%%HV2HE : map half-vertex <hvid> to incident half-edge
%   hv2he(hvid,mesh,mode) 
%       mode == 'any'   : id of some half-edge starting at the vertex
%                         corresponding to <hvid>, 0, if there is no such edge in <mesh>
%       mode == 'match' : id of half_edge which matches edge to which <hvid> belongs. 
%   hv2he(hvid,mesh) is hv2he(hvid,mesh,'match')    

%%
% Insert mapping from hv to an incident he

% mesh.sibhvs - mapping to sibling half-vertex, size mx2, based on edges
% mesh.v2hv - mapping to half-vertex

% mesh.sibhes - mapping between sibling half-edges, size mx3, based on
%               faces
% mesh.v2he - mapping from vertex to half-edge

% half-vertex - (edge_id,index), half-edge - (face_id,index)
% => hv->he=hv->edge->vertex->he

if (hvid<=size(mesh.hv2he,1) && mesh.hv2he(hvid)~=0); heid=mesh.hv2he(hvid); return;  end;
if (nargin<3);  mode='match';  end; 
NEIGHBORHOOD_MAXSIZE=100;
eid = hvid2eid( hvid);     % obtain edge ID from half-vertex ID
lvid = hvid2lvid( hvid);   % obtain local vertex ID within an edge from half-vertex ID

% mesh.edges(eid,lvid) - vertex id
heid=mesh.v2he(mesh.edges(eid,lvid));  % half edge starting at this vertex
if strcmp(mode,'any'); return; end;

%% Find if edge <hvid> comes from is also embedded in at least one of the faces
if strcmp(mode,'match')
    other_lvid=int32([2,1]);  
    other_gvid=mesh.edges(eid,other_lvid(lvid)); % other endpoint of the edge <hvid> belongs to
    % queue to keep faces in 1 ring neighborhood
    % queue is used in case mesh is non-manifold in the neighborhood
        
    hequeue=zeros(1,NEIGHBORHOOD_MAXSIZE); 
    hequeue(1)=heid;
    hequeue_top=1;
    hequeue_size=1;
    while hequeue_top<=hequeue_size
        heid_next=hequeue(hequeue_top);
        hequeue_top=hequeue_top+1;
        if (heid_next==0); continue;  end; 
        
        % half-edge <heid_next> originates at <hvid> 
        if terminal_vertex(mesh.faces, heid_next)==other_gvid
            heid=heid_next;
            mesh.hv2he(hvid)=heid;
            return;
        end
        
        % half_edge <heid_prev> ends at <hvid>
        heid_prev=prev_heid_tri(heid);
        if origin_vertex(mesh.faces, heid_prev)==other_gvid
            heid=heid_prev;
            mesh.hv2he(hvid)=heid;
            return;
        end
        
        hequeue_size=hequeue_size+1;
        heid_next = mesh.sibhes( heid2fid(heid_prev), heid2leid(heid_prev));
        hequeue(hequeue_size)=heid_next;
    end
end
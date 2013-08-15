function  [nTets, tets_1ring, leids_1ring] = obtain_tet_edges_around_explicit_edge(edgeID, edges, tets, v2hf, sibhfs)
% This function takes an explicit edge and returns the list of incident
% tets and local id's of the edge wrt to the incident tets

%DOES NOT SUPPORT STRUCTURES!

% Input:
%     edgeID: edge ID within edges
%     edges:  list of explicit edges
%     tets:   list of tetrahedra
%     v2hf:   vertex to one of its incident half face
%     sibhfs: sibling half faces
% Output:
%     nTets: number of incident tetrahedra
%     tets_1ring: array of element IDs of the incident tetrahedra
%     leids_1ring: array of local edge IDs whthin the tetrahedron
%
%  Note that the lengths of tets_1ring and leids_1ring may be larger than
%     nTets, so only the first nTets entries contain nonzero values.
%  It is also possible that the explicit edge does not belong to any
%  tetrahedron


type_struct = isstruct(v2hf);
etags=false(size(tets,1),1);
%MAXFACES=150;
%tets_1ring=zeros(MAXFACES,1,'int32');
%lfids_1ring=zeros(MAXFACES,1,'int32');
nTets=int32(0);
tetface_nodes = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
tetface_signed_edges = int32([-3 -2 -1; 1 5 -4; 2 6 -5; 3 4 -6]);

%Obtain the vertices
v1=edges(edgeID,1);
v2=edges(edgeID,2);

%Find the incident half edge if possible
[hfid,etags] = obtain_1ring_elems_tet_he( v1,v2, tets, v2hf, sibhfs, etags);


%If the edge does not belong to any of the tetrahedron, just return 0
if ~type_struct
    if hfid==0
        tets_1ring=int32(0);
        leids_1ring=int32(0);
        return
    end
else
    %if hfid.
end

%Otherwise, we use hfid to obtain the incident tetrahedra
itet=hfid2cid(hfid);
faceid=hfid2lfid(hfid);

%Obtain the local edge id
%The edge may have incorrect orientation
for vertexID=1:3
    if tets(itet,tetface_nodes(faceid,1))==v1
        if tets(itet,tetface_nodes(faceid,2))==v2
            iedge=abs(tetface_signed_edges(faceid,1));
        else
            iedge=abs(tetface_signed_edges(faceid,3));
        end
    else if tets(itet,tetface_nodes(faceid,2))==v1
            if tets(itet,tetface_nodes(faceid,1))==v2
                iedge=abs(tetface_signed_edges(faceid,1));
            else
                iedge=abs(tetface_signed_edges(faceid,2));
            end
        else
            if tets(itet,tetface_nodes(faceid,1))==v2
                iedge=abs(tetface_signed_edges(faceid,3));
            else
                iedge=abs(tetface_signed_edges(faceid,2));
            end
        end
    end
end


[nTets, tets_1ring, leids_1ring] = obtain_tet_edges_around_edge...
    (itet, iedge, tets, sibhfs);

end




function [hfid,etags] = obtain_1ring_elems_tet_he( origin, terminal_vertex, tets,v2hf,sibhfs, etags)
%OBTAIN_1RING_ELEMS_TET Examins 1-ring tet neighborhood of vid for edge [origin,terminal_vertex].
% [HFID,ETAGS] = OBTAIN_1RING_ELEMS_TET_HE( ORIGIN, TERMINAL_VERTEX, ETAGS)
% Looks through 1-ring neighbor elements of given vertex and finds half-face containing given edge.
% At input, ETAGS must be set to false. It is reset to false at output.

coder.extrinsic('warning');

MAXTETS = 1024;
nelems=int32(0);
if nargin<4; etags=false(size(tets,1)); end;
% Obtain incident tetrahedron of vid.
eid = hfid2cid(v2hf(origin));
if ~eid; return; end

sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);
lookup_lfid = int32([0,2,1,4;1,0,3,2;4,1,0,3;2,3,4,0]);
maxne = MAXTETS;
overflow = false;

% Create a stack for storing tets and insert element itself into stack
% stack = nullcopy(zeros(MAXTETS,1, 'int32'));
queue = zeros(MAXTETS,1, 'int32'); 
queue_top = int32(1);  queue_size = int32(1); 
queue(1) = eid;
hfid=int32(0);

while queue_top<=queue_size
    % Pop the element from top of stack
    eid = queue(queue_top); queue_top = queue_top+1;
    etags(eid) = true;

    % Append element
    if nelems<maxne
        nelems = nelems + 1;
    else
        overflow = true;
    end
    
    found=false;
    lvid = int32(0); % Stores which vertex vid is within the tetrahedron.
    for ii=1:4
        v = tets(eid,ii);
        if v==origin; 
            lvid = ii;             
        else
            if v==terminal_vertex
                % found tetrahedra containing edge <vid,terminal_vertex>
                found=true;
                ltv=ii;
            end
        end
    end
     
    if found
        hfid=clfids2hfid(eid,lookup_lfid(lvid,ltv));
        etags(queue(1:queue_size)) = false;
        return;
    end
    
    % Push unvisited neighbor tets onto stack
    for ii=1:3
        ngb = hfid2cid(sibhfs(eid,sibhfs_tet(lvid,ii)));
        if ngb && ~etags(ngb);
            queue_size = queue_size + 1; queue(queue_size) = ngb;
        end
    end
end

% Reset etags
etags(queue(1:queue_size)) = false;

if overflow
    warning('MATLAB:obtain_nring_elems_tet_he','Buffers are too small to contain neighborhood.');
end

end

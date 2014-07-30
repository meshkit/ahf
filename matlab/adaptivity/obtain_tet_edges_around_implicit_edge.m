function [nTets, tets_1ring, leids_1ring, tets] = obtain_tet_edges_around_implicit_edge(itet, iedge, tets, sibhfs)
% This function takes an implicit edge and returns the list of incident
% tets and local id's of the edge wrt to the incident tets
% Given an edge ID (starting from 1) within a tetrahedron, extract the
%     local edge IDs in all the tetrahedra incident on the edge.
% 
% This function is particularly useful for adding nodes onto edges
%     for high-order elements.
%
% Input:
%     itet:  element ID of a tetrahedron
%     iedge: local edge ID within the tetrahedron
%     tets:  element connectivity
%     sibhfs: opposite halffaces
% Output:
%     nTets: number of neighboring tets.
%     tets_1ring: array of element IDs of the tets in the 1-ring of edge
%     leids_1ring: array of local edge IDs whthin the tets in the 1-ring of edge
%
%  Note that the lengths of tets_1ring and leids_1ring may be larger than
%     nTets, so only the first nTets entries contain nonzero values.

%#codegen -args {int32(0), int32(0), coder.typeof( int32(0), [inf, 4]), coder.typeof( int32(0), [inf, 4])}

tetface_nodes = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
tetface_signed_edges = int32([-3 -2 -1; 1 5 -4; 2 6 -5; 3 4 -6]);

tetedge_nodes = int32([1 2; 2 3; 3 1; 1 4; 2 4; 3 4]);
tetedge_faces = int32([1 2; 1 3; 1 4; 2 4; 3 2; 4 3]);

MAX = int32(20); % Maximum number of tets around an edge
tets_1ring = nullcopy(zeros(MAX, 1, 'int32'));
leids_1ring = nullcopy(zeros(MAX, 1, 'int32'));
coder.varsize('tets_1ring', 'leids_1ring', [inf,1])

itet_start = itet;

nTets = int32(1); tets_1ring(1) = itet; leids_1ring(1) = iedge;

% Loop through the tets
for i=int32(1):2
    vert2 = tets(itet, tetedge_nodes(iedge,i));
    
    itet_cur = itet_start;
    iedge_cur = iedge;
    iedge_ver = i;
    
    while true
        % Obtain opposite halfface ID
        opphfid = sibhfs( itet_cur, tetedge_faces(iedge_cur,iedge_ver));
        itet_cur = hfid2cid(opphfid);
        
        % Finished the cycle.
        if (itet_cur == itet_start || itet_cur==0)
            break;
        end
        
        % Find the corresponding edge
        itet_next_face = hfid2lfid(opphfid);
        if tets( itet_cur, tetface_nodes(itet_next_face,1)) == vert2
            iedge_cur = tetface_signed_edges(itet_next_face,1);
        elseif tets( itet_cur, tetface_nodes(itet_next_face,2)) == vert2
            iedge_cur = tetface_signed_edges(itet_next_face,2);
        else
            iedge_cur = tetface_signed_edges(itet_next_face,3);
        end
        iedge_ver = 1+int32(iedge_cur<0); iedge_cur=abs(iedge_cur);
        
        % Insert tet and edge ID
        nTets = nTets + 1;
        if nTets>length(tets_1ring)
            if nTets>100; error('Too many incident tets'); end
            tets_1ring = [tets_1ring; zeros(MAX, 1, 'int32')]; %#ok<*AGROW>
        end
        tets_1ring(nTets) = itet_cur; leids_1ring(nTets) = iedge_cur;
    end % while
    
    if itet_cur~=0; break; end
end

tets_1ring = tets_1ring(1:nTets);
leids_1ring = leids_1ring(1:nTets);
end


function [nTets, tets_1ring, leids_1ring] = obtain_tet_edges_around_edge...
    (itet, iedge, tets, opphfs)
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
%     opphfs: opposite halffaces
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
        opphfid = opphfs( itet_cur, tetedge_faces(iedge_cur,iedge_ver));
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

%!test
%! tetedge_nodes = int32([1 2; 2 3; 3 1; 1 4; 2 4; 3 4]);
%! get_meshdata('simple/simple/volmesh/Tets/Cube1.neu.cgns');
%! [xs, tets] = readcgns('Cube1.neu.cgns');
%! opphfs=determine_opposite_halfface(size(xs,1), tets);
%! for i=1:size(tets,1)
%!     for j=1:6;
%!         vsum = tets(i,tetedge_nodes(j,1))+tets(i,tetedge_nodes(j,2));
%!         [nTets, tets_1ring, leids_1ring] = obtain_localedges_around_edge(i, j, tets, opphfs);
%!         assert(length(unique(tets_1ring(1:nTets))) == nTets);
%!         for k=1:nTets
%!             assert(vsum==tets(tets_1ring(k),tetedge_nodes(leids_1ring(k),1))+tets(tets_1ring(k),tetedge_nodes(leids_1ring(k),2)));
%!         end
%!     end
%! end

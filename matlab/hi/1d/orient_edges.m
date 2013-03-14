function [edges, sibhvs] = orient_edges( nv, edges)
% Given a curve, make the edges oriented consistently.
%
%  edges = orient_edges( nv, edges)
%  Make sure the curve given by edge is composed of oriented subcurves 
%        between junctions. It supports non-manifold curves.
%
% Input arguments
%     nv: number of vertices
%     edges: element connectivity (m-by-2)
% Output arguments
%     edges: re-oriented element connectivity (same size as input)
%     sibhvs: sibling half-vertices

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2])}
 
% First, compute sibling half-vertices.
sibhvs = determine_sibling_halfverts( nv, edges);
visited = false(size(edges,1),1);

% Loop through edges to see whether some edges should be flipped
for i=1:int32(size(edges,1))
    if visited(i); continue; end
    
    fullcircle = false;
    
    % Starting from the ith edge, visited adjacent edges one by one.
    edg = i;
    nxt = sibhvs( edg,1);
    nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
    
    % Repeat if the first vertex has only two incident edges
    while sibhvs( nxteid, nxtlid) == elvids2hvid(edg,1)
        visited(edg) = true;
        
        if hvid2lvid( nxt)~=2
            % Flip the next edge
            edges( nxteid,:) = edges( nxteid,[2 1]);
            sibhvs( nxteid,:) = sibhvs( nxteid,[2 1]);
        end
        
        edg = nxteid;
        if edg == i; fullcircle = true; break; end
        nxt = sibhvs( edg,1);
        nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
    end
    
    if ~fullcircle
        edg = i;
        nxt = sibhvs( edg,2);
        nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
        
        % Repeat if the second vertex has only two incident edges
        while sibhvs( nxteid, nxtlid) == elvids2hvid(edg,2)
            visited(edg) = true;
            
            if hvid2lvid( nxt)~=1
                % Flip the next edge
                edges( nxteid,:) = edges( nxteid,[2 1]);
                sibhvs( nxteid,:) = sibhvs( nxteid,[2 1]);
            end
            
            edg = nxteid;
            if edg == i; break; end
            nxt = sibhvs( edg,2);
            nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
        end
    end
end

function test  %#ok<DEFNU>
% Integrated test block. Test using command
%      "test_mcode average_vertex_tangent_curv"
%!test
%! N = 20;
%! xs = [cos(2*pi*(0:N-1)/N); sin(2*pi*(0:N-1)/N)]';
%! edgs = [1:N; 2:N 1]';
%! edgs1 = orient_edges( N, edgs);
%! assert( isequal( edgs, edgs1));

%!test
%! N = 20;
%! xs = [cos(2*pi*(0:N-1)/N); sin(2*pi*(0:N-1)/N)]';
%! edgs = [1:N; 2:N 1]'; edgs1 = edgs;
%! for i=2:2:N
%!     edgs(i,:) = edgs(i,[2 1]);
%! end
%! edgs2 = orient_edges( N, edgs);
%! assert( isequal( edgs1, edgs2));

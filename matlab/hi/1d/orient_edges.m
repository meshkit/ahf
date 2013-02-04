function [edges, nxtpgs] = orient_edges( nv, edges) %#codegen 
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
%     nxtpgs: opposite half-vertices (or next half-vertices if nonmanifold)

% First, compute nextpage.
nxtpgs = determine_nextpage_curv( nv, edges);
visited = false(size(edges,1),1);

% Loop through edges to see whether some edges should be flipped
for i=1:int32(size(edges,1))
    if visited(i); continue; end
    
    fullcircle = false;
    
    % Starting from the ith edge, visited adjacent edges one by one.
    edg = i;
    nxt = nxtpgs( edg,1);
    nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
    
    % Repeat if the first vertex has only two incident edges
    while nxtpgs( nxteid, nxtlid) == elvids2hvid(edg,1)
        visited(edg) = true;
        
        if hvid2lvid( nxt)~=2
            % Flip the next edge
            edges( nxteid,:) = edges( nxteid,[2 1]);
            nxtpgs( nxteid,:) = nxtpgs( nxteid,[2 1]);
        end
        
        edg = nxteid;
        if edg == i; fullcircle = true; break; end
        nxt = nxtpgs( edg,1);
        nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
    end
    
    if ~fullcircle
        edg = i;
        nxt = nxtpgs( edg,2);
        nxteid = hvid2eid( nxt); nxtlid = hvid2lvid( nxt);
        
        % Repeat if the second vertex has only two incident edges
        while nxtpgs( nxteid, nxtlid) == elvids2hvid(edg,2)
            visited(edg) = true;
            
            if hvid2lvid( nxt)~=1
                % Flip the next edge
                edges( nxteid,:) = edges( nxteid,[2 1]);
                nxtpgs( nxteid,:) = nxtpgs( nxteid,[2 1]);
            end
            
            edg = nxteid;
            if edg == i; break; end
            nxt = nxtpgs( edg,2);
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

function [tris, sibhes, v2he] = flip_edge_surf(heid, tris, sibhes, v2he, revert) %#codegen
% Flip an edge in a 2-D mesh.
%   [TRIS, SIBHES] = FLIP_EDGE_SURF(HEID, TRIS, SIBHES)
%   [TRIS, SIBHES] = FLIP_EDGE_SURF(HEID, TRIS, SIBHES, [], REVERT)
%   [TRIS, SIBHES, V2HE] = FLIP_EDGE_SURF(HEID, TRIS, SIBHES, V2HE)
%   [TRIS, SIBHES, V2HE] = FLIP_EDGE_SURF(HEID, TRIS, SIBHES, V2HE, REVERT)
%
%   Flip the given halfedge HEID and updates the connectivity accordingly. 
%   Before calling the function, one should call check_flip_edge_surf
%   to check whether the topology will remain consistent after flipping,
%   along with additional checking of geometry (such as face normals).
%   After the flipping, HEID becomes a halfedge of one of the new triangles.
%   You can call the function on it again with revert=1 to recover the mesh 
%   (including tris, sibhes, and v2he).
%
%   Note that after this function is called, all the halfedge IDs involving 
%   the two triangles incident on the heid (say T1 and T2) become invalid 
%   (in the sense that they would refer to different edges). However, the 
%   heid of their opposite halfedges remain valid. Therefore, if you have 
%   any halfedge with face ID T1 or T2 in some queue, make sure you remove 
%   it or use the heid of its opposite halfedges.
%
%   See also: check_flip_edge_surf
%
%   Example usage:
%
%   if check_flip_edge_surf(heid, tris, sibhes)
%       [tris, sibhes] = flip_edge_surf(heid, tris, sibhes);
%       if someproblem occurs
%           [tris, sibhes, v2he] = flip_edge_surf(heid, tris, sibhes, v2he, 1);
%       end
%   end
%   
%   if check_flip_edge_surf(heid, tris, sibhes)
%       [tris, sibhes, v2he] = flip_edge_surf(heid, tris, sibhes, v2he);
%       if someproblem occurs
%           [tris, sibhes, v2he] = flip_edge_surf(heid, tris, sibhes, v2he, 1);
%       end
%   end

assert(nargout==2 || nargout==3 && nargin>=4);
if nargin<5; revert=0; end

fid = heid2fid(heid);
lid = heid2leid(heid);

if ~sibhes(fid, lid)
    % If the half-edge is a border edge, then report error.
    error('Cannot flip a border edge');
end

fid_opp = heid2fid(sibhes(fid,lid));
lid_opp = heid2leid(sibhes(fid,lid));

prev = [3 1 2];
next = [2 3 1];

if revert
    fids = [fid_opp, fid]; lids = [lid_opp, lid];
    verts = [tris(fid_opp,[lid_opp,prev(lid_opp),next(lid_opp)]);
        tris(fid,[lid,prev(lid),next(lid)])];
else
    fids = [fid, fid_opp]; lids = [lid, lid_opp];
    verts = [tris(fid,[lid,prev(lid),next(lid)]);
        tris(fid_opp,[lid_opp,prev(lid_opp),next(lid_opp)])];
end

% Updating two triangles
tris(fid,prev(lid)) = verts(2,1);
tris(fid,lid) = verts(1,2);
tris(fid,next(lid)) = verts(2,2);

tris(fid_opp,prev(lid_opp)) = verts(1,1);
tris(fid_opp,lid_opp) = verts(2,2);
tris(fid_opp,next(lid_opp)) = verts(1,2);

% Update opposite half-edges (sibhes)
h = sibhes(fid,prev(lid));
if h
    sibhes(heid2fid(h), heid2leid(h)) = 4*fids(2) + next(lids(2)) - 1;
end

h = sibhes(fid,next(lid));
if h
    sibhes(heid2fid(h), heid2leid(h)) = 4*fids(1) + prev(lids(1)) - 1;
end

h = sibhes(fid_opp,prev(lid_opp));
if h
    sibhes(heid2fid(h), heid2leid(h)) = 4*fids(1) + next(lids(1)) - 1;
end

h = sibhes(fid_opp,next(lid_opp));
if h
    sibhes(heid2fid(h), heid2leid(h)) = 4*fids(2) + prev(lids(2)) - 1;
end

hs = [sibhes( fid, next(lid)), sibhes( fid_opp, prev(lid_opp)),...
    sibhes( fid_opp, next(lid_opp)), sibhes( fid, prev(lid))];
sibhes( fids(1), prev(lids(1))) = hs(1);
sibhes( fids(1), next(lids(1))) = hs(2);

sibhes( fids(2), prev(lids(2))) = hs(3);
sibhes( fids(2), next(lids(2))) = hs(4);

% Update incident half-edges (v2he).
if nargout>2 && ~isempty(v2he)
    f = heid2fid(v2he(verts(1,1)));
    if f == fids(1) || f==fids(2) || f>fid || f>fid_opp
        v2he(verts(1,1)) = update_incident_halfedge(4*fid_opp+prev(lid_opp)-1, tris, sibhes);
    end
    
    f = heid2fid(v2he(verts(1,3)));
    if f == fids(1) || f==fids(2) || f>fid || f>fid_opp
        v2he(verts(1,3)) = update_incident_halfedge(4*fid+prev(lid)-1, tris, sibhes);
    end
    
    f = heid2fid(v2he(verts(1,2)));
    if f == fids(1) || f>fid || f>fid_opp
        v2he(verts(1,2)) = update_incident_halfedge(4*fid_opp+next(lid_opp)-1, tris, sibhes);
    end

    f = heid2fid(v2he(verts(2,2)));
    if f == fids(2) || f>fid || f>fid_opp
        v2he(verts(2,2)) = update_incident_halfedge(4*fid+next(lid)-1, tris, sibhes);
    end
end

function test %#ok<DEFNU>
%!test
%! xs = [1,1,0;
%!     2,1,0;
%!     3,1,0;
%!     1,2,0;
%!     2,2,0;
%!     3,2,0;
%!     1,3,0;
%!     2,3,0;
%!     3,3,0;
%!     4,2,0];
%! 
%! tris = int32([5,4,1;
%!     1,2,5;
%!     5,2,3;
%!     3,6,5;
%!     8,7,4;
%!     4,5,8;
%!     8,5,6;
%!     6,9,8;
%!     10,6,3]);
%! 
%! 
%! sibhes = determine_opposite_halfedge(size(xs,1), tris);
%! v2he = determine_incident_halfedges(tris, sibhes);
%! 
%! for i = 1 : 3
%!     for j = 1 : int32(size(tris,1))
%!         if sibhes(j,i)
%!             [tris2, sibhes2, v2he2] = flip_edge_surf(4*j + i - 1, tris, sibhes, v2he);
%!             assert(verify_incident_halfedges(tris2, sibhes2, v2he2));
%!             if ~isequal(sibhes2,determine_opposite_halfedge(size(xs,1),tris2))
%!                 error('Failed checking');
%!             end
%!             if ~isequal( v2he2, determine_incident_halfedges(tris2,sibhes2))
%!                 error('Failed checking');
%!             end
%!
%!             % Test recover mesh.
%!             [tris3, sibhes3, v2he3] = flip_edge_surf(sibhes(j,i), tris2, sibhes2, v2he2, 1);
%!             assert(verify_incident_halfedges(tris3, sibhes3, v2he3));
%!             if ~isequal(tris,tris3) || ~isequal(sibhes3,sibhes) || ~isequal( v2he3, v2he)
%!                 error('Failed checking');
%!             end
%!         end
%!     end
%! end


function [nv, nf, tris, sibhes, v2he] = split_edge_surf(heid, nv, nf, ...
    tris, sibhes, v2he) %#codegen 
%SPLIT_EDGE_SURF    Split an edge and insert a new vertex.
%
%   [NV, NF, TRIS, SIBHES] = SPLIT_EDGE_SURF(HEID, NV, NF, TRIS, SIBHES) 
%   [NV, NF, TRIS, SIBHES, V2HE] = SPLIT_EDGE_SURF(HEID, NV, NF, TRIS, SIBHES, V2HE) 
%   splits edge with half-edge ID HEID into two edges by inserting a vertex 
%   into it and updates the connectivity accordingly. The new vertex has a
%   vertex ID NV+1, and two new triangles are appended to the end of TRIS 
%   with face IDs NF+1 and NF+2. When the function is returned, the
%   original halfedge is split into two halfedges: one still has the same
%   HEID but its destination vertex is equal to the new vertex, and another
%   halfedge with HEID equal to the tuplex <nf_in+1,heid2leid(heid)>.
% 
%   Note that calling contract_edge_surf on the heid <(nf_in+1),heid2leid(heid)> 
%   would recover the mesh (including, tris, sibhes, and v2he).
% 
%   TRIS and SIBHES must be size Mx3 with M>NF+1, and V2HE is Nx1 with N>NV.
%
%   See also CONTRACT_EDGE_SURF, FLIP_EDGE_SURF

coder.extrinsic('fprintf');

assert( nargout==5 && nargin==6 || nargout==4 && nargin==5);
assert( size(tris,1)>nf+1 && size(sibhes,1)>nf+1);
assert( size(v2he,1)>nv);

fid = heid2fid(heid); lid = heid2leid(heid);
prev = [3 1 2];
next = [2 3 1];

if ~sibhes(fid, lid)
    % Is border face
    nv = nv + 1;
    nf = nf + 1;

    % Update tris
    tris(nf, :) = tris(fid, :); tris(nf, lid) = nv;
    tris(fid, next(lid)) = nv;

    % Update opposite half-edges (sibhes)
    sibhes( nf, lid)= 0;
    next_opp=sibhes(fid,next(lid));
    sibhes( nf, prev(lid))= 4*fid + next(lid) -1;
    sibhes( nf, next(lid))= next_opp;
    sibhes( fid, next(lid)) = 4*nf + prev(lid)-1;
    if next_opp
        sibhes( heid2fid(next_opp),heid2leid(next_opp)) = 4*nf+next(lid)-1;
    end

    % Update incident half-edges (v2he).
    if nargin>5
        v2he(nv) = 4*nf + lid - 1;
        
        v = tris(nf,next(lid)); f=heid2fid(v2he(v));
        if f == fid
            v2he(v) = update_incident_halfedge( 4*nf + next(lid) - 1, tris, sibhes);
        end
    end
else
    nv = nv + 1;
    nf = nf + 2;

    fid_opp = heid2fid(sibhes(fid,lid)); lid_opp = heid2leid(sibhes(fid,lid));

    % Update tris
    tris(nf-1, :) = tris(fid, :); tris(nf-1, lid) = nv;
    tris(nf, :) = tris(fid_opp, :); tris(nf, next(lid_opp)) = nv;
    tris(fid, next(lid)) = nv; tris(fid_opp, lid_opp) = nv;

    % Update opposite half-edges (sibhes)
    sibhes( nf-1, lid)= 4*nf + lid_opp - 1;
    next_opp=sibhes(fid,next(lid));
    sibhes( nf-1, prev(lid))= 4*fid + next(lid) -1;
    sibhes( nf-1, next(lid))= next_opp;
    sibhes( fid, next(lid)) = 4*(nf-1) + prev(lid)-1;
    if next_opp
        sibhes( heid2fid(next_opp),heid2leid(next_opp)) = 4*(nf-1)+next(lid)-1;
    end

    sibhes( nf, lid_opp)= 4*(nf-1) + lid - 1;
    opp_prev_opp=sibhes(fid_opp,prev(lid_opp));
    sibhes( nf, prev(lid_opp))= opp_prev_opp;
    sibhes( nf, next(lid_opp))= 4*fid_opp + prev(lid_opp)-1;
    sibhes( fid_opp, prev(lid_opp)) = 4*nf + next(lid_opp)-1;
    if opp_prev_opp
        sibhes( heid2fid(opp_prev_opp),heid2leid(opp_prev_opp)) = 4*nf+prev(lid_opp)-1;
    end
    
    % Update incident half-edges (v2he).
    if nargin>5
        v2he(nv) = update_incident_halfedge( 4*(nf-1) + lid - 1, tris, sibhes);
        
        v = tris(nf-1,next(lid)); f=heid2fid(v2he(v));
        if f == fid
            v2he(v) = update_incident_halfedge( 4*(nf-1) + next(lid) - 1, tris, sibhes);
        elseif f == fid_opp
            v2he(v) = update_incident_halfedge( 4*nf + lid - 1, tris, sibhes);
        end
        
        if sibhes(nf, prev(lid_opp))==0
            % Make sure vertex still points to border halfedge
            v = tris(nf,prev(lid_opp));
            if heid2fid(v2he(v))==fid_opp
                v2he(v) = update_incident_halfedge( 4*nf + prev(lid_opp) - 1, tris, sibhes);
            else
                fprintf(2, 'Warning: Input halfedge data structure does not seem to have correct v2he\n');
            end
        end
    end
end

function test %#ok<DEFNU>
% test using command test_mcode('split_edge_surf')
%
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
%! tris = [5,4,1;
%!     1,2,5;
%!     5,2,3;
%!     3,6,5;
%!     8,7,4;
%!     4,5,8;
%!     8,5,6;
%!     6,9,8;
%!     10,6,3];
%! 
%! nv = int32(size(xs,1)); nf=int32(size(tris,1));
%! sibhes = determine_sibling_halfedges(nv, tris);
%! v2he = determine_incident_halfedges(nv, tris, sibhes);
%!
%! tris = [tris; zeros(2,3,'int32')];
%! sibhes = [sibhes; zeros(2,3,'int32')];
%! v2he = [v2he; 0];
%!
%! for i = 1 : 3
%!     for j = 1 : nf
%!         heid = 4*j + i - 1;
%!         [nv2, nf2, tris2, sibhes2, v2he2] = split_edge_surf(heid, nv, nf, ...
%!               tris, sibhes, v2he);
%!         if ~isequal(sibhes2(1:nf2,:),determine_sibling_halfedges(nv2,tris2(1:nf2,:)))
%!             error('Failed checking');
%!         end
%!         assert(verify_incident_halfedges(tris2, sibhes2, v2he2));
%!         if ~isequal( v2he2, determine_incident_halfedges(nv2,tris2,sibhes2))
%!             error('Failed checking');
%!         end
%!     end
%! end


function allv_ngbvs = obtain_all_nring_surf( ring, nv, elems, opphes, v2he)
% Obtain the nring-neighbors of all the vertices of a surface mesh
% ALLV_NGBVS = OBTAIN_ALL_NRING_SURF( RING, NV, ELEMS)
% ALLV_NGBVS = OBTAIN_ALL_NRING_SURF( RING, NV, ELEMS, OPPHES)
% ALLV_NGBVS = OBTAIN_ALL_NRING_SURF( RING, NV, ELEMS, OPPHES, V2HE)
%
% Input arguments
%    RING: the desired size of the ring
%    NV: number of vertices of curve
%    ELEMS: element connectivity
%    OPPHES: Opposite half-edges (optional)
%    V2HE: Mapping from vertex to an incident half-edge (optional)
%
% Output arguments
%    allv_ngbvs: List of neighboring vertices for each vertex in a format
%        similar to mixed elements. Note that for each vertex, the vertex 
%        itself is not included in the list.
%
% See also obtain_nring_surf

%#codegen -args {0, int32(0), coder.typeof(int32(0),[inf,4],[1,1]),
%#codegen coder.typeof(int32(0),[inf,4],[1,1]), coder.typeof(int32(0),[inf,1])}

if nargin<4; opphes = determine_opposite_halfedge( nv, elems); end
if nargin<5; v2he = determine_incident_halfedges( elems, opphes); end

switch int32(ring*2)
    case 2
        minpnts = int32(4); avepnts = int32(7);
    case 3
        minpnts = int32(8); avepnts = int32(13);
    case 4
        minpnts = int32(12); avepnts = int32(19);
    case 5
        minpnts = int32(18); avepnts = int32(31);
    case 6
        minpnts = int32(25); avepnts = int32(37);
    case 7
        minpnts = int32(33); avepnts = int32(55);
    case 8
        minpnts = int32(43); avepnts = int32(73);
    otherwise
        error('Unsupported ring size');
        minpnts = int32(0); avepnts = int32(0); %#ok<UNRCH>
end

ngbvs = nullcopy(zeros(128,1,'int32'));
vtags = false(nv, 1);
ftags = false(size(elems,1), 1);

allv_ngbvs = nullcopy(zeros( fix(nv*avepnts*1.1),1,'int32'));

offset = int32(1);
for i=1:nv
    [ngbvs, nverts,vtags,ftags] = obtain_nring_quad(i, ring, minpnts, ...
        elems, opphes, v2he, ngbvs, vtags, ftags);

    assert( offset +nverts + 1 <= numel(allv_ngbvs));
    allv_ngbvs(offset) = nverts;
    allv_ngbvs(offset+1:offset+nverts) = ngbvs(1:nverts);
    
    offset = offset +nverts + 1;
end

allv_ngbvs = allv_ngbvs(1:offset-1);

function test  %#ok<DEFNU>
% Integrated test block. Test using command
%      "test_mcode obtain_all_nring_surf"
%!test
%! N = 40;
%! pnts = rand(N,2);
%! tris = delaunay(pnts(:,1),pnts(:,2));
%! allv_ngbvs = obtain_all_nring_surf( 1, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 1.5, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 2, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 2.5, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 3, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 3.5, N, tris);
%! allv_ngbvs = obtain_all_nring_surf( 4, N, tris);

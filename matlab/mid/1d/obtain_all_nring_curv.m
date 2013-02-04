function allv_ngbvs = obtain_all_nring_curv( ring, nv, edges, opphvs, v2hv) %#codegen 
% Obtain the nring-neighbors of all the vertices of a surface mesh
% ALLV_NGBVS = OBTAIN_ALL_NRING_CURV( RING, NV, EDGES)
% ALLV_NGBVS = OBTAIN_ALL_NRING_CURV( RING, NV, EDGES, OPPHVS)
% ALLV_NGBVS = OBTAIN_ALL_NRING_CURV( RING, NV, EDGES, OPPHVS, V2HV)
%
% Input arguments
%    RING: the desired size of the ring
%    NV: number of vertices of curve
%    EDGES: element connectivity
%    OPPHVS: Opposite half-vertices (optional)
%    V2HV: Mapping from vertex to an incident half-vertex (optional)
%
% Output arguments
%    allv_ngbvs: List of neighboring vertices for each vertex in a format
%        similar to mixed elements. Note that for each vertex, the vertex 
%        itself is not included in the list.
%
% See also obtain_nring_curv

if nargin<4; opphvs = determine_opposite_halfvert( nv, edges); end
if nargin<5; v2hv = determine_incident_halfverts( edges, opphvs); end

minpnts = max( fix(1.5*ring),1);
avepnts = int32(2*ring+1);

ngbvs = nullcopy(zeros(13,1,'int32'));
vtags = false(nv, 1);
etags = false(size(edges,1), 1);

allv_ngbvs = nullcopy(zeros( fix(nv*avepnts*1.1),1,'int32'));

offset = int32(1);
for i=1:nv
    [ngbvs, nverts,vtags,etags] = obtain_nring_curv(i, ring, minpnts, ...
        edges, opphvs, v2hv, ngbvs, vtags, etags);

    assert( offset +nverts + 1 <= numel(allv_ngbvs));
    allv_ngbvs(offset) = nverts;
    allv_ngbvs(offset+1:offset+nverts) = ngbvs(1:nverts);

    offset = offset +nverts + 1;
end

allv_ngbvs = allv_ngbvs(1:offset-1);

function test  %#ok<DEFNU>
% Integrated test block. Test using command
%      "test_mcode obtain_all_nring_curv"
%!test
%! N = 20;
%! xs = [cos(2*pi*(0:N-1)/N); sin(2*pi*(0:N-1)/N)]';
%! edgs = [1:N; 2:N 1]';
%! allv_ngbvs = obtain_all_nring_curv( 1, N, edgs);
%! allv_ngbvs = obtain_all_nring_curv( 2, N, edgs);
%! allv_ngbvs = obtain_all_nring_curv( 3, N, edgs);
%! allv_ngbvs = obtain_all_nring_curv( 4, N, edgs);
%! allv_ngbvs = obtain_all_nring_curv( 5, N, edgs);
%! allv_ngbvs = obtain_all_nring_curv( 6, N, edgs);

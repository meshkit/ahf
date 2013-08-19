function [tets_hi, tris_hi, edges_hi, xs_hi] = uniform_refinement_mixed_hi2lowdim(xs,edges,tris,tets)
%This function refines a given mixed dimensional mesh uniformly. Each
%tetrahedra is refined into 8, each triange into 3, and each edge into 2.
% Input: mesh is the structure containing tets, tris, edges and their
% coordinates.


%#codegen -args {coder.typeof(0,[inf,3]), coder.typeof(int32(0), [inf,2]),
%# coder.typeof(int32(0), [inf,3]), coder.typeof(int32(0), [inf,4])}


nv = int32(size(xs,1));
%opphfs = determine_opposite_halfface( nv,tets);
opphfs = construct_halffaces(nv,tets);

MAXNEW = int32(1.25*size(tets,1));
tetedge_nodes = int32([1 2; 2 3; 3 1; 1 4; 2 4; 3 4]);
tetfaces = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
tetface_edg = int32([3 2 1; 1 5 4; 2 6 5; 3 4 6]);

%Extend vertex coordinates, tets, tris and edges
xs_hi = [xs; zeros( MAXNEW,size(xs,2))];
tets_hi = [tets, zeros(size(tets,1), 6, 'int32')];
tris_hi = [tris, zeros(size(tris,1), 3, 'int32')];
edges_hi = [edges, zeros(size(edges,1), 1, 'int32')];

% Loop through highest-dimensional elements
for tetID=1:int32(size(tets,1))
    % Insert points along edges or copy them if not yet inserted
    for edgeID=int32(1):6
        if tets_hi(tetID,4+edgeID)==0
            edg_v1 = tets(tetID,tetedge_nodes(edgeID,1));
            edg_v2 = tets(tetID,tetedge_nodes(edgeID,2));
            [nTets, tets_1ring, leids_1ring] = obtain_tet_edges_around_edge...
                (tetID, edgeID, tets, opphfs);
            % Insert a new vertex
            nv=nv+1;
            if nargout>3
                if nv>size(xs_hi,1) % Enlarge array if necessary
                    xs_hi = [xs_hi; zeros( int32(MAXNEW*0.1),size(xs,2))]; %#ok<AGROW>
                end
                xs_hi(nv,:) = 0.5*(xs(edg_v1,:)+xs(edg_v2,:));
            end
            
            for k=1:nTets
                tets_hi(tets_1ring(k),4+leids_1ring(k)) = nv;
            end
            % Check if this edge is given explicitly
            [isedg, eid] = find_edg_in_list(edg_v1, edg_v2, edges);
            if (isedg && (edges_hi(eid,3)==0))
                edges_hi(eid,3) = nv;
            end
        end
    end
    % Check if this face is given explicitly
    for faceID = int32(1):4
        face_nodes = tets(tetID,tetfaces(faceID,:));
        [isface, fid, map] = find_face_in_list(face_nodes, tris, tetface_edg(faceID,:));
        if (isface && tris_hi(fid,4)==0)
            tris_hi(fid,4:6) = tets_hi(tetID,4+map);
        end
    end
end

if nargout>3;
    xs_hi = xs_hi(1:nv,:);
end
end

function [isedg, eid] = find_edg_in_list(edg_v1, edg_v2, edges)
isedg = false; eid = int32(0);
sumedg = edg_v1 + edg_v2;
for ii=int32(1):size(edges,1)
    sumedge = sum(edges(ii,:),2);
    if (sumedg == sumedge ) && ((edg_v1 == edges(ii,1)) || (edg_v1 == edges(ii,2)))
        isedg = true;
        eid = ii;
        break
    end
end
end

function[isface, fid, map] = find_face_in_list(face_nodes, tris, edg_map)
isface = false; fid = int32(0); map = int32([0,0,0]);
sumface = sum(face_nodes,2);
for ii=int32(1):size(tris,1)
    sumtri = sum(tris(ii,:),2);
    if sumtri == sumface
        if ((face_nodes(1)==tris(ii,1) || face_nodes(1)==tris(ii,2) ||face_nodes(1)==tris(ii,3))  ...
                &&(face_nodes(2)==tris(ii,1) || face_nodes(2)==tris(ii,2) ||face_nodes(2)==tris(ii,3)))
            isface = true;
            fid = ii; 
            break
        end
    end
end
if isface
    tris_edg = int32([1 2; 2 3; 3 1]);
    for i=1:3
        sumedg = sum(tris(fid,tris_edg(i,:)),2);
        for j=1:3
            sumedgt = sum(face_nodes(tris_edg(j,:)),2);
            if (sumedg == sumedgt) && ((tris(fid,tris_edg(i,1)) == face_nodes(tris_edg(j,1)))...
                    || (tris(fid,tris_edg(i,1)) == face_nodes(tris_edg(j,2))))
                map(i) = edg_map(j);
            end
        end
    end
end
end





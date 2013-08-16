function [tets_hi, tris_hi, edges_hi, xs_hi] = construct_hiorder_fe3_mixed(xs,edges,tris,tets)
% Refinement sequence: edges->tris->tets

nv = int32(size(xs,1));
[sibhfs,v2hf] = construct_halffaces(nv,tets);
[sibhes,v2he] = construct_halfedges(nv,tris);

MAXNEW = int32(1.25*size(tets,1));
tetedge_nodes = int32([1 2; 2 3; 3 1; 1 4; 2 4; 3 4]);
triedge_nodes = int32([1 2; 2 3; 3 1]);

%Extend vertex coordinates, tets, tris and edges
xs_hi = [xs; zeros( MAXNEW,size(xs,2))];
tets_hi = [tets, zeros(size(tets,1), 6, 'int32')];
tris_hi = [tris, zeros(size(tris,1), 3, 'int32')];
edges_hi = [edges, zeros(size(edges,1), 1, 'int32')];

%% Refine edges
for edgeID=int32(1):size(edges,1)
    if (edges_hi(edgeID,3) == 0)
        % Insert a new vertex
        nv=nv+1;
        edges_hi(edgeID,3)=nv;
        % Obtain incident triangles on this explicit edge and update in tris_hi
        [nTris, tris_1ring, leids_1ring] = obtain_tri_edges_around_explicit_edge(edgeID, edges, tris, v2he, sibhes);
        for k=1:nTris
            tris_hi(tris_1ring(k),3+leids_1ring(k)) = nv;
        end
        
        % Obtain incident tets on this explicit edge and update tets_hi
        [nTets, tets_1ring, lfids_1ring] = obtain_tet_edges_around_explicit_edge(edges(edgeID,1), edges(edgeID,2), tets, v2hf, sibhfs);        
        for k=1:nTets
            tets_hi(tets_1ring(k),4+lfids_1ring(k)) = nv;
        end
        
        % Create coordinates of the new vertices
        if nargout>3
            if nv>size(xs_hi,1) % Enlarge array if necessary
                xs_hi = [xs_hi; zeros( int32(MAXNEW*0.1),size(xs,2))]; %#ok<AGROW>
            end
            xs_hi(nv,:) = 0.5*(xs(edges(edgeID,1),:)+xs(edges(edgeID,2),:));
        end
    end
end

%% Refine tris
etags=false(size(tets,1),1);
for triID=1:size(tris,1)
    % Obtain an incident tet for this triangle
    [clist]=fid2adj_cells(triID,tris,tets,sibhfs,v2hf, etags);
    if (clist(1)~=0)
        tetID = clist(1);
    end
    
    for edgeID=1:3
        if (tris_hi(triID,3+edgeID) == 0)
            % Insert vertex
            nv = nv+1;
            
            % Obtain incident triangles on this implicit edge and update in tris_hi
            [nTris, tris_1ring, leids_1ring] = obtain_tri_edges_around_implicit_edge(triID, edgeID, sibhes);
            for k=1:nTris
                tris_hi(tris_1ring(k),3+leids_1ring(k)) = nv;
            end
            
            % Obtain incident tets on this explicit edge and update in tets_hi
            edg_v1 = tris(triID,triedge_nodes(edgeID,1));
            edg_v2 = tris(triID,triedge_nodes(edgeID,2));
            %[eid] = obtain_eid(edg_v1,edg_v2,tetID,tets);
            %[nTets, tets_1ring, lfids_1ring] = obtain_tet_edges_around_implicit_edge(tetID, eid, tets, sibhfs); 
            [nTets, tets_1ring, lfids_1ring] = obtain_tet_edges_around_explicit_edge(edg_v1, edg_v2, tets, v2hf, sibhfs);
            for k=1:nTets
                tets_hi(tets_1ring(k),4+lfids_1ring(k)) = nv;
            end
            
            % Create the coordinates of the new vertices
            if nargout>3
                if nv>size(xs_hi,1) % Enlarge array if necessary
                    xs_hi = [xs_hi; zeros( int32(MAXNEW*0.1),size(xs,2))]; %#ok<AGROW>
                end
                xs_hi(nv,:) = 0.5*(xs(tris(triID,triedge_nodes(edgeID,1)),:)+xs(tris(triID,triedge_nodes(edgeID,2)),:));
            end
        end
    end
end

%% Refine tets
for tetID = 1:size(tets,1)
    for edgeID=int32(1):6
        if (tets_hi(tetID,4+edgeID) == 0)
            % Insert a new vertex
            nv=nv+1;
            
            % Obtain incident tets on this implicit edge and update tets_hi
            edg_v1 = tets(tetID,tetedge_nodes(edgeID,1));
            edg_v2 = tets(tetID,tetedge_nodes(edgeID,2));
            [nTets, tets_1ring, leids_1ring] = obtain_tet_edges_around_implicit_edge(tetID, edgeID, tets, sibhfs);
            for k=1:nTets
                tets_hi(tets_1ring(k),4+leids_1ring(k)) = nv;
            end
            
            % Create the coordinates of the new vertices
            if nargout>3
                if nv>size(xs_hi,1) % Enlarge array if necessary
                    xs_hi = [xs_hi; zeros( int32(MAXNEW*0.1),size(xs,2))]; %#ok<AGROW>
                end
                xs_hi(nv,:) = 0.5*(xs(edg_v1,:)+xs(edg_v2,:));
            end            
        end
    end
end
end



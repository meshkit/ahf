function comprehensive_test(mesh)


time_1ring_curv=0;
time_vid2adj_edges=0;
time_1ring_surf=0;
time_1ring_elems=0;

ftags=false(size(mesh.faces,1),1);
vtags=false(size(mesh.xs,1),1);
etags=false(size(mesh.faces,1),1);


for vid = int32(1) : size(mesh.v2hv,1)
    tic;
    [~, ~] = obtain_1ring_curv_NM( vid, mesh.edges, mesh.sibhvs, mesh.v2hv);
    time_1ring_curv=time_1ring_curv+toc;
    tic;
    [~, ~] = vid2adj_edges(vid,mesh.v2hv,mesh.sibhvs);
    time_vid2adj_edges=time_vid2adj_edges+toc;
    tic;
    [~,~,vtags,ftags] = obtain_1ring_surf_nmanfld( vid, mesh.faces, mesh.sibhes, mesh.v2he, vtags, ftags);
    time_1ring_surf=time_1ring_surf+toc;
    tic;
    [~, ~, etags] = obtain_1ring_elems_tet( vid, mesh.cells, mesh.sibhfs, mesh.v2hf, ngbes, etags);
    time_1ring_elems=time_1ring_elems+toc;
end

time_1ring_curv=time_1ring_curv/size(mesh.v2hv,1);
time_vid2adj_edges=time_vid2adj_edges/size(mesh.v2hv,1);
time_1ring_surf=time_1ring_surf/size(mesh.v2hv,1);
time_1ring_elems=time_1ring_elems/size(mesh.v2hv,1);

fprintf('Average 1 ring curve neighborhood: %g ',time_1ring_curv);
fprintf('Average adjacent edges: %g ',time_vid2adj_edges);
fprintf('Average 1 ring surface neighborhood: %g ',time_1ring_surf);
fprintf('Average 1 ring surface neighborhood: %g ',time_1ring_elems);


time_fid2adj_cells=0;
time_obtain_neighbor_faces=0;

for fid = int32(1) : size(mesh.faces,1)
    tic;
    [~,etags]=fid2adj_cells(fid,mesh.faces,mesh.tets,mesh.sibhfs, mesh.v2hf, etags);
    time_fid2adj_cells=time_fid2adj_cells+toc;
    tic;
    obtain_neighbor_faces(fid,mesh.faces,mesh.sibhes);
    time_obtain_neighbor_faces=time_obtain_neighbor_faces+toc;
end
time_fid2adj_cells=time_fid2adj_cells/size(mesh.faces,1);
time_obtain_neighbor_faces=time_obtain_neighbor_faces/size(mesh.faces,1);

fprintf('Average adjacent cells: %g ',time_fid2adj_cells);
fprintf('Average neighbor faces: %g ',time_obtain_neighbor_faces);


time_eid2adj_faces=0;

for eid = int32(1) : size(mesh.edges,1)
    tic;
    [~, ~, ftags]=eid2adj_faces(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,ftags);
    time_eid2adj_faces=time_eid2adj_faces+toc;
end
time_eid2adj_faces=time_eid2adj_faces/size(mesh.edges,1);
fprintf('Average adjacent faces: %g',time_eid2adj_faces);

time_neighbor_tets=0;
for cid = int32(1) : size(mesh.cells,1)
    tic;
    obtain_neighbor_tets(cid,mesh.sibhfs);
    time_neighbor_tets=time_neighbor_tets+toc;
end
time_neighbor_tets=time_neighbor_tets/size(mesh.cells,1);
fprintf('Average neigbor tets: %g',time_neighbor_tets);

function comprehensive_test(mesh) 

%#codegen -args { struct('xs', coder.typeof(0,[inf,3]),
%#codegen 'edges', coder.typeof(int32(0),[inf,2]),
%#codegen 'faces', coder.typeof(int32(0),[inf,inf]),
%#codegen 'cells', coder.typeof(int32(0),[inf,inf]), 
%#codegen 'v2hv', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2he', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2hf', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhvs', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhes', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhfs', coder.typeof(int32(0),[inf,inf])) }

ftags=false(size(mesh.faces,1),1);
vtags=false(size(mesh.xs,1),1);
etags=false(size(mesh.faces,1),1);
ngbes = int32( zeros(1024,1));

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [~, ~] = obtain_1ring_curv_NM( vid, mesh.edges, mesh.sibhvs, mesh.v2hv);
end
time_1ring_curv=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring curve neighborhood: %g ',time_1ring_curv);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [~, ~] = vid2adj_edges(vid,mesh.v2hv,mesh.sibhvs);
end
time_vid2adj_edges=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average adjacent edges: %g ',time_vid2adj_edges);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [~,~,vtags,ftags] = obtain_1ring_surf_nmanfld( vid, mesh.faces, mesh.sibhes, mesh.v2he, vtags, ftags);
end
time_1ring_surf=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring surface neighborhood: %g ',time_1ring_surf);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [~, ~, etags] = obtain_1ring_elems_tet( vid, mesh.cells, mesh.sibhfs, mesh.v2hf, ngbes, etags);
end
time_1ring_elems=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring surface neighborhood: %g ',time_1ring_elems);


t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)
    [~,etags]=fid2adj_cells(fid,mesh.faces,mesh.cells, mesh.sibhfs, mesh.v2hf, etags);
end
time_fid2adj_cells= (wtime - t1) / size(mesh.faces,1);
msg_printf('Average adjacent cells: %g ',time_fid2adj_cells);

t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)
    obtain_neighbor_faces(fid,mesh.faces,mesh.sibhes);
end
time_obtain_neighbor_faces = (wtime - t1) / size(mesh.faces,1);
msg_printf('Average neighbor faces: %g ',time_obtain_neighbor_faces);


t1 = wtime;
for eid = int32(1) : size(mesh.edges,1)
    [~, ~, ftags]=eid2adj_faces(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,ftags);
end
time_eid2adj_faces =(wtime - t1) / size(mesh.edges,1);
msg_printf('Average adjacent faces: %g',time_eid2adj_faces);

t1 = wtime;
for cid = int32(1) : size(mesh.cells,1)
    obtain_neighbor_tets(cid,mesh.sibhfs);
end
time_neighbor_tets = (wtime - t1) / size(mesh.edges,1);
msg_printf('Average neigbor tets: %g',time_neighbor_tets);

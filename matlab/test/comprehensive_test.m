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

etags=false(size(mesh.sibhfs,1)*size(mesh.sibhfs,2),1);
ngbes=zeros(1024,1,'int32');


t1=wtime;

for vid = int32(1) : size(mesh.v2hv,1)
    [ngbvs, nverts] = obtain_1ring_curv_NM( vid, mesh.edges, mesh.sibhvs, mesh.v2hv);
    ngbvs = refv(ngbvs); nverts=refv(nverts); %#ok<*NASGU>
end
time_1ring_curv=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring curve neighborhood: %g \n',time_1ring_curv);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [edge_list, nedges] = vid2adj_edges(vid,mesh.v2hv,mesh.sibhvs);
    edge_list=refv(edge_list); nedges=refv(nedges);
end
time_vid2adj_edges=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average adjacent edges: %g \n',time_vid2adj_edges);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [ngbvs, nverts, vtags,ftags] = obtain_1ring_surf_nmanfld( vid, mesh.faces, mesh.sibhes, mesh.v2he, vtags, ftags);
    ngbvs = refv(ngbvs); nverts=refv(nverts);
end
time_1ring_surf=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring surface neighborhood: %g \n',time_1ring_surf);

t1=wtime;
for vid = int32(1) : size(mesh.v2hv,1)
    [ngbes, nelems, etags] = obtain_1ring_elems_tet( vid, mesh.cells, mesh.sibhfs, mesh.v2hf, ngbes, etags);
    ngbes = refv(ngbes); nelems=refv(nelems);
end
time_1ring_elems=(wtime-t1)/size(mesh.v2hv,1);
msg_printf('Average 1 ring surface neighborhood: %g \n',time_1ring_elems);

ftags=false(size(mesh.faces,1),1);

t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)
    [clist,etags]=fid2adj_cells(fid,mesh.faces,mesh.cells, mesh.sibhfs, mesh.v2hf, etags);
    clist = refv(clist); etags = refv(etags);
end
time_fid2adj_cells= (wtime - t1) / size(mesh.faces,1);
msg_printf('Average adjacent cells: %g \n',time_fid2adj_cells);

t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)
    [ngbfaces, ~, ftags] = obtain_neighbor_faces(fid,mesh.sibhes,ftags);
    ngbfaces = refv( ngbfaces);   ftags=refv(ftags);
end
time_obtain_neighbor_faces = (wtime - t1) / size(mesh.faces,1);
msg_printf('Average neighbor faces: %g \n',time_obtain_neighbor_faces);

t1 = wtime;
flist=zeros(1000,1,'int32');
for eid = int32(1) : size(mesh.edges,1)
    [flist, nfaces, ftags]=eid2adj_faces(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,flist,ftags);
    flist = refv( flist); nfaces = refv( nfaces); ftags=refv(ftags);
end
time_eid2adj_faces =(wtime - t1) / size(mesh.edges,1);
msg_printf('Average adjacent edges: %g\n',time_eid2adj_faces);

t1 = wtime;
MAXEDGES=100;
elist=zeros(MAXEDGES,1,'int32');
for eid = int32(1) : size(mesh.edges,1)
    [elist, nedges]=eid2adj_edges(eid,mesh.edges,mesh.v2hv,mesh.sibhvs,elist);
    elist = refv( elist); nfaces = refv( nedges);
    elist(1:MAXEDGES,1)=int32(0);
end
time_eid2adj_faces =(wtime - t1) / size(mesh.edges,1);
msg_printf('Average adjacent faces: %g\n',time_eid2adj_faces);


t1 = wtime;
for cid = int32(1) : size(mesh.cells,1)
    ngbtets = obtain_neighbor_tets(cid,mesh.sibhfs);
    ngbtets = refv( ngbtets);
end
time_neighbor_tets = (wtime - t1) / size(mesh.edges,1);
msg_printf('Average neigbor tets: %g\n',time_neighbor_tets);
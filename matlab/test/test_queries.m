function test_queries(mesh)
%#codegen -args { struct('xs', coder.typeof(0,[inf,3]),
%#codegen 'edges', coder.typeof(int32(0),[inf,2]),
%#codegen 'faces', coder.typeof(int32(0),[inf,inf]),
%#codegen 'tets', coder.typeof(int32(0),[inf,inf]), 
%#codegen 'v2hv', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2he', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2hf', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhvs', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhes', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhfs', coder.typeof(int32(0),[inf,inf])) }

ftags=false(size(mesh.faces,1),1);
etags=false(size(mesh.tets,1),1);

% AQ1: For every vertex, obtain adjacent edges
t1 = wtime;
for vid = int32(1) : size(mesh.v2hv,1)     
    [edge_list, nedges] = vid2adj_edges(vid,mesh.v2hv,mesh.sibhvs); 
     edge_list=refv(edge_list); nedges=refv(nedges);     %#ok<*NASGU>
end
time_vid2adj_edges=(wtime-t1)/double(size(mesh.v2hv,1));
msg_printf('Average adjacent edges: Time = %g secs\n',time_vid2adj_edges);


% AQ2: For every edge, obtain adjacent faces
MAXFACES = 1000;
coder.varsize('flist',MAXFACES);
flist=zeros(MAXFACES,1,'int32');
t1 = wtime; 
for eid = int32(1) : size(mesh.edges,1)     
    [flist, nfaces, ftags]=eid2adj_faces(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,flist,ftags);
    flist = refv(flist); nfaces = refv(nfaces);   
end
time_eid2adj_faces=(wtime-t1)/size(mesh.edges,1);
msg_printf('Average adjacent faces: Time = %g secs\n',time_eid2adj_faces);

% AQ3: For every face, obtain adjacent cells
t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)   
    [clist,etags]=fid2adj_cells(fid,mesh.faces,mesh.tets,mesh.sibhfs, mesh.v2hf, etags);     
 clist = refv(clist); etags = refv(etags);
end
time_fid2adj_cells=(wtime-t1)/size(mesh.faces,1);
msg_printf('Average adjacent cells: Time = %g secs\n',time_fid2adj_cells);


%NQ1: For every edge, obtain neighbor edges
MAXEDGES=100;
elist=zeros(MAXEDGES,1,'int32');
t1 = wtime;
for eid = int32(1) : size(mesh.edges,1)
    [elist, nedges]=eid2adj_edges(eid,mesh.edges,mesh.v2hv,mesh.sibhvs,elist);
    elist = refv( elist); nfaces = refv( nedges);
    elist(1:MAXEDGES,1)=int32(0);
end
time_eid2adj_edges =(wtime - t1) / size(mesh.edges,1);
msg_printf('Average neighbor edges: Time = %g secs\n',time_eid2adj_edges);

%NQ2: For every face, obtain neighbor faces
t1 = wtime;
for fid = int32(1) : size(mesh.faces,1)   
    [ngbfaces, ~, ftags] = obtain_neighbor_faces(fid,mesh.sibhes,ftags);
    ngbfaces = refv( ngbfaces);   ftags=refv(ftags);
end
time_obtain_neighbor_faces=(wtime-t1)/size(mesh.faces,1);
msg_printf('Average neighbor faces: Time = %g secs\n',time_obtain_neighbor_faces);


%NQ3: For every cell, obtain neighbor cells
t1 = wtime;
for cid = int32(1) : size(mesh.tets,1)    
    ngbtets = obtain_neighbor_tets(cid,mesh.sibhfs); 
    ngbtets = refv( ngbtets);
end
time_neighbor_tets=(wtime-t1)/size(mesh.tets,1);
msg_printf('Average neighbor tets: Time = %g secs\n',time_neighbor_tets);

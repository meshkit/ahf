function ngbfaces = obtain_neighbor_faces(fid,mesh)
% For every face, obtain neighbor faces
n_edges=size(mesh.sibhes,2);
queue_size=0;
queue=[];
ftags=false(size(mesh.tris,1));
ftags(fid)=true;
nfaces=0;
ngbfaces=zeros(n_edges,1);
for leid = 1 : n_edges
    heid=mesh.sibhes(fid,leid);
    if heid~=0
        nfaces=nfaces+1;
        ngbfaces(nfaces,1)=heid2fid(heid);
        
        [queue,queue_size]=loop_sbihes(heid,mesh.sibhes,queue,queue_size,ftags);
    end
end
for i = 1 : queue_size
    nfaces=nfaces+1;
    ngbfaces(nfaces,1)=heid2fid(queue(i));
end
ngbfaces(nfaces+1:end,:)=[];

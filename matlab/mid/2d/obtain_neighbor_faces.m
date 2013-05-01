function ngbfaces = obtain_neighbor_faces(fid,tris,sibhes) %#codegen
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,3])}
% For every face, obtain neighbor faces
coder.extrinsic('fprintf');
n_edges=size(sibhes,2);
MAXQUEUESIZE=50;
queue_size=0;
queue=zeros(1,MAXQUEUESIZE);
ftags=false(size(tris,1),1);
ftags(fid,1)=true;
nfaces=0;
ngbfaces=zeros(MAXQUEUESIZE,1);
coder.varsize('ngbfaces');
for leid = 1 : n_edges
    heid=sibhes(fid,leid);
    if heid~=0
        nfaces=nfaces+1;
        ngbfaces(nfaces,1)=heid2fid(heid);
        
        [queue,queue_size,ftags]=loop_sbihes(heid,sibhes,queue,queue_size,ftags);
    end
end
fprintf('%d\n',queue_size);
for i = 1 : queue_size
    nfaces=nfaces+1;
    ngbfaces(nfaces,1)=heid2fid(queue(i));
end
ngbfaces(nfaces+1:end,:)=[];

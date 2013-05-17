function ngbfaces = obtain_neighbor_faces(fid,tris,sibhes,varargin) %#codegen
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,3])}
%#codegen obtain_neighbor_faces_usestruct -args {int32(0), coder.typeof(int32(0), [inf,3]),
%#codegen struct('fid',coder.typeof(int32(0), [inf,3]),'leid',coder.typeof(int8(0), [inf,3])), false}
% For every face, obtain neighbor faces
coder.extrinsic('fprintf');
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    n_edges=size(sibhes,2);
else
    n_edges=size(sibhes.fid,2);
end
MAXQUEUESIZE=50;
queue_size=0;
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    queue=zeros(1,MAXQUEUESIZE);
else
    queue=struct('fid',zeros(1,MAXQUEUESIZE),'leid',zeros(1,MAXQUEUESIZE));
end
ftags=false(size(tris,1),1);
ftags(fid,1)=true;
nfaces=0;
ngbfaces=zeros(MAXQUEUESIZE,1);
coder.varsize('ngbfaces');
for leid = 1 : n_edges
    if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
        heid=sibhes(fid,leid);
        if heid~=0
            nfaces=nfaces+1;
            ngbfaces(nfaces,1)=heid2fid(heid);
        
            [queue,queue_size,ftags]=loop_sbihes(heid,sibhes,queue,queue_size,ftags);
        end
    else
        heid.fid=sibhes.fid(fid,leid);
        heid.leid=sibhes.leid(fid,leid);
        if heid.fid~=0
            nfaces=nfaces+1;
            ngbfaces(nfaces,1)=heid.fid;
        
            [queue,queue_size,ftags]=loop_sbihes(heid,sibhes,queue,queue_size,ftags,true);
        end
    end
end
%fprintf('%d\n',queue_size);
for i = 1 : queue_size
    nfaces=nfaces+1;
    if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
        ngbfaces(nfaces,1)=heid2fid(queue(i));
    else
        ngbfaces(nfaces,1)=queue.fid(i);
    end
end
ngbfaces(nfaces+1:end,:)=[];

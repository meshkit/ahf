function [ngbfaces, nfaces, ftags] = obtain_neighbor_faces(fid,sibhes,ftags,varargin) %#codegen
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,3]), coder.typeof(false, [inf,1])}
%#codegen obtain_neighbor_faces_usestruct -args {int32(0), 
%#codegen struct('fid',coder.typeof(int32(0), [inf,3]),'leid',coder.typeof(int8(0), [inf,3])), coder.typeof(false, [inf,1]), false}
% For every face, obtain neighbor faces
coder.extrinsic('fprintf');
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    n_edges=size(sibhes,2);
else
    n_edges=size(sibhes.fid,2);
end
MAXQUEUESIZE=100;
queue_size=0;
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    queue=zeros(MAXQUEUESIZE,1);
else
    queue=struct('fid',zeros(MAXQUEUESIZE,1),'leid',zeros(MAXQUEUESIZE,1));
end
%ftags=false(size(tris,1),1);
ftags(fid,1)=true;
nfaces=0;
ngbfaces=zeros(MAXQUEUESIZE,1);
%coder.varsize('ngbfaces');
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
%ngbfaces(nfaces+1:end,:)=[];
ftags(fid,1)=false; 
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    for i =  1 : queue_size
        ftags(heid2fid(queue(i,1)),1)=false;
    end
else
    ftags(queue.fid(1:queue_size,1),1)=false;
end
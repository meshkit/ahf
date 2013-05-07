function [ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld...
    ( vid, tris, sibhes, v2he, vtags, ftags) %#codegen

%function [ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_nring_surf...
%( vid, ring, minpnts, tris, sibhes, v2he, ngbvs, vtags, ftags, ngbfs) %#codegen
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),
%#codegen     coder.typeof(false, [inf,1]),coder.typeof(false, [inf,1])}
coder.extrinsic('warning');

MAXNPNTS = int32(128);

fid = heid2fid(v2he(vid)); 
nverts=int32(0); nfaces=int32(0);

ngbvs=zeros(MAXNPNTS,1,'int32');   coder.varsize('ngbvs');

maxnf = 2*MAXNPNTS; ngbfs = zeros(maxnf,1, 'int32'); 
coder.varsize('ngbfs');  
if ~fid; return; end;

MAXQUEUE=maxnf;
queue=zeros(MAXQUEUE,1,'int32');
[queue,tris,queue_size,ftags,ngbfs]=start(vid,v2he,sibhes,tris,queue,ftags,ngbfs);
[ngbfs,nfaces,ftags]=collect(vid,sibhes,queue,queue_size,tris,ftags,ngbfs);
[ngbvs,nverts,ngbfs,vtags,ftags]=ngbfs2ngbvs(vid,ngbfs,nfaces,ngbvs,vtags,ftags,tris);
ngbfs(nfaces+1,:)=[];
ngbvs(nverts+1,:)=[];
end

function [ngbvs,ngbvs_size,ngbfs,vtags,ftags]=ngbfs2ngbvs(vid,ngbfs,ngbfs_size,ngbvs,vtags,ftags,tris)
ngbvs_size=int32(0);
vtags(vid)=true;
for i = 1 : ngbfs_size
    fid=ngbfs(i);
    for j = 1 : 3
        lvid=tris(fid,j);
        if ~vtags(lvid)
            ngbvs_size=ngbvs_size+1;
            ngbvs(ngbvs_size)=lvid;
            vtags(lvid)=true;
        end
        ftags(fid)=false;
    end
end
vtags(vid)=false;
vtags(ngbvs(1:ngbvs_size,1),1)=false;
end


function [queue,faces,queue_size,ftags,ngbfs]=start(vid,v2he,sibhes,faces,queue,ftags,ngbfs)
%% start the cycle
%  collect all the sibling half-edges around initial half-edge
he=v2he(vid);
he2=another_halfedge(vid,he,faces);
queue_size=0;
%queue(queue_size)=he2;
ftags(heid2fid(he))=true;

ngbfs(1)=heid2fid(he);

[queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags);
[queue,queue_size,ftags]=loop_sbihes(he2,sibhes,queue,queue_size,ftags);
end

function [ngbfs,ngbfs_size,ftags]=collect(vid,sibhes,queue,queue_size,faces,ftags,ngbfs)
ngbfs_size=int32(1);
if (queue_size<1); return; end;
queue_top=1;

while queue_top<=queue_size
    he=queue(queue_top);
    queue_top=queue_top+1;
    [he2,fid]=another_halfedge(vid,he,faces);
    if ftags(fid); continue; end;    
    ftags(fid)=true;
    
    [queue,queue_size,ftags]=loop_sbihes(he2,sibhes,queue,queue_size,ftags);
    
    ngbfs_size=ngbfs_size+1;
    ngbfs(ngbfs_size)=fid;   
end
end

function [he2,fid]=another_halfedge(vid,he,faces)
if ~isstruct(he)
    fid=heid2fid(he);
    lid=heid2leid(he);
else
    fid=he.fid;
    lid=he.lid;
end
next=[2,3,1];
prev=[3,1,2];
if (faces(fid,lid)==vid)
    lid2=prev(lid);
else
    lid2=next(lid);
end
he2=fleids2heid(fid, lid2);
end

function [queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags)
fid=heid2fid(he);
lid=heid2leid(he);
if (lid==0); return; end;
sibhe=sibhes(fid,lid);

while sibhe 
    fid = heid2fid(sibhe); 
    assert(fid~=0); % fid can not be zero if the algorithm is correct
    if ~ftags(fid)   
        % face have not been visited yet, add he to queue
        queue_size=queue_size+1;
        queue(queue_size)=sibhe;  
    end
    lid = heid2leid(sibhe);
    assert(lid~=0);
    if (sibhes(fid,lid)==he); break; end; 
    sibhe=sibhes(fid,lid);
end
end
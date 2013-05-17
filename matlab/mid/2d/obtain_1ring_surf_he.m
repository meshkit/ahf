function [heid,ftags] = obtain_1ring_surf_he...
    ( vid, second_vid, tris, sibhes, v2he, ftags)

%function [ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_nring_surf...
%( vid, ring, minpnts, tris, sibhes, v2he, ngbvs, vtags, ftags, ngbfs) %#codegen
coder.extrinsic('warning');

heid=int32(0);
if nargin>=8; assert( islogical( vtags)); end
if nargin>=9; assert( islogical(ftags)); end

fid = heid2fid(v2he(vid)); 

if ~fid; return; end;

MAXQUEUE=100;
queue=zeros(MAXQUEUE,1,'int32');
[queue,tris,queue_size,ftags]=start(vid,v2he,sibhes,tris,queue,ftags);
%fprintf('starting collect_n_compare...\n');
[heid,ftags]=collect_n_compare(vid,sibhes,queue,queue_size,tris,ftags,second_vid);
%fprintf('done\n');
end

function [queue,faces,queue_size,ftags]=start(vid,v2he,sibhes,faces,queue,ftags)
%% start the cycle
%  collect all the sibling half-edges around initial half-edge
he=v2he(vid);
he2=another_halfedge(vid,he,faces);
queue_size=2;
queue(1)=he;
queue(2)=he2;
ftags(heid2fid(he))=true;

[queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags);
[queue,queue_size,ftags]=loop_sbihes(he2,sibhes,queue,queue_size,ftags);
end

function [he,ftags]=collect_n_compare(vid,sibhes,queue,queue_size,faces,ftags,second_vid)
he=int32(0);

if (queue_size<1); return; end;
queue_top=1;
next=[2,3,1];
counter = 0;
while queue_top<=queue_size && counter < 200
    he=queue(queue_top);
    
    if (nargin>6)
        if faces(heid2fid(he),heid2leid(he))==vid
            if faces(heid2fid(he),next(heid2leid(he)))==second_vid
                return;
            end
        elseif faces(heid2fid(he),heid2leid(he))==second_vid
                return;
        end
    end
    
    queue_top=queue_top+1;
    [he2,fid]=another_halfedge(vid,he,faces);
    if ftags(fid); continue; end;    
    ftags(fid)=true;
   % fprintf('starting loop...');
    [queue,queue_size,ftags]=loop_sbihes(he2,sibhes,queue,queue_size,ftags);
   % fprintf('done\n');
    counter=counter+1;
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
counter=0;
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
    counter=counter+1;
end
end
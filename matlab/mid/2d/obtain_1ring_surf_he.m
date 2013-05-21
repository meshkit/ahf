function [heid,ftags] = obtain_1ring_surf_he...
    ( vid, second_vid, tris, sibhes, v2he, ftags)

%function [ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_nring_surf...
%( vid, ring, minpnts, tris, sibhes, v2he, ngbvs, vtags, ftags, ngbfs) %#codegen
coder.extrinsic('warning');

heid=int32(0);
if nargin>=8; assert( islogical( vtags)); end
if nargin>=9; assert( islogical(ftags)); end

if isstruct(v2he)
    fid = v2he.fid(vid);
else
    fid = heid2fid(v2he(vid));
end

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
if isstruct(v2he)
    he.fid=v2he.fid(vid);   he.leid=v2he.leid(vid);
else
    he=v2he(vid);
end
he2=another_halfedge(vid,he,faces);
queue_size=2;
if isstruct(v2he)
    queue.fid(1)=he.fid;
    queue.fid(2)=he2.fid;
    ftags(he.fid)=true;
else
    queue(1)=he;
    queue(2)=he2;
    ftags(heid2fid(he))=true;
end

[queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags);
[queue,queue_size,ftags]=loop_sbihes(he2,sibhes,queue,queue_size,ftags);
end

function [he,ftags]=collect_n_compare(vid,sibhes,queue,queue_size,faces,ftags,second_vid)
if isstruct(sibhes)
    he.fid=int32(0); he.leid=int8(0);
else
    he=int32(0);
end

if (queue_size<1); return; end;
queue_top=1;
next=[2,3,1];
counter = 0;
while queue_top<=queue_size && counter < 500
    if isstruct(sibhes)
        he.fid=queue.fid(queue_top);     he.leid=queue.leid(queue_top);
    else
        he=queue(queue_top);
    end
    
    if ~isstruct(sibhes)
        if (nargin>6)
            if faces(heid2fid(he),heid2leid(he))==vid
                if faces(heid2fid(he),next(heid2leid(he)))==second_vid
                    return;
                end
            elseif faces(heid2fid(he),heid2leid(he))==second_vid
                return;
            end
        end
    else
        if (nargin>6)
            if faces(he.fid,he.leid)==vid
                if faces(he.fid,next(he.leid))==second_vid
                    return;
                end
            elseif faces(he.fid,he.leid)==second_vid
                return;
            end
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
if isstruct(he)
    he2.fid=fid;   he2.leid=lid2;
else
    he2=fleids2heid(fid, lid2);
end
end

function [queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags)
if isstruct(he)
    fid=he.fid;
    lid=he.leid;
else
    fid=heid2fid(he);
    lid=heid2leid(he);
end

if (lid==0); return; end;
if isstruct(sibhes)
    sibhe.fid=sibhes.fid(fid,lid);     sibhe.leid=sibhes.leid(fid,lid);
else
    sibhe=sibhes(fid,lid);
end
counter=0;
while (~isstruct(sibhe)&&sibhe) || (isstruct(sibhe)&&sibhe.fid)
    if ~isstruct(sibhe)
        fid = heid2fid(sibhe);
    else
        fid = sibhe.fid;
    end
    assert(fid~=0); % fid can not be zero if the algorithm is correct
    if ~ftags(fid)
        % face have not been visited yet, add he to queue
        queue_size=queue_size+1;
        if isstruct(sibhe)
            queue.fid(queue_size)=sibhe.fid;   queue.leid(queue_size)=sibhe.leid;
        else
            queue(queue_size)=sibhe;
        end
    end
    if ~isstruct(sibhe)
        lid = heid2leid(sibhe);
        assert(lid~=0);
        if (sibhes(fid,lid)==he); break; end;
        sibhe=sibhes(fid,lid);
        counter=counter+1;
    else
        lid = sibhe.leid;
        assert(lid~=0);
        if (sibhes.fid(fid,lid)==he.fid && sibhes.leid(fid,lid)==he.leid); break; end;
        sibhe.fid=sibhes.fid(fid,lid);    sibhe.leid=sibhes.leid(fid,lid);
        counter=counter+1;
    end
end
end
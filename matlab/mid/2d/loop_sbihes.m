function [queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags,varargin)
if nargin<6 || isempty(varargin{1}) || ~islogical(varargin{1})
    fid=heid2fid(he);
    lid=heid2leid(he);
else
    fid=he.fid;
    lid=he.leid;
end

if (fid==0)||(lid==0); return; end;

if nargin<6 || isempty(varargin{1}) || ~islogical(varargin{1})
    sibhe=sibhes(fid,lid);
else
    sibhe.fid=sibhes.fid(fid,lid);
    sibhe.leid=sibhes.leid(fid,lid);
end

if nargin<6 || isempty(varargin{1}) || ~islogical(varargin{1})
    while sibhe
        fid = heid2fid(sibhe);
        assert(fid~=0); % fid can not be zero if the algorithm is correct
        if ~ftags(fid,1)
            % face have not been visited yet, add he to queue
            queue_size=queue_size+1;
            queue(queue_size)=sibhe;
        end
        lid = heid2leid(sibhe);
        assert(lid~=0);
        if (sibhes(fid,lid)==he); break; end;
        sibhe=sibhes(fid,lid);
    end
else
    while sibhe.fid
        fid=sibhe.fid;
        assert(fid~=0); % fid can not be zero if the algorithm is correct
        if ~ftags(fid,1)
            % face have not been visited yet, add he to queue
            queue_size=queue_size+1;
            queue.fid(queue_size)=sibhe.fid;
            queue.leid(queue_size)=sibhe.leid;
        end
        leid = sibhe.leid;
        assert(leid~=0);
        if (sibhes.fid(fid,leid)==he.fid && sibhes.leid(fid,leid)==he.leid); break; end;
        sibhe.fid=sibhes.fid(fid,leid);
        sibhe.leid=sibhes.leid(fid,leid);
    end
end
end
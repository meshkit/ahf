function [queue,queue_size,ftags]=loop_sbihes(he,sibhes,queue,queue_size,ftags)
fid=heid2fid(he);
lid=heid2leid(he);
if (lid==0); return; end;
sibhe=sibhes(fid,lid);

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
end
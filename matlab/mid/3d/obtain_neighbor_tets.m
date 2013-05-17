function ngbtets = obtain_neighbor_tets(cid,sibhfs,varargin)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,4])}
%#codegen obtain_neighbor_tets_usestruct -args 
%#codegen {int32(0), struct('cid',coder.typeof(int32(0), [inf,4]), 'lfid', coder.typeof(int8(0), [inf,4])),false}
% For every cell, obtain neighbor cells
n_ngbtets=0;
ngbtets=zeros(4,1);
coder.varsize('ngbtets',4);
if nargin<3 || isempty(varargin{1}) || ~islogical(varargin{1})
    for lfid = 1 : 4
        oppfid = sibhfs(cid, lfid);
        if oppfid~=0
            n_ngbtets=n_ngbtets+1;
            ngbtets(n_ngbtets,1)=hfid2cid(oppfid);
        end
    end
else
    for lfid = 1 : 4
        oppfid = sibhfs.cid(cid, lfid);
        if oppfid ~=0
            n_ngbtets=n_ngbtets+1;
            ngbtets(n_ngbtets,1)=oppfid;
        end
    end
end
ngbtets(n_ngbtets+1:end)=[];

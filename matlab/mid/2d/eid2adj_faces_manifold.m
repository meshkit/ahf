function [success, flist, nfaces, ftags]=eid2adj_faces_manifold(eid,edges,tris,v2he,sibhes,flist,ftags,varargin)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,1]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}

%#codegen eid2adj_faces_top_usestruct -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen struct('fid',coder.typeof(int32(0), [inf,1]),'leid',coder.typeof(int8(0), [inf,1])),
%#codegen struct('fid',coder.typeof(int32(0), [inf,3]),'leid',coder.typeof(int8(0), [inf,3])),coder.typeof(int32(0), [inf,1]),
%#codegen coder.typeof(false, [inf,1]),false}

% For edge, obtain adjacent faces
% edge->half-edge->opposite half-edges
type_struct=isstruct(sibhes);
nfaces = int32(0);
% Find half-edge
[success,heid] = obtain_1ring_surf_he_manifold(edges(eid,1), edges(eid,2), tris, sibhes, v2he);
if (~success)
    [success,heid] = obtain_1ring_surf_he_manifold(edges(eid,2), edges(eid,1),  tris, sibhes, v2he);
end
if ~success
%       fprintf('fallback\n');
       nfaces = int32(0);return;   
       
else
    % Check if the half-edge is a manifold or not
    if isstruct(heid)
        opp.fid=sibhes.fid(heid.fid,heid.lid);  opp.lid=sibhes.lid(heid.fid,heid.lid);
        oppopp.fid = sibhes.fid(opp.fid,opp.lid); oppopp.lid = sibhes.leid(opp.fid,opp.lid);
        manifold = (oppopp.fid==heid.fid)&&(oppopp.lid==heid.lid);
    else
        opp=sibhes(heid2fid(heid),heid2leid(heid));
        oppopp = sibhes(heid2fid(opp),heid2leid(opp)); 
        manifold = (heid2fid(oppopp)==heid2fid(heid))&&(heid2leid(oppopp)==heid2leid(heid));
    end
    
    if ~manifold
        MAXFACES=150;
        if nargin<8 || ~type_struct
            flist(1,1)=int32(heid2fid(heid));
        else
            flist(1,1)=int32(heid.fid);
        end
        nfaces=int32(1);
        if nargin<8 || ~type_struct
            [helist,nhes,ftags]=loop_sbihes(heid,sibhes,zeros(MAXFACES,1),0,ftags);
        else
            helist.fid=zeros(MAXFACES,1);   helist.leid=zeros(MAXFACES,1);
            [helist,nhes,ftags]=loop_sbihes(heid,sibhes,helist,0,ftags,true);
        end
        
        for i = 1 : nhes
            nfaces=nfaces+1;
            if nargin<8 || ~type_struct
                flist(nfaces,1)=int32(heid2fid(helist(i)));
            else
                flist(nfaces,1)=int32(helist.fid(i));
            end
        end
    end
    
end




end



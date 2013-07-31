function [flist, nfaces, ftags]=eid2adj_faces_nonmanifold(eid,edges,tris,v2he,sibhes,flist,ftags,type_struct)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,1]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}

%#codegen eid2adj_faces_top_usestruct -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen struct('fid',coder.typeof(int32(0), [inf,1]),'leid',coder.typeof(int8(0), [inf,1])),
%#codegen struct('fid',coder.typeof(int32(0), [inf,3]),'leid',coder.typeof(int8(0), [inf,3])),coder.typeof(int32(0), [inf,1]),
%#codegen coder.typeof(false, [inf,1]),false}

% For edge, obtain adjacent faces
% edge->half-vertex->half-edge->sibling half-edges
MAXFACES=150;
nfaces=int32(0);
[heid,ftags] = obtain_1ring_surf_he( edges(eid,1), edges(eid,2), tris, sibhes, v2he, ftags);

if nargin<8 || ~type_struct
    if (heid==0);  flist=zeros(1,1,'int32'); return;   end;
else
    if (heid.fid==0);  flist=zeros(1,1,'int32'); return;   end;
end    

% coder.varsize('flist',MAXFACES);
% flist=zeros(MAXFACES,1,'int32');
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
%flist(nfaces+1:MAXFACES,:)=[];











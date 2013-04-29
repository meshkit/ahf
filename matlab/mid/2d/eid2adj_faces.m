function [flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,3]),coder.typeof(false, [inf,1])}
% For edge, obtain adjacent faces
% edge->half-vertex->half-edge->sibling half-edges
MAXFACES=150;
nfaces=0;

[heid,ftags] = obtain_1ring_surf_he( edges(eid,1), edges(eid,2), tris, sibhes, v2he, ftags);
ftags(ftags==true)=false;
if (heid==0);  flist=int32(0); return;   end;


coder.varsize('flist',MAXFACES);
flist=zeros(MAXFACES,1,'int32');
flist(1,1)=int32(heid2fid(heid));
nfaces=1;
[helist,nhes,ftags]=loop_sbihes(heid,sibhes,zeros(20,1),0,ftags);
for i = 1 : nhes
    nfaces=nfaces+1;
    flist(nfaces,1)=int32(heid2fid(helist(i)));
end
flist(nfaces+1:MAXFACES,:)=[];











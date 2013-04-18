function [flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags)
% For edge, obtain adjacent faces
% edge->half-vertex->half-edge->sibling half-edges


[heid,ftags] = obtain_1ring_surf_he( edges(eid,1), edges(eid,2), tris, sibhes, v2he, ftags);
ftags(ftags==true)=false;
if (heid==0) 
    flist=[];
    nfaces=0;
    return;
end
    
flist(1,1)=heid2fid(heid);
nfaces=1;
[helist,nhes,ftags]=loop_sbihes(heid,sibhes,zeros(20,1),0,ftags);
for i = 1 : nhes
    nfaces=nfaces+1;
    flist(nfaces,1)=heid2fid(helist(i));
end












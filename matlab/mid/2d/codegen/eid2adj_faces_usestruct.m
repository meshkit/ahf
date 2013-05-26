function [flist, nfaces, ftags]=eid2adj_faces_usestruct(eid,edges,tris,v2he,sibhes,flist,ftags,usestruct)
[flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,flist,ftags,usestruct);
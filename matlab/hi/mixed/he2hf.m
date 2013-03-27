function [hfid,etags] = he2hf(heid,etags)

fid=heid2fid(heid);
leid=heid2leid(heid);
origin_vertex=mesh.faces(fid,leid);
next=[2,3,1];
terminal_vertex=mesh.edges(fid,next(leid));

[hfid,etags] = obtain_1ring_elems_tet_he( origin_vertex, terminal_vertex, mesh, etags);
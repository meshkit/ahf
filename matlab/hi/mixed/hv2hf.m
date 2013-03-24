function [hfid,etags] = hv2hf(hvid,mesh,etags)
eid=hvid2eid(hvid);
lvid=hvid2lvid(hvid);

endpoint=[2,1];

origin_vertex=mesh.edges(eid,lvid);
terminal_vertex=mesh.edges(eid,endpoint(lvid));

[hfid,etags] = obtain_1ring_elems_tet_he( origin_vertex, terminal_vertex, mesh, etags);
function [xs, nverts, tets, ntets]=uref_tet_by_bdry(xs, nverts, tets, ntets, bdry_edge, bdry_face, deg)
if deg==1
    return
end
down_edge =bdry_edge(1:3,:);
down_face =bdry_face(1,:);
istrt=1;
for level=2:deg
    local_deg =deg-level+1;
    top_edge =bdry_face(2:4,istrt:istrt+local_deg);
    istrt =istrt+local_deg+1;
    ntets =ntets+1;
    tets(ntets,:) =[down_edge(3,end-1), down_edge(1,1), down_edge(1,2), top_edge(1,1)];
    for i=2:local_deg+1
        ntets =ntets+1;
        tets(ntets,:) =[down_face(i-1), down_edge(1,i), top_edge(1,i), top_edge(1,i-1)];
        ntets =ntets+1;
        tets(ntets,:) =[down_face(i-1), down_edge(1,i), down_face(i), top_edge(1,i)];
        ntets =ntets+1;
        tets(ntets,:) =[down_face(i), down_edge(1,i), down_edge(1,i+1), top_edge(1,i)];
    end
    tris=[top_edge(1,1), top_edge(2,1), top_edge(3,1)]; ntris=1;
    [xs, nverts, tris, ntris, upper_face]=uref_base_bdry_old(xs, nverts, tris, ntris, top_edge, local_deg);
    out =top_edge(1,:);
    out_lower =down_face(1:local_deg+1);
    istrt_inner=1;
    for i=1:local_deg
        in =upper_face(istrt_inner:istrt_inner+local_deg-i);
        in_lower =down_face(istrt_inner+local_deg+1:istrt_inner+local_deg-i+local_deg+1);
        istrt_inner=istrt_inner+local_deg-i+1;
        ntets =ntets+1;
        tets(ntets,:) =[out_lower(1), out_lower(2), in_lower(1), in(1)];
        ntets =ntets+1;
        tets(ntets,:) =[out_lower(1), out(2), in(1), out(1)];
        ntets =ntets+1;
        tets(ntets,:) =[out_lower(1), out_lower(2), in(1), out(2)];
        for j=1:local_deg-i
            ntets =ntets+1;
            tets(ntets,:) =[in(j), out_lower(j+1), in(j+1), out(j+1)];
            ntets =ntets+1;
            tets(ntets,:) =[in_lower(j), out_lower(j+1), in(j+1), in(j)];
            ntets =ntets+1;
            tets(ntets,:) =[in_lower(j), out_lower(j+1), in_lower(j+1), in(j+1)];
            ntets =ntets+1;
            tets(ntets,:) =[in_lower(j+1), out_lower(j+1), out_lower(j+2), in(j+1)];
            ntets =ntets+1;
            tets(ntets,:) =[out_lower(j+1), out(j+2), in(j+1), out(j+1)];
            ntets =ntets+1;
            tets(ntets,:) =[out_lower(j+1), out_lower(j+2), in(j+1), out(j+2)];
        end
        out =in;
        out_lower =in_lower;
    end
    down_edge=top_edge;
    down_face =upper_face;
end
ntets =ntets+1;
tets(ntets,:) =[bdry_edge(4,end-1), bdry_edge(5,end-1), bdry_edge(6,end-1), bdry_edge(4,end)];
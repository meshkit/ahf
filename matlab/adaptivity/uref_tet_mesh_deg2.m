function [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg2(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff)
if nargin==0
    xs=[1 0 0;...
    0 1 0;...
    0 0 0;...
    0 0 1;...
    0 0 -1];
    nverts =5; nv_orig=5;
    tets=[1 2 3 4;2 1 3 5];
    ntets=2;
    pre_ntets=0;
    deg=2;
    [sibhfs, ~] =construct_halffaces(nverts,tets);
    figure
    tetramesh(tets,xs);
    parent_id =zeros(0,1);parent_coeff=zeros(0,1);
end
if deg==1
    return
end
if deg~=2
    error('degree 2 refinment only');
end
assert(size(parent_id,1)==size(parent_coeff,1));

edge2nodes=[1 2;2 3;3 1;1 4;2 4;3 4];
nonorien_face=[1 2 3;1 2 4;2 3 4;3 1 4];
nonorien_f2edges=[1 2 3;1 5 4;2 6 5;3 4 6];

num_tets=ntets-pre_ntets;
xs =[xs;zeros(int32(1.25*num_tets),3)];
bdry_node=zeros(num_tets,6);
% for parent
strt_id =size(parent_id,1);
parent_id =[parent_id; zeros(int32(1.25*num_tets),1)];
parent_coeff =[parent_coeff; zeros(int32(1.25*num_tets),4)];

for i=1:num_tets
    tet_id=i+pre_ntets;
    tet_conn =tets(tet_id,:);
    for j=1:6
        if bdry_node(i,j)~=0
            continue
        end
        v1 =tet_conn(edge2nodes(j,1));
        v2 =tet_conn(edge2nodes(j,2));
        step =(xs(v2,:)-xs(v1,:))/2;
        nverts =nverts+1;
        xs(nverts,:) =xs(v1,:)+step;
        [num_ngbts, tets_1ring, leids_1ring] =obtain_tet_edges_around_edge(i,j, tets(pre_ntets+1:ntets,:), sibhfs);
        % for parent
        strt_id =strt_id+1;
        parent_id(strt_id) =tet_id;
        parent_coeff(strt_id,edge2nodes(j,:)) =[1/2 1/2];
        
        for k=1:num_ngbts
            bdry_node(tets_1ring(k),leids_1ring(k))=nverts;
        end
    end
end
xs =xs(1:nverts,:); parent_id=parent_id(1:strt_id); parent_coeff=parent_coeff(1:strt_id,:);

tets =[tets; zeros(8*num_tets, 4)];
for i=1:num_tets
    tet_id=i+pre_ntets;
    tet_conn =tets(tet_id,:);
    temp_bdry=zeros(6,3);
    for j=1:6
        temp_bdry(j,1) =tet_conn(edge2nodes(j,1));
        temp_bdry(j,2) =bdry_node(i,j);
        temp_bdry(j,3) =tet_conn(edge2nodes(j,2));
    end
    temp_face_hi_level=zeros(4,3);
    for j=1:4
        edge1=nonorien_f2edges(j,3);
        edge2=nonorien_f2edges(j,2);
        temp_face_hi_level(j,:) =[bdry_node(i,edge1), bdry_node(i,edge2), tet_conn(nonorien_face(j,3))];
    end
    [xs, nverts, tets, ntets]=uref_tet_by_bdry(xs, nverts, tets, ntets, temp_bdry, temp_face_hi_level, deg);
end

%test case
figure
tetramesh(tets(pre_ntets+1:ntets,:),xs);
tol=1e-10;
for i=nv_orig+1:nverts
    xs_linear =parent_coeff(i-nv_orig,:)*xs(tets(parent_id(i-nv_orig),:),:);
    assert(norm(xs(i,:)-xs_linear)<tol);
end
    
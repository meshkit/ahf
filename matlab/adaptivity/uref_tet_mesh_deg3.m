function [xs, nverts, tets, ntets, parent_id, parent_coeff]=uref_tet_mesh_deg3(xs, nverts, nv_orig, tets, pre_ntets, ntets, deg, sibhfs, parent_id, parent_coeff)
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
    deg=3;
    [sibhfs, ~] =construct_halffaces(nverts,tets);
    figure
    tetramesh(tets,xs);
    parent_id =zeros(0,1);parent_coeff=zeros(0,1);
end
if deg==1
    return
end
if deg~=3
    error('degree 3 refinment only');
end
assert(size(parent_id,1)==size(parent_coeff,1));

edge2nodes=[1 2;2 3;3 1;1 4;2 4;3 4];
nonorien_face=[1 2 3;1 2 4;2 3 4;3 1 4];
nonorien_f2edges=[1 2 3;1 5 4;2 6 5;3 4 6];

num_tets=ntets-pre_ntets;
xs =[xs;zeros(int32(2.5*num_tets),3)];
bdry_node=zeros(num_tets,12);
% for parent
strt_id =size(parent_id,1);
parent_id =[parent_id; zeros(int32(2.5*num_tets),1)];
parent_coeff =[parent_coeff; zeros(int32(2.5*num_tets),4)];

for i=1:num_tets
    tet_id=i+pre_ntets;
    tet_conn =tets(tet_id,:);
    for j=1:6
        if bdry_node(i,2*j-1)~=0
            continue
        end
        v1 =tet_conn(edge2nodes(j,1));
        v2 =tet_conn(edge2nodes(j,2));
        step =(xs(v2,:)-xs(v1,:))/3;
        nverts =nverts+1;
        xs(nverts,:) =xs(v1,:)+step;
        % for parent
        strt_id =strt_id+1;
        parent_id(strt_id) =tet_id;
        parent_coeff(strt_id,edge2nodes(j,:)) =[2/3 1/3];
        
        nverts =nverts+1;
        xs(nverts,:) =xs(nverts-1,:)+step;
        % for parent
        strt_id =strt_id+1;
        parent_id(strt_id) =tet_id;
        parent_coeff(strt_id,edge2nodes(j,:)) =[1/3 2/3];
        
        [num_ngbts, tets_1ring, leids_1ring] =obtain_tet_edges_around_edge(i,j, tets(pre_ntets+1:ntets,:), sibhfs);
        
        for k=1:num_ngbts
            temp_tet=pre_ntets+tets_1ring(k);
            temp_conn =tets(temp_tet,:);
            temp_v1 =temp_conn(edge2nodes(leids_1ring(k),1));
            if temp_v1==v1
                bdry_node(tets_1ring(k),2*(leids_1ring(k)-1)+1:2*leids_1ring(k))=[nverts-1 nverts];
            else
                bdry_node(tets_1ring(k),2*(leids_1ring(k)-1)+1:2*leids_1ring(k))=[nverts nverts-1];
            end
        end
    end
end
xs =xs(1:nverts,:); parent_id=parent_id(1:strt_id); parent_coeff=parent_coeff(1:strt_id,:);
steiner_tets =zeros(num_tets,4);
xs =[xs;zeros(num_tets,3)];
parent_id =[parent_id;zeros(num_tets,1)];
parent_coeff =[parent_coeff;zeros(num_tets,4)];
tets =[tets; zeros(27*num_tets, 4)];
for i=1:num_tets
    tet_id=i+pre_ntets;
    tet_conn =tets(tet_id,:);
    temp_bdry=zeros(6,4);
    for j=1:6
        temp_bdry(j,1) =tet_conn(edge2nodes(j,1));
        temp_bdry(j,2:3) =bdry_node(i,2*j-1:2*j);
        temp_bdry(j,4) =tet_conn(edge2nodes(j,2));
    end
    temp_face_hi_level=zeros(4,6);
    for j=1:4
        edge3=nonorien_f2edges(j,3);
        edge2=nonorien_f2edges(j,2);
        if tet_conn(edge2nodes(edge3,1))==tet_conn(nonorien_face(j,1))
            temp_face_hi_level(j,[1 4])=bdry_node(i,[2*edge3-1 2*edge3]);
        else
            temp_face_hi_level(j,[1 4])=bdry_node(i,[2*edge3 2*edge3-1]);
        end
        if tet_conn(edge2nodes(edge2,1))==tet_conn(nonorien_face(j,2))
            temp_face_hi_level(j,[3 5])=bdry_node(i,[2*edge2-1 2*edge2]);
        else
            temp_face_hi_level(j,[3 5])=bdry_node(i,[2*edge2 2*edge2-1]);
        end
        temp_face_hi_level(j,6)=tet_conn(nonorien_face(j,3));
        if steiner_tets(i,j)==0
            v1 =temp_face_hi_level(j,1); v2 =temp_face_hi_level(j,3);
            step =(xs(v2,:)-xs(v1,:))/2;
            nverts =nverts+1;
            xs(nverts,:) =xs(v1,:)+step;
            temp_face_hi_level(j,2)=nverts;
            %for parent
            strt_id =strt_id+1;
            if strt_id>size(parent_id,1)
                parent_id =[parent_id;zeros(20,1)];
                parent_coeff =[parent_coeff; zeros(20,4)];
            end
            parent_id(strt_id) =tet_id;
            tet1 =parent_id(v1-nv_orig);
            tet2 =parent_id(v2-nv_orig);
            for k=1:4
                if parent_coeff(v1-nv_orig,k)~=0
                    v_temp=tets(tet1,k);
                    if v_temp==tet_conn(nonorien_face(j,1))
                        parent_coeff(strt_id,nonorien_face(j,1))=parent_coeff(strt_id,nonorien_face(j,1))+0.5*parent_coeff(v1-nv_orig,k);
                    else
                        parent_coeff(strt_id,nonorien_face(j,3))=parent_coeff(strt_id,nonorien_face(j,3))+0.5*parent_coeff(v1-nv_orig,k);
                    end
                end
                if parent_coeff(v2-nv_orig,k)~=0
                    v_temp=tets(tet2,k);
                    if v_temp==tet_conn(nonorien_face(j,2))
                        parent_coeff(strt_id,nonorien_face(j,2))=parent_coeff(strt_id,nonorien_face(j,2))+0.5*parent_coeff(v2-nv_orig,k);
                    else
                        parent_coeff(strt_id,nonorien_face(j,3))=parent_coeff(strt_id,nonorien_face(j,3))+0.5*parent_coeff(v2-nv_orig,k);
                    end
                end
            end
            hfid =sibhfs(i,j);
            cid =hfid2cid(hfid);
            lfid =hfid2lfid(hfid);
            if 0~=cid
                steiner_tets(cid,lfid) =nverts;
            end
        else
            temp_face_hi_level(j,2)=steiner_tets(i,j);
        end
    end
    [xs, nverts, tets, ntets]=uref_tet_by_bdry(xs, nverts, tets, ntets, temp_bdry, temp_face_hi_level, deg);
end
xs =xs(1:nverts,:);parent_id=parent_id(1:strt_id);parent_coeff=parent_coeff(1:strt_id,:);
%test case
figure
tetramesh(tets(pre_ntets+1:ntets,:),xs);
tol=1e-10;
for i=nv_orig+1:nverts
    xs_linear =parent_coeff(i-nv_orig,:)*xs(tets(parent_id(i-nv_orig),:),:);
    assert(norm(xs(i,:)-xs_linear)<tol);
end
    
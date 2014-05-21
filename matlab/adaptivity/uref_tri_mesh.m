function [xs, nverts, tris, ntris, parent_id, parent_coeff]=uref_tri_mesh(xs, nverts, nv_orig, tris, pre_ntris, ntris, deg, sibhes, parent_id, parent_coeff)

assert(size(tris, 2)==3&&deg>1);
tri_edges=zeros(3*(ntris-pre_ntris), deg+1);
nxt =[2 3 1];
istrt =size(parent_id,1);
xs =[xs; zeros(int32(1.25*(ntris-pre_ntris)),3)];
parent_id =[parent_id;zeros(int32(1.25*(ntris-pre_ntris)),1)];
parent_coeff =[parent_coeff; zeros(int32(1.25*(ntris-pre_ntris)),3)];
for i=1:ntris-pre_ntris
    for j=1:3
        heid=sibhes(i,j);
        fid =heid2fid(heid);
        lid =heid2leid(heid);
        if fid==0
            v1 =tris(i+pre_ntris,j);tri_edges((i-1)*3+j, 1)=v1;
            v2 =tris(i+pre_ntris,nxt(j));tri_edges((i-1)*3+j, end)=v2;
            step =(xs(v2,:)-xs(v1,:))/deg;
            for k=1:deg-1
                nverts =nverts+1;
                xs(nverts,:) =xs(v1,:)+k*step;
                tri_edges((i-1)*3+j, k+1) =nverts;
                istrt =istrt+1;
                parent_id(istrt) =i+pre_ntris;
                parent_coeff(istrt,[j nxt(j) nxt(nxt(j))]) =[1-k/deg k/deg 0];
            end
            continue
        end
        if tri_edges((i-1)*3+j, 2)==0
            v1 =tris(i+pre_ntris,j);tri_edges((i-1)*3+j, 1)=v1;
            v2 =tris(i+pre_ntris,nxt(j));tri_edges((i-1)*3+j, end)=v2;
            step =(xs(v2,:)-xs(v1,:))/deg;
            for k=1:deg-1
                nverts =nverts+1;
                xs(nverts,:) =xs(v1,:)+k*step;
                tri_edges((i-1)*3+j, k+1) =nverts;
                istrt =istrt+1;
                parent_id(istrt) =i+pre_ntris;
                parent_coeff(istrt,[j nxt(j) nxt(nxt(j))]) =[1-k/deg k/deg 0];
            end
            tri_edges((fid-1)*3+lid, :) =tri_edges((i-1)*3+j, end:-1:1);
        end
    end
end
parent_id =parent_id(1:istrt); parent_coeff =parent_coeff(1:istrt,:);
xs =xs(1:nverts,:);
xs =[xs;zeros((ntris-pre_ntris)*(deg-2)*(deg-1)/2, 3)];
parent_id =[parent_id;zeros((ntris-pre_ntris)*(deg-2)*(deg-1)/2, 1)];
parent_coeff =[parent_coeff; zeros((ntris-pre_ntris)*(deg-2)*(deg-1)/2, 3)];
for i=1:ntris-pre_ntris
    [xs, nverts, tris, ntris, parent_id, parent_coeff, ~]=uref_base_bdry(xs, nverts, nv_orig, tris, ntris, pre_ntris+i, tri_edges(3*(i-1)+1:3*(i-1)+3,:), deg, parent_id, parent_coeff);
end
            
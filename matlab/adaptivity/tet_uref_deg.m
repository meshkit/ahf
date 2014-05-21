function tet_uref_deg(deg)
if nargin==0
    deg=2;
end

xs=[1 0 0;...
    0 1 0;...
    0 0 0;...
    0 0 1];
nverts=4;
tets =[1 2 3 4];
ntets=1;
figure
tetramesh(tets,xs);
edge2nodes=[1 2;2 3;3 1;1 4;2 4;3 4];
bdry_hi=zeros(6, deg+1);
%refinde edges
xs=[xs;zeros(6*(deg-1),3)];
for i=1:6
    v1=edge2nodes(i,1);bdry_hi(i,1)=v1;
    v2=edge2nodes(i,2);bdry_hi(i,end)=v2;
    step=(xs(v2,:)-xs(v1,:))/deg;
    for j=1:deg-1
        nverts=nverts+1;
        xs(nverts,:)=xs(v1,:)+j*step;
        bdry_hi(i,j+1)=nverts;
    end
end

faces=[1 2 3; 1 2 4; 2 3 4;3 1 4];
faces2edge=[1 2 3;...
            1 5 4;...
            2 6 5;...
            3 4 6];
face_nodes_level=zeros(4,deg*(deg+1)/2);        
for i=1:4
    temp_bdry=zeros(3,deg+1);
    for j=1:3
        vstrt=faces(i,j);
        vedge=faces2edge(i,j);
        if vstrt==edge2nodes(vedge,1)
            temp_bdry(j,1:end)=bdry_hi(vedge,1:end);
        else
            temp_bdry(j,1:end)=bdry_hi(vedge,end:-1:1);
        end
    end
    tris=faces(i,:);ntris=1;
    [xs, nverts, tris, ntris, face_nodes_level(i,1:end)]=uref_base_bdry_old(xs, nverts, tris, ntris, temp_bdry, deg);
    %figure
    %trimesh(tris(2:end,:),xs(unique(tris(2:end,:)),1),xs(unique(tris(2:end,:)),2),xs(unique(tris(2:end,:)),3));
end

[xs, nverts, tets, ntets]=uref_tet_by_bdry(xs, nverts, tets, ntets, bdry_hi, face_nodes_level, deg);
figure
tetramesh(tets(2:end,:),xs)
title(['deg ', num2str(deg), ' refinment ', num2str(ntets-1), ' subtets']);
[sibhfs, v2hf,manifold,oriented] = construct_halffaces(size(xs,1), tets(2:end,:));
if oriented 
    disp GREAT:ORIENTED
end

        
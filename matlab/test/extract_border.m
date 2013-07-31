function extract_border(meshfile)
mesh = test_cstmesh( meshfile );

verts = border_vertices(mesh);
edges = border_edges(mesh);
faces = border_faces(mesh);
C = ones(size(mesh.cells,1),1);

%tetramesh(mesh.cells,mesh.xs,C);
figure
triamesh(mesh.faces,mesh.xs)
hold on
%alpha(0.1);
surfmesh_1(faces,mesh.xs)
alpha(0.1);
for i=1:size(mesh.edges,1)
    v = [mesh.xs(mesh.edges(i,1),:);mesh.xs(mesh.edges(i,2),:)];
    plot3(v(:,1),v(:,2),v(:,3),'Color','r','LineWidth',1.5);
end
for i=1:size(edges,1)
    v = [mesh.xs(edges(i,1),:);mesh.xs(edges(i,2),:)];
    plot3(v(:,1),v(:,2),v(:,3),'Color','b','LineWidth',1.5);
end
for i=1:size(verts,1)
    scatter3(mesh.xs(verts(i),1),mesh.xs(verts(i),2),mesh.xs(verts(i),3),'filled','g');
end


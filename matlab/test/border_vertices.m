function [verts] = border_vertices(mesh)
verts=[];
for i = 1 : size(mesh.edges)
    for j = 1 : 2
        if (hvid2eid(mesh.sibhvs(i,j))==0)                    
            verts=[verts; mesh.edges(i,j)];         
        end
    end
end
end


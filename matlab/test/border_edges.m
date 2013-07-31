function [edges, zones]=border_edges(mesh,var_cells)
shift=size(mesh.edges);
next=[2,3,1];
edges=[];
zones.SCALARS=[];
for i = 1 : size(mesh.faces)
    for j = 1 : 3
        if (heid2fid(mesh.sibhes(i,j))==0)
        %if (heid2leid(mesh.sibhes(i,j))==0)
            edge=[mesh.faces(i,j) mesh.faces(i,next(j))];
            edges=[edges; edge];
            % zones.SCALARS=[zones.SCALARS; var_cells.SCALARS(shift+i)];
        end
    end
end

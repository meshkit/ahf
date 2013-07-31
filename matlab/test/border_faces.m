function [faces, zones]=border_faces(mesh,var_cells)
hf_tet = int32([1,2,3; 1 4 2; 2 4 3; 3 4 1]);
shift=size(mesh.edges)+size(mesh.faces);
faces=[];
zones.SCALARS=[];
for i = 1 : size(mesh.cells)
    for j = 1 : 4
        if (hfid2cid(mesh.sibhfs(i,j))==0)
        %if (hfid2lfid(mesh.sibhfs(i,j))==0)
            face=[mesh.cells(i,hf_tet(j,1)) mesh.cells(i,hf_tet(j,2)) mesh.cells(i,hf_tet(j,3))];
            faces=[faces; face];
         %   zones.SCALARS=[zones.SCALARS; var_cells.SCALARS(shift+i)];
        end
    end
end


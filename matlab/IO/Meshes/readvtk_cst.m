function [xs,cells,var_nodes,var_elems]=readvtk_cst(fname)

[xs,elems,types,var_nodes,var_elems]=readvtk_cst_core(fname);
p=0;
types_num2str={'vertices','poly_vertices','edges','poly_lines','tris','strips','polygons','pixels','quads','tets','voxels','hexes','prisms','pyrs'};
types_num2ncoords=[2,0,3,0,4,0,0,5,5,5,9,9,7,6];
cells=struct;

for i = 1: length(types)
    type_id=types(i);
    if ((type_id)>0 && (type_id)<=length(types_num2str))
        if isfield(cells,types_num2str{type_id})
            cells.(types_num2str{type_id})=[cells.(types_num2str{type_id}); elems(p+2:p+types_num2ncoords(type_id))'+1];
        else
            cells.(types_num2str{type_id})=elems(p+2:p+types_num2ncoords(type_id))'+1;
        end    
        p=p+types_num2ncoords(type_id);
    else
       warning('MATLAB:readvtk_cst','unknown element type %g',type_id);
    end
end

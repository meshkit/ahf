function [xs,cells,var_nodes,var_elems]=readvtk_cst(fname)

[xs,elems,types,var_nodes,var_elems]=readvtk_cst_core(fname);
types_num2str={'vertices','poly_vertices','edges','poly_lines','tris',...
    'strips','polygons','pixels','quads','tets','voxels','hexes','prisms','pyrs'};
types_num2ncoords=[2,0,3,0,4,0,0,5,5,5,9,9,7,6];

cells=struct;
sizes=struct;

p=0;
for i = 1: length(types)
    type_id=types(i);
    if ((type_id)>0 && (type_id)<=length(types_num2str))
        typename = types_num2str{type_id};
        
        if isfield(cells,typename)
            sizes.(typename)=sizes.(typename)+1;
        else
            sizes.(typename)=1;
            cells.(typename)=zeros(length(types),types_num2ncoords(type_id)-1,'int32');
        end
        
        cells.(typename)(sizes.(typename),:)=elems(p+2:p+types_num2ncoords(type_id))'+1;        
        p = p+types_num2ncoords(type_id);
    else
        warning('MATLAB:readvtk_cst','unknown element type %g',type_id);
    end
end

fields = fieldnames( cells);

for i=1:length(fields)
    cells.(fields{i})(sizes.(fields{i})+1:end,:)=[];
end

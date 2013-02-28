function combine_vtk_cgns(cfd_file,icontab_file,compartment_file)
[ps, tets, ~,~,var_cells]=readvtk_unstr2(cfd_file);
[~, ~, typestr,var_nodes,~,icontab]=readcgns_Lagrit(icontab_file);
[~, ~, ~,~,var_cells2]=readcgns_unstr...
          (compartment_file);
%names=fieldnames(var_cells); 
%numfields=size(names,1);
compartment=var_cells2.compartment;
var_cells=setfield(var_cells,'compartment',compartment); %#ok<SFLD>
prefix = regexprep( cfd_file, '.\w+$', '');

writecgns_unstrBC([prefix '_combined.cgns'], ps, tets, typestr, ...
  var_nodes, var_cells, [], [], [],icontab );


%END FUNCTION
end

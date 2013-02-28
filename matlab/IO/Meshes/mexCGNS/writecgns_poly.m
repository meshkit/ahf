function writecgns_poly(file_name, ps, polyfaces, polyhedra)

if ~exist('cgnslib_mex', 'file')
    warning('CGNS does not appear to be compiled  properly. Try to run build_mexcgns.'); %#ok<WNTAG>
    build_mexcgns;
end

if (nargin<4)
    error('Requires at least three input arguments: filename, coordinates, elements.');
end
% Set file type to HDF5.
if strcmp(file_name(end-2:end),'.h5') || strcmp(file_name(end-4:end),'.hdf5') 
    ierr = cg_set_file_type(CG_FILE_HDF5); chk_error(ierr);
else
    ierr = cg_set_file_type(CG_FILE_ADF2); chk_error(ierr);
end

% Open the CGNS file.
[index_file,ierr] = cg_open(file_name,CG_MODE_WRITE); chk_error(ierr);

% Create base.
iphysdim = size(ps,2);
icelldim=3;
[index_base,ierr] = cg_base_write(index_file,'Base',icelldim,iphysdim); 
chk_error(ierr);
% Number of vertices and elements
isize = [size(ps,1), nelems, zeros(1,7)];
% Create zone
[index_zone,ierr] = cg_zone_write(index_file,index_base,'Zone1',isize,...
    Unstructured); chk_error(ierr);
% Write grid coordinates (must use SIDS-standard names here)
[index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
    RealDouble,'CoordinateX',ps(:,1)); chk_error(ierr); %#ok<*ASGLU>
[index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
    RealDouble,'CoordinateY',ps(:,2)); chk_error(ierr);
[index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
    RealDouble,'CoordinateZ',ps(:,3)); chk_error(ierr);
% Write element connectivity. We must permute elems, but we don't need to
% cast the data type to integer explicitly (MEX function does it for us).
%
% UNWRAP THE POLY DATA TO GET THE NUMBER
[num_per_poly,numpfaces] = get_nodes_or_faces_per_poly(polyfaces);
[index_sec1, ierr] = cg_section_write(index_file,index_base,index_zone,...
    'NGON_n', NGON_n, 1, numpfaces, 0, polyfaces); chk_error(ierr);
%
[num_per_poly,numpolys] = get_nodes_or_faces_per_poly(polyfaces);
[index_sec1, ierr] = cg_section_write(index_file,index_base,index_zone,...
    'NFACE_n', NFACE_n, 1, numpolys, 0, polyhedra); chk_error(ierr);


% Close the CGNS file.
ierr = cg_close(index_file); chk_error(ierr);

%END FUNCTION
end


function [num_per_poly,numpolys] = get_nodes_or_faces_per_poly(polys)
% Convert from the number of vertices per element into
% element_type in the connecitvity table.
es = size(polys,1);
ii=1;
numpolys = 0;

while (ii<es)
    nvpp = polys(ii);
    num_per_poly=nvpp;
    ii = ii + nvpp + 1;
    numpolys = numpolys + 1;
end

end



function chk_error( ierr)
% Check whether CGNS returned an error code. If so, get error message
if ierr
    error( ['Error: ', cg_get_error()]);
end
end
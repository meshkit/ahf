function writecgns_unstr_Lagrit( file_name, ps, elems, typestr, var_nodes, var_cells, icontab)
% Write out an unstructured mesh with node/cell-centered values in CGNS format.
%
% WRITECGNS_UNSTR( FILENAME, XS, ELEMS, TYPESTR, VAR_NODES, VAR_CELLS)
%
% Arguments:
%   FILENAME is a character string, specifying the output file. If the
%       file name extension is h5 or hdf5, then HDF5 format will be used.
%
%   XS is nxd array containing nodal coordinates, where d is the dimension
%       of the space (in general d is 2 or 3).
%
%   ELEMS is mxd. For a regular unstructured mesh, m is the number
%       of elements, and d is the number of vertices per element. For
%       a mesh with mixed types of elements, where each element is
%       given by first listing the number of vertices per element and then
%       the vertex IDs within the element, so d is 1 and m is the element
%       data size. For example, a mesh with a triangle, a quadrilateral,
%       and five vertices is given by ELEMS=[3 1 2 3, 4 2 3 4 5]'.
%
%   TYPESTR is a character string specifying the element type, and it
%       is used to resolve ambiguities when different element types
%       have the same number of vertices per element. For a regular mesh,
%       only the first character is used in resolving ambiguities (e.g.,
%       't...' for triangle and 'q...' for quadrilateral). For mixed
%       meshes, TYPESTR must use 'MIXED2' or 'MIXED3' (case insensitive)
%       for surface and volume meshes, respectively.
%
%   VAR_NODES is a MATLAB structure, of which each field corresponds to a
%       nodal value to be written. The structure can contain an arbitrary
%       number of fields. The field names of the MATLAB structure are
%       mapped to the field names in the CGNS file. If there is no nodal
%       variable to be written, then leave out the argument or use [].
%
%   VAR_CELLS is a MATLAB structure containing elemental values to be
%       written. Its usage is similar to VAR_NODES.
%
% Example usage
%     var_nodes.vdisp = disp;   % Define two nodal variables
%     var_nodes.vnrms = vnrms;
%     var_cells.fnrms = fnrms;  % Define one elemental variables
%     % Write out nodal and elemental variables
%     writecgns_unstr_Lagrit( 'test.cgns', xs, elems, '', var_nodes, var_cells);
%     % Write out nodal and elemental variables
%     writecgns_unstr_Lagrit( 'test.cgns', xs, elems, '', var_nodes);
%     % Write out only elemental variables
%     writecgns_unstr_Lagrit( 'test.cgns', xs, elems, '', [], var_cells);
%
% Note that a field in VAR_NODES (and similarly in VAR_CELLS) is
% an nxd matrix with d>=1. If d>1, each column of the field will
% be written as an individual variable in the CGNS file with a
% variable name "<fieldname>-<column>" (e.g., "disp-1").
%
% See also readcgns_unstr.
%

% Note: This function will be generalized to support structured meshes in
%   the future. At that time, it will be renamed to writecgns and its arguments
%   will change to include a mesh structure.
% Authors:
%        Xiangmin Jiao (jiao@ams.sunysb.edu)
%        Ying Chen (yingchen@ams.sunysb.edu)

if ~exist('cgnslib_mex', 'file')
    warning('CGNS does not appear to be compiled  properly. Try to run build_mexcgns.'); %#ok<WNTAG>
    build_mexcgns;
end

if (nargin<3)
    error('Requires at least three input arguments: filename, coordinates, elements.');
elseif (nargin>7)
    error('Too many input arguments.');
end

if nargin<4; typestr = []; end
if nargin<5; var_nodes = []; end
if nargin<6; var_cells = []; end
if nargin<7; icontab = []; end

nelems = int32(size(elems,1));
if ~isa( elems, 'int32'); elems = int32( elems); end

% elems is nxd, where d is 3 for triangle etc.
if isempty(elems)
    type = NODE;
    icelldim = 1;
else
    % get elems_type from elems
    [type, icelldim] = get_elemtype( int32(size(elems,2)), typestr, int32(size(ps,1)), elems);
    if type == MIXED
        [elems,nelems] = convert_mixed_elements( elems, int32(icelldim));
    end
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
iphysdim = int32(size(ps,2));
[index_base,ierr] = cg_base_write(index_file,'Base',icelldim,iphysdim); chk_error(ierr);

% Number of vertices and elements
isize = [int32(size(ps,1)), nelems, zeros(1,7,'int32')];
% Create zone
[index_zone,ierr] = cg_zone_write(index_file,index_base,'Zone1',isize,...
    Unstructured); chk_error(ierr);

% Write grid coordinates (must use SIDS-standard names here)
[index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
    RealDouble,'CoordinateX',ps(:,1)); chk_error(ierr); %#ok<*ASGLU>
[index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
    RealDouble,'CoordinateY',ps(:,2)); chk_error(ierr);

if iphysdim==3
    [index_coor, ierr] = cg_coord_write(index_file,index_base,index_zone,...
        RealDouble,'CoordinateZ',ps(:,3)); chk_error(ierr);
end

% Write element connectivity. We must permute elems, but we don't need to
% cast the data type to integer explicitly (MEX function does it for us).
[index_sec, ierr] = cg_section_write(index_file,index_base,index_zone,'Elements', ...
    type, 1, nelems, 0, elems'); chk_error(ierr);

% get number of variables
if isempty(var_nodes)
    n_vn = 0;
else
    n_vn = length(fieldnames(var_nodes));
end

if isempty(var_cells)
    n_vf = 0;
else
    n_vf = length(fieldnames(var_cells));
end

% Write node-centered variables
if (n_vn ~= 0)
    solname = 'NodeCenteredSolutions';
    [index_sol,ierr] = cg_sol_write(index_file, index_base, index_zone, ...
        solname, Vertex); chk_error(ierr);
    
    write_variables( index_file, index_base, index_zone, index_sol, var_nodes);
end

% Write cell-centered variables
if(n_vf ~= 0)
    solname = 'CellCenteredSolutions';
    [index_sol,ierr] = cg_sol_write(index_file, index_base, index_zone, ...
        solname, CellCenter); chk_error(ierr);
    
    write_variables( index_file, index_base, index_zone, index_sol, var_cells);
end
% Write out icontab if it exists
if(~isempty(icontab))
    if(isfield(var_nodes,'icr1')||isfield(var_nodes,'cgicr1'))
        if(isfield(var_nodes,'icr1'))
            maxicr=max(var_nodes.icr1);
        else
            maxicr=max(var_nodes.cgicr1);
        end
        DimensionVector(1)=int32(50);
        DimensionVector(2)=int32(maxicr);
        ierr=cg_goto(index_file,index_base, 'Zone_t', index_zone);
        if (ierr ~= 0)
            cg_error_print()
        end
        ierr = cg_user_data_write('Lagrit_icontab');
        if (ierr ~= 0)
            cg_error_print()
        end
        ierr=cg_goto(index_file,index_base, 'Zone_t', index_zone, ...
            'UserDefinedData_t',1);
        if (ierr ~= 0)
            cg_error_print()
        end
        ierr=cg_array_write('Lagrit_icontab', Integer, 2, ...
            DimensionVector, icontab);
        if (ierr ~= 0)
            cg_error_print()
        end
    else
        fprintf(1,'Not writing icontab since icr1 is empty\n');
    end
end

% Close the CGNS file.
ierr = cg_close(index_file); chk_error(ierr);
end

function type = get_cgns_datatype( arr)
% Obtain the corresponding CGNS data type for a given array
if isinteger(arr)
    type = Integer;
elseif ischar(arr)
    type = Character;
elseif isa(arr, 'single')
    type = RealSingle;
else
    type = RealDouble;
end
end

function write_variables( index_file, index_base, index_zone, index_sol, struct)
% Subfunction for writing out variable names.
fldlist2 = fieldnames(struct);
fldlist = regexprep(fldlist2,'_dOt_','.');
fldlist = regexprep(fldlist,'_dSh_','-');
fldlist = regexprep(fldlist,'_bLk_',' ');

for ii=1:length(fldlist)
    if ~strcmp( fldlist{ii}, fldlist2{ii})
        fprintf(2, 'Info: field variable %s is renamed to %s.\n', fldlist2{ii}, fldlist{ii});
    end
    
    ncol = int32(size(struct.(fldlist2{ii}),2));
    arr = struct.(fldlist2{ii});
    type = get_cgns_datatype(arr);
    
    if ncol==1
        varname = fldlist{ii};
        [index_field,ierr] = cg_field_write(index_file, index_base, ...
            index_zone, index_sol, type, varname, arr); chk_error(ierr);
    elseif ncol<=3 || ncol==6
        % For naming convention, see http://www.grc.nasa.gov/WWW/cgns/sids/dataname.html
        if ncol<=3  % Vector
            suffix = ['X';'Y';'Z'];
        else        % Tensor
            suffix = ['XX';'XY';'XZ';'YY';'YZ';'ZZ'];
        end
        
        for jj=1:ncol
            [index_field,ierr] = cg_field_write(index_file, index_base, index_zone, ...
                index_sol, type, [fldlist{ii},suffix(jj,:)], arr(:,jj)); chk_error(ierr);
        end
    else
        for jj=1:ncol
            % Store variable as var-<jj>
            varname = sprintf('%s_%d', fldlist{ii}, jj);
            
            [index_field,ierr] = cg_field_write(index_file, index_base, ...
                index_zone, index_sol, type, varname, arr(:,jj)); chk_error(ierr);
        end
    end
end
end

function [type, icelldim] = get_elemtype( npe, typestr, nv, elems)
% Obtain the element-type ID and dimension of elements
switch (npe)
    case 1
        type = MIXED;
        
        if strcmpi(typestr,'MIXED2')
            icelldim = 2;
        elseif strcmpi(typestr,'MIXED3')
            icelldim = 3;
        else
            try
                convert_mixed_elements( elems, int32(3));
                icelldim = 3;
            catch %#ok<CTCH>
                icelldim = 2;
            end
        end
    case 2
        type = BAR_2;
        icelldim = 1;
    case 3
        if ~isempty(typestr) && upper(typestr(1))=='B' || ...
                ~is_2dmesh_mex( nv, elems)
            type = BAR_3;
            icelldim = 1;
        else
            type = TRI_3;
            icelldim = 2;
        end
    case 4
        if ~isempty(typestr) && upper(typestr(1))=='Q' || ...
                is_2dmesh_mex( nv, elems)
            type = QUAD_4;
            icelldim = 2;
        else
            type = TETRA_4;
            icelldim = 3;
        end
    case 5
        type = PYRA_5;
        icelldim = 3;
    case 6
        if ( ~isempty(typestr) && upper(typestr(1))=='P') || ...
                ~is_2dmesh_mex( nv, elems)
            type = PENTA_6;
            icelldim = 3;
        else
            type = TRI_6;
            icelldim = 2;
        end
    case 8
        if ~isempty(typestr) && upper(typestr(1))=='Q' || ...
                is_2dmesh_mex( nv, elems)
            type = QUAD_8;
            icelldim = 2;
        else
            type = HEXA_8;
            icelldim = 3;
        end
    case 9
        type = QUAD_9;
        icelldim = 2;
    case 10
        type = TETRA_10;
        icelldim = 3;
    case 13
        type = PYRA_13;
        icelldim = 3;
    case 14
        type = PYRA_14;
        icelldim = 3;
    case 15
        type = PENTA_15;
        icelldim = 3;
    case 18
        type = PENTA_18;
        icelldim = 3;
    case 20
        type = HEXA_20;
        icelldim = 3;
    case 27
        type = HEXA_27;
        icelldim = 3;
    otherwise
        error('ERROR: unknown element type with %d nodes.', npe);
end
end

function chk_error( ierr)
% Check whether CGNS returned an error code. If so, get error message
if ierr
    error( ['Error: ', cg_get_error()]);
end
end

%% Integrated test block. Run these tests by issuing command
% "test_mcode writecgns_unstr_Lagrit" in Octave or MATLAB.

%% Test to write a triangular mesh
%!shared xs, tris, elems
%! xs = [0 0 0; 1 0 0; 1 1 0; 0 1 0];
%! tris = int32([1 2 3; 3 4 1]);
%! elems = int32([3 1 2 3, 3 3 4 1]');
%!test
%! writecgns_unstr_Lagrit( 'test1_tri.cgns', xs, tris);
%! writecgns_unstr_Lagrit( 'test1_tri.cgns', xs, tris, []);
%! delete test1_tri.cgns;

%!test
%! writecgns_unstr_Lagrit( 'test1_tri.h5', xs, tris);
%! writecgns_unstr_Lagrit( 'test1_tri.h5', xs, tris, []);
%! delete test1_tri.h5;

%% Test to write a mixed mesh
%!test
%! writecgns_unstr_Lagrit( 'test1_mixed.cgns', xs, elems, 'MIXED2');
%! writecgns_unstr_Lagrit( 'test1_mixed.cgns', xs, elems, 'MIXED2', []);
%! delete test1_mixed.cgns;

%!test
%! writecgns_unstr_Lagrit( 'test1_mixed.h5', xs, elems, 'MIXED2');
%! writecgns_unstr_Lagrit( 'test1_mixed.h5', xs, elems, 'MIXED2', []);
%! delete test1_mixed.h5;

%% Test to write nodal variables
%!test
%! nodal_vars.vec = xs;
%! nodal_vars.sca = xs(:,1);
%! writecgns_unstr_Lagrit( 'test1_tri.cgns', xs, tris, [], nodal_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.cgns', xs, elems, 'MIXED2', nodal_vars);
%! delete test1_tri.cgns;
%! delete test1_mixed.cgns;

%!test
%! nodal_vars.vec = xs;
%! nodal_vars.sca = xs(:,1);
%! writecgns_unstr_Lagrit( 'test1_tri.h5', xs, tris, [], nodal_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.h5', xs, elems, 'MIXED2', nodal_vars);
%! delete test1_tri.h5;
%! delete test1_mixed.h5;

%% Test to write elemental variables
%!test
%! eleml_vars.vec = tris;
%! eleml_vars.sca = int32(tris(:,1));
%! writecgns_unstr_Lagrit( 'test1_tri.cgns', xs, tris, [], [], eleml_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.cgns', xs, elems, 'MIXED2', [], eleml_vars);
%! delete test1_tri.cgns;
%! delete test1_mixed.cgns;

%!test
%! eleml_vars.vec = tris;
%! eleml_vars.sca = int32(tris(:,1));
%! writecgns_unstr_Lagrit( 'test1_tri.h5', xs, tris, [], [], eleml_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.h5', xs, elems, 'MIXED2', [], eleml_vars);
%! delete test1_tri.h5;
%! delete test1_mixed.h5;

%% Test to write both nodal and elemental variables
%!test
%! nodal_vars.vec = xs;
%! nodal_vars.sca = xs(:,1);
%! eleml_vars.vec = tris;
%! eleml_vars.sca = int32(tris(:,1));
%! writecgns_unstr_Lagrit( 'test1_tri.cgns', xs, tris, [], nodal_vars, eleml_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.cgns', xs, elems, 'MIXED2', nodal_vars, eleml_vars);
%! delete test1_tri.cgns;
%! delete test1_mixed.cgns;

%!test
%! nodal_vars.vec = xs;
%! nodal_vars.sca = xs(:,1);
%! eleml_vars.vec = tris;
%! eleml_vars.sca = int32(tris(:,1));
%! writecgns_unstr_Lagrit( 'test1_tri.h5', xs, tris, [], nodal_vars, eleml_vars);
%! writecgns_unstr_Lagrit( 'test1_mixed.h5', xs, elems, 'MIXED2', nodal_vars, eleml_vars);
%! delete test1_tri.h5;
%! delete test1_mixed.h5;

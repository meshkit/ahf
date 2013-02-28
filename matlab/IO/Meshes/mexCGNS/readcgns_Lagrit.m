function [ps, elems, typestr, var_nodes, var_cells,Lagrit_icontab] = ...
    readcgns_Lagrit(filename, node_var_list, elem_var_list)
%readcgns_Lagrit Read an unstructured grid CGNS file.
% readcgns_Lagrit(FILENAME, NODE_VAR_LIST, ELEM_VAR_LIST) Reads a file in
% CGNS format via CGNS mid-library. Inputs and Outputs, as well as examples
% provided below.
%
% Input arguments:
%   FILENAME is a character string, specifying the input file.
%
%   NODE_VAR_LIST, if present, is either a character string specifying some
%        regular express for nodal variables to be read, or a cell structure
%        containing the list of the names of nodal variables to be read.
%        If not present or is empty, then all nodal variables are read.
%   ELEM_VAR_LIST is analogous to NODE_VAR_LIST but is for elemental values.
%
% Output arguments:
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
%   TYPESTR is a character string specifying the element type.
%
%   VAR_NODES is a MATLAB structure, of which each field corresponds to a
%       nodal value to be read. The field names in the CGNS file are
%       mapped to the field names of this MATLAB structure. If there is no nodal
%       variable in the CGNS file, then this argument is [].
%
%   VAR_CELLS is a MATLAB structure containing elemental values to be
%       read. Its usage is similar to VAR_NODES.
%
% Example usage
%     % Read only node-centered variables
%     [xs, elems, etype, var_nodes] = readcgns_unstr( 'test.cgns');
%
%     % Read only cell-centered variables
%     [xs, elems, etype, tmp, var_cells] = readcgns_Lagrit( 'test.cgns', '-');
%
%     % Read node-centered and cell-centered variables
%     [xs, elems, etype, var_nodes, var_cells] = readcgns_unstr( 'test.cgns');
%
% See also WRITECGNS_UNSTR

% Note: This function will be generalized to support structured meshes in
%   the future. At that time, it will be renamed to readcgns and its arguments
%   will change to include a mesh structure.
% Authors:
%        Ying Chen (yingchen@ams.sunysb.edu)
%        Xiangmin Jiao (jiao@ams.sunysb.edu)

if ~exist('cgnslib_mex', 'file')
    warning('CGNS does not appear to be compiled  properly. Try to run build_mexcgns.'); %#ok<WNTAG>
    build_mexcgns;
end

% confirm input arguments
if(nargin <1)
    error('Input filename is necessary');
elseif (nargin<2)
    node_var_list = [];
    elem_var_list = [];
elseif (nargin<3)
    elem_var_list = [];
end

% Open the CGNS file
[index_file,ierr] = cg_open(filename, CG_MODE_READ); chk_error(ierr);

% Get dimension of element(icelldim) and vertex(iphysdim)
index_base=1;  %assume there is only one base
basename = char(zeros(1,32));
[basename,icelldim,iphysdim,ierr] = cg_base_read(index_file,index_base,...
    basename); chk_error(ierr); %#ok<*ASGLU>
assert(~isempty(deblank(basename)));
% Get zone size (and name - although not needed here) */
index_zone=1;  % assume there is only one zone
sz = zeros(1,9,'int32');
zonename = char(zeros(1,32));
[zonename,sz,ierr] = cg_zone_read(index_file,index_base,index_zone, ...
    zonename, sz); chk_error(ierr);
assert(~isempty(deblank(zonename)))

% Define the range of vertices
rmin = 1;      % lower range index of vertices
rmax = sz(1);  % upper range index of vertices

% Read grid coordinates (must use SIDS-standard names here)
ps = zeros(rmax(1),iphysdim);
[ps(:,1),ierr] = cg_coord_read(index_file,index_base,index_zone,...
    'CoordinateX', RealDouble,rmin,rmax, ps(:,1)); chk_error(ierr);
[ps(:,2),ierr] = cg_coord_read(index_file,index_base,index_zone,...
    'CoordinateY', RealDouble,rmin,rmax, ps(:,2)); chk_error(ierr);

if (iphysdim == 3)
    [ps(:,3),ierr ]= cg_coord_read(index_file,index_base,index_zone,...
        'CoordinateZ', RealDouble,rmin,rmax, ps(:,3)); chk_error(ierr);
end

% Get element connectivity and element type
index_sect = 1;    % assume there is only one section
sectionname = char(zeros(1,32));
[sectionname,itype,istart,iend, nbndry, pflag, ierr] = cg_section_read(index_file, ...
    index_base,index_zone,index_sect,sectionname); chk_error(ierr); %#ok<*ASGLU>
assert(~isempty(deblank(sectionname)))

% Define the range of elements
elem_start = istart;  % lower range index of elements
elem_end = iend;     % upper range index of elements

[npe, typestr] = get_elemtype_string( itype, icelldim);

% Get element connectivity
[size_ielem,ierr] = cg_ElementDataSize(index_file,index_base,index_zone, ...
    index_sect); chk_error(ierr);
num_elems = size_ielem / npe;   % number of elements (except for MIXED)
elems = zeros(npe, num_elems,'int32');  % Element connectivity is permuted in CGNS
parent_data = [];
[elems, parent_data,ierr] = cg_elements_read(index_file,index_base,index_zone,...
    index_sect,elems,parent_data); chk_error(ierr);
elems = elems';                 % Permute the connectivity back

element_type = elems(1);
% If element type is MIXED, change leading type to number of nodes for
% every element in the element connectivity
if (itype == MIXED)
    elems = inverse_mixed_elements(elems);
end

nelems = nnz_elements( elems);    % number of elements (MIXED element type)

if (itype ~= MIXED) && (num_elems ~= nelems )
    error('Error: Incorrectly reading element connectivity.');
end

if (itype == MIXED)
    [elems, typestr]=check_mixed(elems,int32(nelems),int32(element_type),int32(icelldim),typestr);
end

% Get variables. First read in the field names, datatypes, etc.
[n_sol,ierr ]= cg_nsols(index_file, index_base, index_zone); % number of solutions
chk_error(ierr);

before_struct = struct('field_name',[],'datatype',[],'location',[],'index_sol',[]);
index_struct = 1;
for index_sol =1:n_sol
    solname = char(zeros(1,32));
    [solname, location,ierr] = cg_sol_info(index_file, index_base,...
        index_zone,index_sol,solname); chk_error(ierr);
    [n_fields,ierr] = cg_nfields(index_file, index_base, ...
        index_zone,index_sol); chk_error(ierr);
    assert(~isempty(deblank(solname)))
    for index_field = 1:n_fields
        field_name = char(zeros(1,32));
        
        [field_name , datatype,ierr] = cg_field_info(index_file, index_base, ...
            index_zone, index_sol, index_field,field_name); chk_error(ierr);
        assert(~isempty(deblank(field_name)))
        
        %field_name including '-' and deblank the trailing blank
        before_struct(index_struct).field_name = deblank(field_name);
        before_struct(index_struct).datatype = datatype;
        before_struct(index_struct).location = location;
        before_struct(index_struct).index_sol = index_sol;
        index_struct = index_struct + 1;
    end
end

% Construct var_nodes and var_cells structures.
var_nodes = [];
var_cells = [];
after_struct = [];

if (n_sol>0)
    [var_nodes, var_cells,after_struct] = convert_field_name(before_struct,...
        node_var_list, elem_var_list,nargin,nargout);
end

% get the number of variables to read
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


% Read node-centered variables
if (n_vn ~= 0)
    var_nodes = read_variables(index_file,index_base,index_zone,...
        after_struct,var_nodes,rmin, rmax,Vertex);
end

% Read cell-centered variables
if(n_vf ~= 0)
    var_cells = read_variables(index_file,index_base,index_zone,...
        after_struct,var_cells,elem_start,elem_end, CellCenter);
end

if nargout>5
    % Determine if there are boundary conditions from Lagrit
    ierr=cg_goto(index_file,index_base, 'Zone_t', index_zone); chk_error(ierr);
    [nuser_data, ierr] = cg_nuser_data(); chk_error(ierr);
    if(nuser_data >0)
        index_user=1;
        [username, ierr]=cg_user_data_read(index_user); chk_error(ierr);
        if(strfind(username,'Lagrit_icontab'))
            ierr=cg_goto(index_file,index_base, 'Zone_t', index_zone,...
                'UserDefinedData_t',index_user);
            if(ierr>0)
                error_message=cg_get_error();
                fprintf(1,[error_message '\n']);
            end
            [narrays ierr] = cg_narrays(); chk_error(ierr);
            [ArrayName, DimensionVector, DataType, DataDimension, ierr] = ...
                cg_array_info(1); chk_error(ierr);
            Lagrit_icontab=zeros(DimensionVector(1),DimensionVector(2),'int32');
            [Lagrit_icontab, ierr] = cg_array_read(1, Lagrit_icontab); chk_error(ierr);
        end
    else
        fprintf(1,'Constraint table data not found.\n');
        Lagrit_icontab=[];
    end
end

%[nbocos ierr] = cg_nbocos(index_file,index_base,index_zone);
%if (nbocos > 0 && ierr ==0)
%    bocos_indices=zeros(nbocos,2,'int32');
%    npts=size(ps,1);
%    boco_pnts=zeros(npts,1);
%    fprintf(1,'Reading %d boundary conditions.\n',nbocos);
%    for i=1:nbocos
%        boconame = char(zeros(1,32));
%        [boconame, NormalIndex, bocotype, ptset_type, npnts, ...
%            NormalListFlag,NormalDataType, boco_pnts, ierr] = ...
%            cg_boco_info(index_file,index_base,index_zone, i,...
%            boconame, []);
%        io_pnts=zeros(npts,1);
%        io_NormalList=zeros(npts,1);
%        [io_pnts, io_NormalList, ierr] = ...
%            cg_boco_read(index_file,index_base,index_zone, i, ...
%            io_pnts, []);
%    end
%end

% Close CGNS file
ierr = cg_close(index_file); chk_error(ierr);
end

function [var_nodes,var_cells,after_struct] = convert_field_name(before_struct, ...
    node_var_list, elem_var_list,nargin_main,nargout_main)
% (1) Merge the variables of before_struct and save them into after_struct,
%     and eliminate '-' in variable names. Ex: merge [t-1, t-2,t-3] into t.s
% (2) Create var_ndoes and var_cells with corresponding variable names
%     but without variable values.

var_nodes = [];
var_cells = [];

after_struct = struct('field_name',[], 'datatype',[], 'location',[],...
    'index_sol',[],'ncol',[]);

ii=1; nvar=0;
while ii <= length(before_struct)
    var = before_struct(ii).field_name; ncol = 1;
    
    if ~isempty(regexp(var, '-[0-9]+', 'match'))
        var = regexprep(var, '-[0-9]+', '');
        nvar = nvar+1;
        after_struct(nvar).field_name = var;
        after_struct(nvar).datatype = before_struct(ii).datatype;
        after_struct(nvar).location = before_struct(ii).location;
        after_struct(nvar).index_sol= before_struct(ii).index_sol;
        
        ii=ii+1;
        pat = [var '-[0-9]+'];
        while ii<=length(before_struct) && ...
                ~isempty(regexp(before_struct(ii).field_name, pat, 'match'))
            ncol = ncol+1; ii=ii+1;
        end
        after_struct(nvar).ncol = ncol;
    elseif ~isempty(regexp(var, 'XX$', 'match'))
        var(end-1:end) = [];
        nvar = nvar+1;
        after_struct(nvar).field_name = var;
        after_struct(nvar).datatype = before_struct(ii).datatype;
        after_struct(nvar).location = before_struct(ii).location;
        after_struct(nvar).index_sol= before_struct(ii).index_sol;
        
        ii=ii+1;
        pat = [var '[XYZ][XYZ]'];
        
        while ii<=length(before_struct) && ...
                ~isempty(regexp(before_struct(ii).field_name, pat, 'match'))
            ncol = ncol+1; ii=ii+1;
        end
        after_struct(nvar).ncol = ncol;
    elseif ~isempty(regexp(var, 'X$', 'match'))
        var(end) = [];
        nvar = nvar+1;
        after_struct(nvar).field_name = var;
        after_struct(nvar).datatype = before_struct(ii).datatype;
        after_struct(nvar).location = before_struct(ii).location;
        after_struct(nvar).index_sol= before_struct(ii).index_sol;
        
        
        ii=ii+1;
        pat = [var '[YZ]'];
        
        while ii<=length(before_struct) && ...
                ~isempty(regexp(before_struct(ii).field_name, pat, 'match'))
            ncol = ncol+1; ii=ii+1;
        end
        after_struct(nvar).ncol = ncol;
    else
        judge = 0;
        for jj=1:length(after_struct)
            if(strcmpi(var, after_struct(jj).field_name) && ...
                    (before_struct(ii).location == after_struct(jj).location))
                judge = judge+1;
            end
        end
        if (judge == 0)
            nvar = nvar+1;
            after_struct(nvar).field_name = var;
            after_struct(nvar).datatype = before_struct(ii).datatype;
            after_struct(nvar).location = before_struct(ii).location;
            after_struct(nvar).index_sol= before_struct(ii).index_sol;
            after_struct(nvar).ncol = 1;
        end
        
        ii = ii+1;
    end
end

% Determine which variables should be read based on user input
for ii=1:length(after_struct)
    if  (after_struct(ii).location == Vertex)
        if (nargout_main>3 && (nargin_main<2 || ...
                match_name(after_struct(ii).field_name, node_var_list)))
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'\.','_dOt_');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'-','_dSh_');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,' ','_bLk_');
            var_nodes.(after_struct(ii).field_name) = [];
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_dOt_','.');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_dSh_','-');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_bLk_',' ');
        end
        
        
    elseif(after_struct(ii).location == CellCenter)
        if (nargout_main>4 && (nargin_main<3 || ...
                match_name(after_struct(ii).field_name, elem_var_list)))
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'\.','_dOt_');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'-','_dSh_');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,' ','_bLk_');
            var_cells.(after_struct(ii).field_name) = [];
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_dOt_','.');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_dSh_','-');
            after_struct(ii).field_name = regexprep(after_struct(ii).field_name,'_bLk_',' ');
        end
    end
end

end


function [out_var_str]=read_variables(index_file, index_base, index_zone,...
    in_struct,in_var_str,index_min, index_max,location)
% Get variable values via cg_field_read

fieldlist = fieldnames(in_var_str);

for ii =1:length(fieldlist)
    var = fieldlist{ii};
    var_orig = regexprep(var,'_dOt_','.');
    var_orig = regexprep(var_orig,'_dSh_','-');
    var_orig = regexprep(var_orig,'_bLk_',' ');
    if ~strcmp( var, var_orig)
        fprintf(1, 'Info: field variable %s is renamed to %s.\n', var_orig, var);
    end
    
    index_struct = 0;
    for kk=1:length(in_struct)
        if(strcmpi(var_orig, in_struct(kk).field_name) && (location == in_struct(kk).location))
            index_struct = kk; break;
        end
    end
    
    switch (in_struct(index_struct).datatype )
        case 2
            out_var_str.(var) = zeros(index_max(1),in_struct(index_struct).ncol,'int32');
        case 3
            out_var_str.(var) = zeros(index_max(1),in_struct(index_struct).ncol,'single');
        case 5
            out_var_str.(var) = char(zeros(index_max(1),in_struct(index_struct).ncol));
        otherwise
            out_var_str.(var) = zeros(index_max(1),in_struct(index_struct).ncol);
    end
    
    ncol = in_struct(index_struct).ncol;
    
    if ncol==1
        [out_var_str.(var),ierr]= cg_field_read(index_file, index_base, index_zone, ...
            in_struct(index_struct).index_sol, var_orig, in_struct(index_struct).datatype, ...
            index_min, index_max,out_var_str.(var)); chk_error(ierr);
        
    elseif ncol<=3 || ncol==6
        % For naming convention, see http://www.grc.nasa.gov/WWW/cgns/sids/dataname.html
        if ncol<=3  % Vector
            suffix = ['X';'Y';'Z'];
        else        % Tensor
            suffix = ['XX';'XY';'XZ';'YY';'YZ';'ZZ'];
        end
        
        for jj=1:ncol
            varname = [var_orig,suffix(jj,:)];
            [out_var_str.(var)(:,jj),ierr]= cg_field_read(index_file, index_base, index_zone, ...
                in_struct(index_struct).index_sol, varname, in_struct(index_struct).datatype, ...
                index_min, index_max, out_var_str.(var)(:,jj)); chk_error(ierr);
        end
    else
        for jj=1:ncol
            varname = sprintf('%s-%d',var_orig, jj);
            [out_var_str.(var)(:,jj),ierr]= cg_field_read(index_file, index_base, ...
                index_zone, in_struct(index_struct).index_sol, varname, in_struct(index_struct).datatype, ...
                index_min, index_max, out_var_str.(var)(:,jj)); chk_error(ierr);
        end
    end
end
end

function b = match_name( var, inplist)
% Determine whether variable matches input
if ischar(inplist)
    b = ~isempty(regexp(var,inplist,'match'));
else
    b = 0;
    assert(iscell(inplist));
    for ii=1:length(inplist)
        if strcmpi(var,inplist{ii}); b = 1; return; end
    end
end
end

function chk_error( ierr)
% Check whether CGNS returned an error code. If so, get error message
if ierr
    error( ['Error: ', cg_get_error()]);
end
end

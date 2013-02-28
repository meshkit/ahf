function writeucd_unstr( fname_ucd, xs, elems, type, var_nodes, var_faces)
%WRITEUCD_UNSTR Write an AVS/UCD file.
% WRITEUCD_UNSTR( FNAME_UCD, XS, ELEMS, TYPE, VAR_NODES, VAR_FACES) writes
% an ASCII Unstructured Cell Data file, provided inputs described below.
% Though it is a UCD file, the file suffix is ".inp".
%
%    WRITEUCD_UNSTR( FNAME_UCD, XS, ELEMS)
%    WRITEUCD_UNSTR( FNAME_UCD, XS, ELEMS, TYPE)
%    WRITEUCD_UNSTR( FNAME_UCD, XS, ELEMS, TYPE, VAR_NODES, VAR_FACES)
%
% Input Arguments:
% FNAME_UCD is a character string, specifying the output file name.
% XS is nx3 array containing nodal coordinates
% ELEMS is mxd, where d is number of vertices per elements
% TYPE specifies element type, possible inputs are 'pt', 'line', 'tri',
%    'quad', 'tet', 'pyr', 'prism', 'hex', and 'mixed'. This argument is 
%     optional, as it can be inferred from the connectivity.
% VAR_NODES is a structure containing nodal values to be written out.
% VAR_FACES is a structure containing elemental values to be written out.
%
% Note that a field in VAR_NODES can be an nxd array, where d>1.
% In this case, each column will be written out as an individual variable
% name with variable name.  All variable names should be written out fully
% in lowercase (i.e. scalars, vectors, tensors, normals, texture
% coordinates, curvature, or field data)
%
% Example
%     var_nodes.normals = normals;
%     var_nodes.vectors = vectors;
%     var_faces.field  = field;
%     writeucd_unstr( 'test.inp', xs, elems, '', var_nodes, var_faces);
%     writeucd_unstr( 'test.inp', xs, elems, '', var_nodes);
%     writeucd_unstr( 'test.inp', xs, elems, '', [], var_faces);
%
% See also READUCD_UNSTR

if isempty(elems)
    fid = fopen(fname_ucd, 'w');
    % Write out section 1
    n_xs = size(xs,1);
    if nargin<5
      n_vn = 0;
    else
      if isempty(var_nodes)
        n_vn = 0;
      else
        n_vn = length(fieldnames(var_nodes));
      end
    end
    fprintf(fid, '%d %d %d %d 0\n', n_xs, 0, n_vn, 0);
    % Write out section 2
    fprintf(fid, '%d %g %g %g\n', [(1:n_xs); xs']);
    % Write out nodal values
    if n_vn; write_fields( fid, var_nodes, n_xs); end
    fclose(fid);
    return
end
if nargin<3 || nargin>6
    error('Incorrect number of input arguments');
end

% Allow an alternative amount of inputs
if nargin<4; type = ''; end
if nargin<5; var_nodes = []; end
if nargin<6; var_faces = []; end

% Write out in UCD format
%     The UCD file format splits the file into 8 sections, for information
%     regarding these sections, go to:
%     http://people.scs.fsu.edu/~burkardt/html/ucd_format.html
% Write out header

fid = fopen(fname_ucd, 'Wt');
% fprintf(fid, '# This file was written using writeucd_unstr.m\n# \n# %s\n', fname_ucd);

% Write out remaining UCD File

% Assign values
if isempty(var_nodes)
    n_vn = 0;
else
    n_vn = length(fieldnames(var_nodes));
end
if isempty(var_faces)
    n_vf = 0;
else
    n_vf = length(fieldnames(var_faces));
end

n_xs = size(xs,1);
n_elems = size(elems,1);
nvpe = size(elems,2);

if nvpe==1
    [elems_buf, elems_type] = split_mixed_elems( elems);
    if isempty(elems_type)
        % There is actually only one type of elements
        elems = elems_buf;
        n_elems = size(elems,1);
        nvpe = size(elems,2);
    else
        n_elems = size(elems_type,1);
    end
end

% Write out section 1
fprintf(fid, '%d %d %d %d 0\n', n_xs, n_elems, n_vn, n_vf);

% Write out section 2
fprintf(fid, '%d %g %g %g\n', [(1:n_xs); xs']);

% Write out section 3

if nvpe==1
    is2d = is_2dmesh_mex(n_xs,elems);

    % Mixed mesh
    etype = elems_type(1); offset=1; iprev=1;
    for i=1:size(elems_type,1)
        if i==size(elems_type,1) || elems_type(i+1)~=etype
            offset1 = offset + etype*(i-iprev+1);
            % Write out
            pat = get_pattern(etype, type, size(xs,1), elems, is2d);
            fprintf(fid, pat, [(iprev:i); ...
                reshape(elems_buf(offset:offset1-1), etype, i-iprev+1)]);
            
            offset=offset1; iprev=i+1;
            if i<size(elems_type,1); etype = elems_type(i+1); end
        end
    end
else
    pat = get_pattern(nvpe, type, size(xs,1), elems);
    fprintf(fid, pat, [(1:n_elems); elems']);
end

% Write out nodal values
if n_vn; write_fields( fid, var_nodes, n_xs); end

% Write out element-centered values
if n_vf; write_fields( fid, var_faces, n_elems); end

fclose(fid);

function write_fields( fid, vars, nrows)
% Write out fields of a structure

var_list = fieldnames(vars);
nv = length(var_list);

var_lengths_mat = zeros(1,nv+1);
var_lengths_mat(1) = nv;
for ii = 1:nv
    var_lengths_mat(ii+1) = size(vars.(var_list{ii}), 2);
end
fprintf(fid, [repmat('%d ',1,nv+1) '\n'], var_lengths_mat);

%
for ii = 1:nv
    fprintf(fid, '%s, %s\n', var_list{ii}, class(vars.(var_list{ii})));
end

%
ncol = sum(var_lengths_mat(2:end));

% Merge columns of fields into a single matrix
buf = zeros(nrows, ncol+1);
buf(:,1) = (1:nrows)';
start = 2;
for kk=1:nv
    buf(:,start:start+var_lengths_mat(kk+1)-1) = vars.(var_list{kk});
    start = start+var_lengths_mat(kk+1);
end

fprintf(fid, [repmat('%d ',1,ncol+1) '\n'], buf');

function pat = get_pattern(nvpe, type, nv, elems, is2d)
    switch nvpe
        case 2
            pat = '%d 0 line %d %d\n';
        case 3
            pat = '%d 0 tri  %d %d %d\n';
        case 4
            if (isempty(type) || strcmp(type,'MIXED3'))
                if (nargin==5 && ~is2d) || (nargin<5 && ~is_2dmesh_mex(nv,elems))
                    type = 'tet';
                else
                    type = 'quad';
                end
            end
            
            pat = sprintf('%%d 0 %s %%d %%d %%d %%d\n', type);
        case 5
            pat = '%d 0 pyr   %d %d %d %d %d\n';
        case 6
            pat = '%d 0 prism %d %d %d %d %d %d\n';
        case 8
            pat = '%d 0 hex   %d %d %d %d %d %d %d %d\n';
    end

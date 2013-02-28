function writevtk_unstr( fname_vtk, xs, elems, type, var_nodes, var_faces)
%WRITEVTK_UNSTR Write a Legacy ASCII Visualization Toolkit file.
% WRITEVTK_UNSTR( FNAME_VTK, XS, ELEMS, TYPE, VAR_NODES, VAR_FACES) Writes a
% Legacy ASCII Visualization Toolkit file, provided inputs described below.
% This is for ASCII Legacy format only, datafile version 3.0 and only
% supports the 'UNSTRUCTURED_POINTS' dataset type.
%
% Input Arguments:
% FILENAME is a character string, specifying the output file.
% XS is nx3 array containing nodal coordinates
% ELEMS is mx2, mx3, mx4 or mx4 containing element connectivity
% TYPE specifies element type, possible inputs are 'LINESEG', 'TRIANGLE',
%   'QUADRILATERAL', 'TETRAHEDRON', or 'BRICK' (must be in caps).
% VAR_NODES is a structure containing nodal values to be written out.
% VAR_FACES is a structure containing elemental values to be written out.
%
% Note that a field in VAR_NODES can be an nxd array, where d>1.
% In this case, each column will be written out as an individual variable
% name with variable name.  All variable names must be written out fully in
% lowercase (i.e. scalars, vectors, tensors, normals, texture coordinates,
% or field data)
%
% Example
%     var_nodes.normals = normals;
%     var_nodes.vectors = vectors;
%     var_faces.field  = field;
%     writevtk_unstr( 'test.vtk', xs, elems, '', var_nodes, var_faces);
%     writevtk_unstr( 'test.vtk', xs, elems, '', var_nodes);
%     writevtk_unstr( 'test.vtk', xs, elems, '', [], var_faces);
%
% See also READVTK_UNSTR

% Allow an alternative amount of inputs
switch nargin
    case {3,4}
        var_nodes = [];
        var_faces = [];
    case 5
        var_faces = [];
    case 6
        % Do nothing
    otherwise
        error('Not a valid amount of inputs')
end

if nargin==3 || isempty(type)
    switch size(elems,2)
        case 1
            type='mixed';
        case 2
            type = 'line';
        case 3
            type = 'tri';
        case 4
            if nargin>=4 && ~isempty(type) && (type(1)=='Q' || type(1)=='q' ) || ...
                    (nargin<4 || isempty(type)) && is_2dmesh_mex( size(xs,1), elems)
                type = 'quad';
                
                % If fourth vertex ID is zero for any element, change to ID of
                % third vertex.
                empty = elems(:,4)==0;
                if any(empty)
                    elems(empty,4)=elems(empty,3);
                end
            else
                type = 'tet';
            end
        case 5
            type = 'pyr';
        case 6
            type = 'prism';
        case 8
            type = 'hex';
        otherwise
            error('Unknown element type');
    end
end

% Write out in VTK format
% Write out header
fid = fopen(fname_vtk, 'Wt');
fprintf(fid, '# vtk DataFile Version 3.0\n');
fprintf(fid, 'This file was written using writevtk_unstr.m\n');
fprintf(fid, 'ASCII\n');

% Write out remaining VTK File pending on dataset type
n_xs = size(xs,1);
if(strcmp(type,'mixed'))
    [elems_buf, elems_type, elems_offsets] = ...
                split_mixed_elems( elems);
    n_elems = size(elems_type,1);
    
else
    n_elems = size(elems,1);
    rowsize_elems = size(elems,2);
end

% Write out header
fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');
fprintf(fid, 'POINTS %i double', n_xs);

% Write out vertices
fprintf(fid, '\n%g %g %g', xs');


if(~strcmp(type,'mixed'));
% Write out connectivity header
  fprintf(fid, '\n\nCELLS %i %i', n_elems, size(elems,1)*...
      (1+rowsize_elems));
    % Convert TYPE from string to integer
    switch type
        case 'pt'
            type = 2;
        case 'line'
            type = 3;
        case 'tri'
            type = 5;
        case 'quad'
            type = 9;
        case 'tet'
            type = 10;
        case 'hex'
            type = 12;
        case 'prism'
            type = 13;
        case 'pyr'
            type = 14;
        otherwise
            error('Unknown element type');
    end

    % Write out connectivity of vertices

    switch rowsize_elems   
        case 2
            pat = '\n%d %d %d';
        case 3
            pat = '\n%d %d %d %d';
        case 4
            pat = '\n%d %d %d %d %d';
        case 8
            pat = '\n%d %d %d %d %d %d %d %d %d';
    end
    i = 1:1:n_elems;
    elems_mat = zeros(n_elems,rowsize_elems+1);
    elems_mat(i,2:end) = elems(i,:)-1;
    elems_mat(i,1) = rowsize_elems;
    fprintf(fid, pat, elems_mat');
else
    % DEAL WITH THE MIXED TYPE
    fprintf(fid, '\n\nCELLS %i %i', n_elems, sum(elems_type)+n_elems);
    for i=1:n_elems
      switch elems_type(i)   
        case 2
            pat = '\n%d %d %d';
            mixedtype=3;
        case 3
            pat = '\n%d %d %d %d';
            mixedtype=5;
        case 4
            pat = '\n%d %d %d %d %d';
            mixedtype=10;
        case 5
            pat = '\n%d %d %d %d %d %d';
            mixedtype=14;
        case 6
            pat = '\n%d %d %d %d %d %d %d';
            mixedtype=13;
        case 8
            pat = '\n%d %d %d %d %d %d %d %d %d';
            mixedtype=12;
      end
      thiselconnect=elems_buf(elems_offsets(i)+1:elems_offsets(i)+elems_type(i));
      thiselconnect=thiselconnect-1; %ZERO BASED SYSTEM
      fprintf(fid, pat, elems_type(i), thiselconnect);
      elems_type(i)=mixedtype; % SET TO VTK TYPE
    end

end

% Write out cell types
fprintf(fid, '\n\nCELL_TYPES %i', n_elems);
if(~strcmp(type,'mixed'));
  type_mat(i) = type;
  fprintf(fid, '\n%i', type_mat);
else
  fprintf(fid, '\n%i', elems_type);
end

% Write out nodal variables
if ~isempty(var_nodes)
    fprintf(fid, '\n\nPOINT_DATA %i', n_xs);
    % Obtain list of nodal variables and coinciding data
    if nargin>=5 && ~isempty(var_nodes)
        assert(isstruct(var_nodes));
        varlist_nodes = fieldnames( var_nodes);
    else
        varlist_nodes = {};
    end
    % Write out header and data for each nodal variables
    for i = 1:size(fieldnames(var_nodes),1)
        var_cols = (size((var_nodes.(varlist_nodes{i})),2));

        switch var_cols
            case 1
                pat = '%g\n';
            case 3
                pat = '%g %g %g\n';
            case 6
                pat = '%g %g %g %g %g %g\n';
            otherwise
                error('invalid row length for variable, requires 1 or 3')
        end
        if strcmp(varlist_nodes{i}, 'texture coordinates')
            fprintf(fid, '\nTEXTURE COORDINATES %s double\n',  ...
            varlist_nodes{i});
        elseif strcmp(varlist_nodes{i}, 'normals')
            fprintf(fid, '\nNORMALS %s double\n',  ...
            varlist_nodes{i});
        elseif strcmp(varlist_nodes{i}, 'field data')
            fprintf(fid, '\nFIELD DATA %s double\n',  ...
            varlist_nodes{i});
        elseif size(fieldnames(var_nodes{i}),2)==1
            fprintf(fid, '\nSCALARS %s double\n', varlist_nodes{i});
            fprintf(fid, 'LOOKUP_TABLE default\n');
        elseif size(fieldnames(var_nodes),2)==3
            fprintf(fid, '\nVECTORS %s double\n', varlist_nodes{i});
        elseif size(fieldnames(var_nodes),2)==6
            fprintf(fid, '\nTENSORS %s double\n', varlist_nodes{i});
        else
            error('Variable type not valid')
        end
        fprintf(fid, pat, var_nodes.(varlist_nodes{i})');
    end
end

% Write out face variables
if ~isempty(var_faces)
    % Write out face variables header
    fprintf(fid, '\nCELL_DATA %i\n', n_elems);
    % Obtain list of face variables and coinciding data
    if nargin>=6  && ~isempty(var_faces)
        assert(isstruct(var_faces));
        varlist_faces = fieldnames( var_faces);
    else
        varlist_faces = {};
    end
    % Write out header and data for each face variables
    for i = 1:size(varlist_faces,1)
        var_cols = (size((var_faces.(varlist_faces{i})),2));
        switch var_cols
            case 1
                pat = '%g\n';
            case 3
                pat = '%g %g %g\n';
            case 6
                pat = '%g %g %g %g %g %g\n';
            otherwise
                error('invalid row length for variable, requires 1 or 3')
        end
        rowlength=size(getfield(var_faces, varlist_faces{i}),2); %#ok<GFLD>
        if strcmp(varlist_faces{i}, 'texture coordinates')
            fprintf(fid, '\nTEXTURE COORDINATES %s double\n',  ...
            varlist_faces{i});
        elseif strcmp(varlist_faces{i}, 'normals')
            fprintf(fid, '\nNORMALS %s double\n',  ...
            varlist_faces{i});
        elseif strcmp(varlist_faces{i}, 'field data')
            fprintf(fid, '\nFIELD DATA %s double\n',  ...
                varlist_faces{i});
        elseif rowlength==1
            fprintf(fid, '\nSCALARS %s double\n', varlist_faces{i});
            fprintf(fid, 'LOOKUP_TABLE default\n');
        elseif rowlength==3
            fprintf(fid, '\nVECTORS %s double\n', varlist_faces{i});
        elseif rowlength==6
            fprintf(fid, '\nTENSORS %s double\n', varlist_faces{i});
        else
            error('Variable type not valid')
        end
        %end
        fprintf(fid, pat, var_faces.(varlist_faces{i})');
    end
end

fclose(fid);

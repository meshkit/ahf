function writegmv_unstr( fname_gmv, xs, elems, type, var_nodes, var_faces)
% WRITEGMV_UNSTR   Write out unstructured mesh in GMV format.
%
% Example use:
% writegmv_unstr( 'fname.gmv', xs, elems)
% writegmv_unstr( 'fname.gmv', xs, elems, '', struct('varname_v',var_nodes))
% writegmv_unstr( 'fname.gmv', xs, elems, '', struct( 'varname_v',var_nodes), struct('varname_f',var_faces))
% writegmv_unstr( 'fname.gmv', xs, elems, '', [], struct('varname_f',var_faces))
%
% Note: If the filename has suffix 'gmvb' or 'gmb', then it writes in binary 
% format. Otherwise, it writes in ASCII format. Note that in binary format, GMV
% uses only the first eight characters of variable names, and it would lead to
% an error if two variable names are the same for the first eight characters.
%
% See <a href="http://www-xdiv.lanl.gov/XCM/gmv/GMVHome.html">GMV's homepaeg</a>.

% Note: This function silently compiles the MEX function the first time it
% is called during a MATLAB session and then invokes the MEX function.

persistent compiled;

% Build MEX version
compiled = 1;
if nargin==0 || ~exist(['writegmv_mex.' mexext], 'file') || (isempty(compiled) && ...
    isnewer(['GMV/Mex/write_gmv_unst.c'],['writegmv_mex.' mexext]))

    disp('Building GMV...');

    oldpwd = pwd;
    dir = which('writegmv_unstr'); cd(dir(1:end-16));

    if isoctave
        command = ['mkoctfile --mex -IGMV/Source -o ' ...
                   'writegmv_mex.mex GMV/Mex/write_gmv_unst.c'];
    else
        command = ['mex -IGMV/Source -g -output ' ...
                   'writegmv_mex GMV/Mex/write_gmv_unst.c'];
    end

    try
        if nargin==0
            disp(command);
            eval(command);
        else
            eval(command);
        end

        if isoctave
            if ispc; OBJEXT = 'obj'; else OBJEXT='o'; end
            delete(['GMV/Mex/write_gmv_unst.' OBJEXT]);
        end

        % Update paths in Matlab
        if ~isoctave && ispc; rehash('path'); else rehash; end
    catch
        error('Error during compilation of GMV I/O utility.');
    end

    cd(oldpwd);
    compiled = 1;

    disp('GMV was built successfully.');

    if nargin==0; return; end
else
    compiled = 1;
end

% Call the MEX version.
switch nargin
    case 3
        writegmv_mex( fname_gmv, xs, elems);
    case 4
        writegmv_mex( fname_gmv, xs, elems, type);
    case 5
        [varlist_nodes, var_nodes] = get_firstfield( var_nodes, 5);
        if( ~isempty(varlist_nodes) && size(var_nodes,1)~=size(xs,1));
            error('Wrong dimensions in nodal variables.');
        end
        writegmv_mex( fname_gmv, xs, elems, type, var_nodes, varlist_nodes);
    case 6
        [varlist_nodes, var_nodes] = get_firstfield( var_nodes, 5);
        if( ~isempty(varlist_nodes) && size(var_nodes,1)~=size(xs,1));
            error('Wrong dimensions in nodal variables.');
        end
        [varlist_faces, var_faces] = get_firstfield( var_faces, 6);
        if( ~isempty(varlist_faces) && size(var_faces,1)~=size(elems,1));
            error('Wrong dimensions in cell-centered variables.');
        end
        writegmv_mex( fname_gmv, xs, elems, type, var_nodes, varlist_nodes, var_faces, varlist_faces);
    otherwise
        error('Incorrect number of arguments\n');
end


function [name, field] = get_firstfield( var, num)

if ~isempty(var) && ~isstruct(var)
    error('Incorrect input argument %d. Must be a struct.', num);
end

if ~isempty(var)
    names = fieldnames(var); name = names{1};
    field = double(var.(name));

    if size(names)>1
        warning('Only first field %s will be written.', name);
    end
else
    name = ''; field = [];
end

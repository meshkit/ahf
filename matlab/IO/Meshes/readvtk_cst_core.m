function [xs, elems, types, var_nodes, var_elems] = readvtk_cst_core(filename)
%READVTK_UNSTR Read in a Legacy ASCII Visualization Toolkit file.
% [XS,ELEMS,TYPE,VAR_NODES,VAR_ELEMS] = READVTK_UNSTR(FILENAME) Reads
% Visualization Toolkit file, FILENAME.
%
% The output arguments are the coordinates of points in an nx3 matrix XS,
% a list of the elements in a mx2, mx3, mx4, or mx8 matrix ELEMS, the type
% of elements TYPE, the node variables VAR_NODES, and the element variables
% VAR_ELEMS.  The routine only supports VTK files that are Legacy ASCII
% format with dataset type 'UNSTRUCTURED_GRID'.
%
% See also WRITEVTK_UNSTR

% Set variables to empty, in case file has none
var_nodes = [];
var_elems = [];
% Allow an alternative amount of inputs
switch nargin
    case 1
        % Do nothing
    otherwise
        error('Not a valid amount of inputs')
end
fid = fopen(filename, 'r');
%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end
% Skip header until the 'DATASET' keyword
get_nextline(fid);
get_nextline(fid);
get_nextline(fid);
s = get_nextline(fid);
tmp = sscanf(s, '%s');

if strcmpi(tmp(1:7),'DATASET')
    assert( ~feof(fid));
    t = tmp(8:end);
    % Determine dataset type is an unstructured grid
    switch t
        case 'UNSTRUCTURED_GRID'
            % Find number of points N_XS
            while ~strcmpi(t,'POINTS') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'POINTS')
                assert( ~feof(fid));
                [t,s] = strtok(s);
                n_xs = str2double(t);
                % Read points XS
                ts = fscanf(fid, '%g', [3,n_xs]);
                xs = ts';
            end
            % Find number of cells N_ELEMS and number of cell points ELEM_SIZE
            while ~strcmpi(t,'CELLS') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'CELLS')
                assert( ~feof(fid));
                [t,s] = strtok(s);
                n_elems = str2double(t);
                [t,s] = strtok(s);
                elem_size = str2double(t);
                % Read connectivity of points, forming elements ELEMS
                elems = fscanf(fid, '%g', elem_size);
                %elems = elems(2:end,:)' + ones(n_elems,(elem_size/n_elems)-1);
            end
            
            % Find type of cells, TYPE
            while ~strcmpi(t,'CELL_TYPES') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'CELL_TYPES')
                assert( ~feof(fid));
                %s = get_nextline(fid);
                %[t,s] = strtok(s);
            end
            s = get_nextline(fid);
            [t,s] = strtok(s);
            type = str2double(t);
            type = round(type);
            % Assign string to element type
            %switch type
            %    case 2
            %        type = 'pt';
            %    case 3
            %        type = 'line';
            %    case 5
            %        type = 'tri';
            %    case 9
            %        type = 'quad';
            %    case 10
            %        type = 'tet';
            %    case 12
            %        type = 'hex';
            %    case 13
            %        type = 'prism';
            %    case 14
            %        type = 'pyr';

            %    otherwise
            %        error('Unknown element type');
            %end
            %if(nargout<4);  return;  end;
            % Get nodal variables
            temp = fscanf(fid, '%g', [1,n_elems-1]);
            types=[type temp];
            
            if(nargout<4);  return;  end;
            % Get nodal variables
            % Get first nodal variable and values
            while ~strcmpi(t,'POINT_DATA') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
                var_name = t;
                while isnan(str2double(t))
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                end
                ts_new = zeros(n_xs,1);
                ts_new(1,1) = str2double(t);
                % Read values for first nodal variable
                ts = fscanf(fid, '%g', [1,n_xs]);
                if numel(ts)~= 0
                    for i = 1:n_xs-1
                        ts_new(i+1,1) = ts(i);
                    end
                else
                    ts_new = zeros( n_xs,1);
                end
                var_nodes = setfield(var_nodes,var_name,ts_new);
                s = fgetl(fid);
                [t,s] = strtok(s);
                while strcmpi(t,[]) && ~feof(fid)
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                end
                % Get all remaining nodal variables and their values
                while ~feof(fid) && ~strcmpi(t,'CELL_DATA')
                    var_name = t;
                    while isnan(str2double(t))
                        s = get_nextline(fid);
                        [t,s] = strtok(s);
                    end
                    ts_new = zeros(n_xs,1);
                    ts_new(1,1) = str2double(t);
                    % Read values for nodal variable
                    ts = fscanf(fid, '%g', [1,n_xs]);
                    if numel(ts)~= 0
                        for i = 1:n_xs-1
                            ts_new(i+1,1) = ts(i);
                        end
                    else
                        ts_new = zeros( n_xs,1);
                    end
                    var_nodes = setfield(var_nodes,var_name,ts_new);
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                    while strcmpi(t,[]) && ~feof(fid)
                        s = get_nextline(fid);
                        [t,s] = strtok(s);
                    end
                end

                % Get element variables
                % Get first element variable and values
                while ~strcmpi(t,'CELL_DATA') && ~feof(fid)
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                end
                if ~feof(fid)
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    var_name = t;
                    while isnan(str2double(t))
                        s = fgetl(fid);
                        [t,s] = strtok(s);
                    end
                    ts_new = zeros(n_elems,1);
                    ts_new(1,1) = str2double(t);
                    % Read values for first element variable
                    ts = fscanf(fid, '%g', [1,n_elems]);
                    if numel(ts)~= 0
                        for i = 1:n_elems-1
                            ts_new(i+1,1) = ts(i);
                        end
                    else
                        ts_new = zeros( n_xs,1);
                    end
                    var_elems = setfield(var_elems,var_name,ts_new);
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    while strcmpi(t,[]) && ~feof(fid)
                        s = fgetl(fid);
                        [t,s] = strtok(s);
                    end
                    % Get all remaining element variables and their values
                    while ~feof(fid) && ~strcmpi(t,'POINT_DATA')
                        var_name = t;
                        while isnan(str2double(t))
                            s = fgetl(fid);
                            [t,s] = strtok(s);
                        end
                        ts_new = zeros(n_elems,1);
                        ts_new(1,1) = str2double(t);
                        % Read values for element variable
                        ts = fscanf(fid, '%g', [1,n_elems]);
                        if numel(ts)~= 0
                            for i = 1:n_elems-1
                                ts_new(i+1,1) = ts(i);
                            end
                        else
                            ts_new = zeros( n_xs,1);
                        end
                        var_elems = setfield(var_elems,var_name,ts_new);
                        s = fgetl(fid);
                        [t,s] = strtok(s);
                        while strcmpi(t,[]) && ~feof(fid)
                            s = fgetl(fid);
                            [t,s] = strtok(s);
                        end
                    end
                end
            end
        case 'POLYDATA'
            % Find number of points N_XS
            while ~strcmpi(t,'POINTS') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'POINTS')
                assert( ~feof(fid));
                [t,s] = strtok(s);
                n_xs = str2double(t);
                % Read points XS
                ts = fscanf(fid, '%g', [3,n_xs]);
                xs = ts';
            end
            % Find number of cells N_ELEMS and number of cell points ELEM_SIZE
            while ~strcmpi(t,'POLYGONS') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'POLYGONS')
                assert( ~feof(fid));
                [t,s] = strtok(s);
                n_elems = str2double(t);
                [t,s] = strtok(s);
                elem_size = str2double(t);
                % Read connectivity of points, forming elements ELEMS
                elems = fscanf(fid, '%g', [(elem_size/n_elems),n_elems]);
                elems = elems(2:end,:)' + ones(n_elems,(elem_size/n_elems)-1);
            end
        otherwise
            error('Only UNSTRUCTURED_GRID dataset type is supported');
    end
end

fclose(fid);

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && isempty(s)
    s = fgetl(fid);
end
%skip string of gaps
for i = 1 : length(s)
    if (s(i) ~= ' ')
        s = s(i:end);
        return
    end
end
s = get_nextline(fid);

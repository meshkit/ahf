function [xs, elems, type, var_nodes, var_elems] = readvtk_unstr2(filename)
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
mixedtype=false;
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
                if(fix(elem_size/n_elems)==elem_size/n_elems)
                  % NOTE THIS ASSUMES A SINGLE ELEMENT TYPE
                  elems = fscanf(fid, '%g', [(elem_size/n_elems),n_elems]);
                  elems = elems(2:end,:)' + ones(n_elems,(elem_size/n_elems)-1);
                else
                  elems = fscanf(fid, '%g', [(elem_size),1]);
                  % Check that mesh is indeed HYBRID
                  num_type = elems(1);
                  for ii = 2:n_elems
                    if num_type~=elems(1+(num_type+1)*(ii-1))
                      num_type = 0;
                      break;
                    end
                  end
                  % Change ELEMS so that it is the correct type of
                  % output matrix.
                  if num_type ~= 0
                    new_elems = zeros(n_elems,num_type,'int32');
                    for ii = 1:n_elems
                      new_elems(ii,:) = elems((num_type+1)*(ii-1)+2:(num_type+1)*(ii-1)+(num_type+1));
                    end
                    [npe, typestr] = get_elemtype_string( element_type, icelldim);
                    elems = new_elems;
                  end
                  node_zero=size(find(elems==0),1);
                  if(node_zero)
                    fprintf(1,'Input mesh is zero-based\n');
                    fprintf(1,'Converting to a one-based mesh ...\n');
                    [elems_buf, elems_type, elems_offsets] = ...
                      split_mixed_elems( int32(elems) );
                    elems_buf=elems_buf+1;
                    [elems] = merge_mixed_elems( elems_buf, elems_type, elems_offsets);
                    mixedtype=true;
                  end
                end
            end
         
            % Find type of cells, TYPE
            while ~strcmpi(t,'CELL_TYPES') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if strcmpi(t,'CELL_TYPES')
                assert( ~feof(fid));
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            s = get_nextline(fid);
            if(mixedtype)
                type='mixed';
            else
                [t,s] = strtok(s);
                type = str2double(t);
                type = round(type);
                % Assign string to element type
                % NOTE THAT THIS PRESUMES THAT THE MESH IS NOT HYBRID
                switch type
                    case 2
                        type = 'pt';
                    case 3
                        type = 'line';
                    case 5
                        type = 'tri';
                    case 9
                        type = 'quad';
                    case 10
                        type = 'tet';
                    case 11
                        type = 'hex';
                    case 12
                        type = 'hex';
                    case 13
                        type = 'prism';
                    case 14
                        type = 'pyr';

                    otherwise
                      error('Unknown element type');
                end
            end
            % JUST ADVANCE TO THE NEXT BLOCK
            ts = fscanf(fid, '%d', [1,n_elems-1]); %#ok<NASGU>
            %
            % Get cell variables
            complabel={'_1','_2','_3','_4','_5','_6','_7','_8','_9'};
            s = get_nextline(fid);
                [t,s] = strtok(s); %#ok<NASGU>
            %
            if(nargout<4)
                return
            end
            while ~strcmpi(t,'CELL_DATA') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s); %#ok<NASGU,STTOK>
            end
            if ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
                if(strcmp(t,'SCALARS'))
                    while ~strcmpi(t,'FIELD') && ~feof(fid) && ~strcmpi(t,'POINT_DATA')
                        s = get_nextline(fid);
                        [t,s] = strtok(s); %#ok<NASGU,STTOK>
                    end
                end
                if(strcmp(t,'FIELD'))
                    nFields=strtok(s,' FieldData');
                    if(isempty(str2num(nFields))) %#ok<ST2NM>
                      nFields=strtok(s,' attributes');
                    end
                    s = get_nextline(fid);
                    t = strtok(s);
                    s=strtok(s,t);
                    nComponents=strtok(s);
                else
                    nFields=1;
                    nComponents=1;
                end
                for variable=1:str2double(nFields)
                  var_name = t;
                    % Read values for cell variable
                    ts = fscanf(fid, '%g', ...
                        [1,n_elems*str2double(nComponents)]);
                    if numel(ts)== 0
                      continue;%move on
                    end
                    if(~strcmp(var_name,'cellID'))
                      if(str2double(nComponents)>1)
                            
                            for component=1:str2double(nComponents)
                               var_name_component=strcat(var_name,...
                                 char(complabel(component)));
                                 start=component;
                                 skip=str2double(nComponents);
                                 stop=n_elems*skip;
                                ts_new=ts(start:skip:stop)';
                                var_elems = setfield(var_elems,...
                                  var_name_component,ts_new); %#ok<SFLD>
                            end

                      else
                        var_elems = setfield(var_elems,var_name,...
                            ts'); %#ok<SFLD>
                      end
                    end
                  %end
                  clear ts;
                  clear ts_new;
                  s = fgetl(fid); %#ok<NASGU>
                  %s = get_nextline(fid);
                  t = strtok(s);
                  s=strtok(s,t);
                  nComponents=strtok(s);
                end
                  
            end
            %
            while ~strcmpi(t,'POINT_DATA') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s); %#ok<NASGU,STTOK>
            end
            if ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
                if(strcmp(t,'FIELD'))
                    nFields=strtok(s,' FieldData');
                    if(isempty(str2num(nFields))) %#ok<ST2NM>
                      nFields=strtok(s,' attributes');
                    end
                    s = get_nextline(fid);
                    t = strtok(s);
                    s=strtok(s,t);
                    nComponents=strtok(s);
                else
                    nFields=1;
                    nComponents=1;
                    if(strcmp(t,'SCALARS'))
                        temp=strtok(s);
                        s = get_nextline(fid);
                        t=temp;
                    end
                end
                for variable=1:str2double(nFields)
                  var_name = t;   
                  % Read values for cell variable
                  if(ischar(nComponents))
                      nComponents=str2double(nComponents);
                  end
                  ts = fscanf(fid, '%g', ...
                        [1,n_xs*str2double(nComponents)]);
                  if numel(ts)== 0
                     continue;%move on
                  end
                  if(str2double(nComponents)>1)   
                     for component=1:str2double(nComponents)
                       var_name_component=strcat(var_name,...
                                 char(complabel(component)));
                       start=component;
                       skip=str2double(nComponents);
                       stop=n_xs*skip;
                       ts_new=ts(start:skip:stop)';
                       var_nodes = setfield(var_nodes,...
                                  var_name_component,ts_new); %#ok<SFLD>
                     end
                  else
                        var_nodes = setfield(var_nodes,var_name,...
                            ts'); %#ok<SFLD>
                  end
                  s = fgetl(fid); %#ok<NASGU>
                  s = get_nextline(fid);
                  t = strtok(s);
                  s=strtok(s,t);
                  nComponents=strtok(s);
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
                if(fix(elem_size/n_elems)==elem_size/n_elems)
                  elems = fscanf(fid, '%g', [(elem_size/n_elems),n_elems]);
                  elems = elems(2:end,:)' + ones(n_elems,(elem_size/n_elems)-1);
                  if(size(elems,2)==3)
                     type='tri';
                  elseif(size(elems,2)==4)
                     type='quad';
                  end
                else
                  type='mixed';
                  %MIXED TYPE
                  elems = fscanf(fid, '%g', [(elem_size),1]);
                  % Check that mesh is indeed HYBRID
                  num_type = elems(1);
                  for ii = 2:n_elems
                    if num_type~=elems(1+(num_type+1)*(ii-1))
                      num_type = 0;
                      break;
                    end
                  end
                  % Change ELEMS so that it is the correct type of
                  % output matrix.
                  if num_type ~= 0
                    new_elems = zeros(n_elems,num_type,'int32');
                    for ii = 1:n_elems
                      new_elems(ii,:) = elems((num_type+1)*(ii-1)+2:(num_type+1)*(ii-1)+(num_type+1));
                    end
                    [npe, typestr] = get_elemtype_string( element_type, icelldim);
                    elems = new_elems;
                  end
                  node_zero=size(find(elems==0),1);
                  if(node_zero)
                    fprintf(1,'Input mesh is zero-based\n');
                    fprintf(1,'Converting to a one-based mesh ...\n');
                    [elems_buf, elems_type, elems_offsets] = ...
                      split_mixed_elems( elems );
                    elems_buf=elems_buf+1;
                    [elems] = merge_mixed_elems( elems_buf, elems_type, elems_offsets);
                    mixedtype=true;
                  end
                end
            end
            %CELL_DATA n_elems
            %SCALARS %0Afieldname float
            %LOOKUP_TABLE default
            %
            %
            if(nargout==5)
            while ~strcmpi(t,'CELL_DATA') && ~feof(fid)
                s = get_nextline(fid);
                [t,s] = strtok(s);
            end
            if ~feof(fid)
                s = get_nextline(fid);
                t=strtok(s);
                if(strcmp(t,'SCALARS'))
                    s=strtok(s,'SCALARS');
                    t=strtok(s,'%');
                    var_name = t;
                end
                while isnan(str2double(t))
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                end
                ts_new = zeros(n_elems,1,'int32');
                ts_new(1,1) = str2double(t);
                % Read values for first nodal variable
                ts = fscanf(fid, '%g', [1,n_elems]);
                if numel(ts)~= 0
                    for i = 1:n_elems-1
                        try
                        ts_new(i+1,1) = ts(i);
                        catch
                            fprintf(1,'Here\n')
                        end
                    end
                else
                    ts_new = zeros( n_elems,1,'int32');%return zeros
                end
                var_elems = setfield(var_elems,var_name,ts_new);
                s = fgetl(fid);
                [t,s] = strtok(s);
                while strcmpi(t,[]) && ~feof(fid)
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                end
                % Get all remaining nodal variables and their values
                while ~feof(fid) && ~strcmpi(t,'POINT_DATA')
                    var_name = t;
                    while isnan(str2double(t))
                        s = get_nextline(fid);
                        [t,s] = strtok(s);
                    end
                    ts_new = zeros(n_elems,1,'int32');
                    ts_new(1,1) = int32(str2double(t));
                    % Read values for nodal variable
                    ts = fscanf(fid, '%g', [1,n_elems]);
                    if numel(ts)~= 0
                        for i = 1:n_elems-1
                            ts_new(i+1,1) = ts(i);
                        end
                    else
                        ts_new = zeros( n_elems,1,'int32');%return array of zeros
                    end
                    var_elems = setfield(var_elems,var_name,ts_new);
                    s = get_nextline(fid);
                    [t,s] = strtok(s);
                    while strcmpi(t,[]) && ~feof(fid)
                        s = get_nextline(fid);
                        [t,s] = strtok(s);
                    end
                end

                % Get element variables
                % Get first element variable and values
                %POINT_DATA n_xs
                %SCALARS %0APressure float
                %LOOKUP_TABLE default
                while ~strcmpi(t,'POINT_DATA') && ~feof(fid)
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
                    ts_new = zeros(n_xs,1,'int32');
                    ts_new(1,1) = str2double(t);
                    % Read values for first element variable
                    ts = fscanf(fid, '%g', [1,n_xs]);
                    if numel(ts)~= 0
                        for i = 1:n_xs-1
                            ts_new(i+1,1) = ts(i);
                        end
                    else
                        ts_new = zeros( n_xs,1,'int32');
                    end
                    var_nodes = setfield(var_nodes,var_name,ts_new);
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    while strcmpi(t,[]) && ~feof(fid)
                        s = fgetl(fid);
                        [t,s] = strtok(s);
                    end
                    % Get all remaining element variables and their values
                    while ~feof(fid) && ~strcmpi(t,'FIELD_DATA')
                        var_name = t;
                        while isnan(str2double(t))
                            s = fgetl(fid);
                            [t,s] = strtok(s);
                        end
                        ts_new = zeros(n_xs,1,'int32');
                        ts_new(1,1) = str2double(t);
                        % Read values for element variable
                        ts = fscanf(fid, '%g', [1,n_xs]);
                        if numel(ts)~= 0
                            for i = 1:n_xs-1
                                ts_new(i+1,1) = ts(i);
                            end
                        else
                            ts_new = zeros( n_xs,1,'int32');
                        end
                        var_nodes = setfield(var_nodes,var_name,ts_new);
                        s = fgetl(fid);
                        [t,s] = strtok(s);
                        while strcmpi(t,[]) && ~feof(fid)
                            s = fgetl(fid);
                            [t,s] = strtok(s);
                        end
                    end
                end
            end
            end
        otherwise
            error('Only UNSTRUCTURED_GRID and POLYDATA are supported');
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

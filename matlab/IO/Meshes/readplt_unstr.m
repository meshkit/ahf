function [xs, elems, type, var_nodes, var_elems] = ...
    readplt_unstr(filename, node_var_list, elem_var_list)
%READPLT: Read in an ASCII Tecplot file.
% [XS, ELEMS, TYPE, VAR_NODES, VAR_ELEMS] = ...
%    READPLT_UNSTR(FILENAME, NODE_VAR_LIST, ELEM_VAR_LIST)
%
% Arguments:
% FILENAME is a character string.
% NODE_VAR_LIST, if present, is either a character string specifying some
%    regular express for nodal variables to be read, or a cell structure
%    containing the list of nodal variables to be read. If not present,
%    then all nodal variables are read.
% ELEM_VAR_LIST is analogous to NODE_VAR_LIST but is for elemental values.
%
% XS is nx3 array containing nodal coordinates
% ELEMS is mx3 or mx4, containing element connectivity
% VAR_NODES is a structure containing nodal values.
% VAR_ELEMS is a structure containing elemental values.
%
% Example usage: 
%      [xs, elems, type, var_nodes, var_elems] = readplt_unstr('file.plt');
%      [xs, elems, type, var_nodes, var_elems] = readplt_unstr('file.plt',{'vfield1','vfield2'}, 'efield1');
%
% Limitation: The variable names in the Tecplot file should be proper 
%     MATLAB variable names (i.e., they should start with a letter and
%     contain only letters, digits, and underscore. One except is the
%     variables named as "<fieldname>-<int>" (such as "field1-1", "field1-2"),
%     for which the variables are grouped into a single variable "<fieldname>"
%     (i.e, field1 in this example).
%
% See also writeplt_unstr.

% FIXME: If elemental data are given, it current requires data
% packing to be block.

fid = fopen(filename, 'r');
s = get_nextline(fid);

% Skip header until the 'VARIABLES' or 'ZONE' keyword
[t,s] = strtok(s,' =');
while ~strcmpi(t,'VARIABLES') && ~strcmpi(t,'ZONE') && ~feof(fid)
    s = get_nextline(fid);
    [t,s] = strtok(s,'= ,'); %#ok<*STTOK>
end

% Collect variable names
if strcmpi(t,'VARIABLES')
    [var_list,s] = obtain_varlist(fid, s);
else
    var_list = {};
end

nvar = length(var_list); if nvar==0; nvar=3; end

% Collect other information about zone.
var_location = zeros(nvar,1); var_location(:)='n';
% Find 'N=', 'Nodes=', 'NODES=', 'E=', 'Elements=', 'ELEMENTS=', 'ET=', and
% 'ZONETYPE=', 'DATAPACKING', 'F', 'VARLOCATION'
nv = 0; ne = 0; type=''; packing='POINT';
while true
    [tok,s] = strtok( s, '= ');
    [val,s] = strtok( s(2:end), ' ,');
    if val(1)=='"' && val(end)~='"'
        ind = strfind(s,'"');
        if isempty(ind)
            error('Mismatched quote');
        else
            val = [val, s(1:ind)]; %#ok<AGROW>
            s = s(ind+1:end);
        end
    elseif val(1)=='('
        ind = strfind(s,')');
        if isempty(ind)
            if val(end)==')'
                val = val(2:end-1);
            else
                error('Mismatched parenthasis');
            end
        else
            val = [val(2:end), s(1:ind(1)-1)];
            s = s(ind+1:end);
        end
    end

    switch upper(tok)
        case {'N','NODES'}
            nv = str2double( val);
        case {'E','ELEMENTS'}
            ne = str2double( val);
        case 'ZONETYPE'
            type = upper(val(3:end));
        case 'ET'
            type = upper(val);
        case 'F'
	    	packing = upper(val(3:end));
	    case 'DATAPACKING'
            packing = val;
	    case 'VARLOCATION'
            vlist = regexp( val, '[0-9]+', 'match');
            for ii=1:length(vlist)
                var_location(str2num(vlist{ii})) = 'e'; %#ok<ST2NM>
            end
        case 'T'
            % Ignore it
        case 'STRANDID'
            % Ignore it
        case 'SOLUTIONTIME'
            % Ignore it
        case 'DT'
            % Ignore it
        case 'DATASETAUXDATA'
            % Ignore it
        otherwise
            error('Unsupported keyword %s', tok);
    end

    if isempty(s)
        pos = ftell(fid);
        s = get_nextline(fid);
        if ~isempty(sscanf(s, '%f'))
            % Rewind and stop the loop
            fseek(fid, pos, -1);
            break;
        end
    elseif s(1)==','
        s = s(2:end);
    end
end

% Read in coordinates and values
if strcmpi(packing, 'POINT') || strcmpi(packing, 'POINT') 
    skip_comments(fid);
    % For POINT layout, we support only nodal data.
    assert( all(var_location=='n'));

    % Permute if datapacking is POINT
    buf = fscanf(fid, '%g', [nvar,nv]);
    xs = buf(1:3,:)';

    ii = 4;
    while ii<=nvar
        % Read in other variables
        var = var_list{ii}; start=ii; ncol = 1;

        if ~isempty(regexp(var, '-[0-9]+', 'match'))
            var = regexprep(var, '-[0-9]+', '');
            ii=ii+1;
            pat = [var '-[0-9]+'];
            while ii<=nvar && ~isempty(regexp(var_list{ii}, pat, 'match'))
                ncol = ncol+1; ii=ii+1;
            end
        else
            ii = ii+1;
        end

        if nargin<2 || match_name( var, node_var_list)
            var_nodes.(var) = buf (start:ii-1,:)';
        end
    end
else
    xs = zeros(nv,3);
    ii = 1;
    while ii<=nvar
        skip_comments(fid);
        if ii<=3
            xs(:,ii) = fscanf(fid, '%g', nv); ii = ii+1;
        else
            % Read in other variables
            var = var_list{ii};
            ncol = 1; loc = var_location(ii);

            if ~isempty(regexp(var, '-[0-9]+$', 'match'))
                var = regexprep(var, '-[0-9]+$', '');
                ii=ii+1;
                pat = [var '-[0-9]+$'];
                while ii<=nvar && ~isempty(regexp(var_list{ii}, pat, 'match'))
                    ncol = ncol+1; ii=ii+1;
                end
            else
                ii = ii+1;
            end

            if loc=='n'
                if nargout>3 && (nargin<2 || match_name( var, node_var_list))
                    var_nodes.(var) = fscanf(fid, '%g', [nv, ncol]);
                else
                    fscanf(fid, '%*g', [nv, ncol]);
                end
            else
                if nargout>4 && (nargin<3 || match_name( var, elem_var_list))
                    var_elems.(var) = fscanf(fid, '%g', [ne, ncol]);
                else
                    fscanf(fid, '%*g', [ne, ncol]);
                end
            end
        end
    end
end

% Read in connectivity
elems = read_connectivity(fid, type, ne);

fclose( fid);

if nargout>3 && ~exist('var_nodes','var'); var_nodes=[]; end
if nargout>4 && ~exist('var_elems','var'); var_elems=[]; end

end

function s = get_nextline(fid)
% Get nextline and skip empty-lines and comments
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
    s = fgetl(fid);
end
end

function s = skip_comments(fid)
% Skip comments
pos = ftell(fid);
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#')
    pos = ftell(fid);
    s = fgetl(fid);
end
%Rewind
fseek(fid, pos, -1);
end

function [var_list,s] = obtain_varlist(fid,s)
var_list = {};
% Collect variable names
assert( ~feof(fid));

nvar = 0;
while true
    [var,s] = strtok(s, '= ,');

    if var(1)=='"' && var(end)~='"'
        ind = strfind(s,'"');
        if isempty(ind)
            error('Mismatched quote');
        else
            var = [var, s(1:ind(1))]; %#ok<AGROW>
            s = s(ind+1:end);
        end
    
    elseif strcmpi(var,'ZONE')
        break;
    end
    if(~strcmpi(var,'DATASETAUXDATA'))
      nvar = nvar + 1;
      if var(1)=='"'
        var_list{nvar} = var(2:end-1); %#ok<AGROW>
      else
        var_list{nvar} = var; %#ok<AGROW>
      end
    else
      s = get_nextline(fid);  
    end

    if isempty(s)
        s = get_nextline(fid);
        if strcmpi(strtok(s), 'ZONE')
            s = s(5:end);
            break;
        end
    elseif s(1)==','
        s = s(2:end);
    end
end
end

function elems = read_connectivity(fid, type, ne)
% Read in connectivity
switch type
    case 'TRIANGLE'
        nvpe = 3;
    case {'QUADRILATERAL','TETRAHEDRON'}
        nvpe = 4;
    case 'BRICK'
        nvpe = 8;
    otherwise
        error('Unsupported element type');
end

skip_comments(fid);
elems = fscanf(fid, '%d', [nvpe,ne]);
elems = elems';
end

function b = match_name( var, inplist)
% Determine whether variable matches input
if isempty(inplist)
    b=1; return;
end

if ischar(inplist)
    b = ~isempty(regexp(var,inplist,'match'));
else
    b = 0;
    assert(iscell(inplist));
    for ii=1:length(inplist)
        if strcmp(var,inplist{ii}); b = 1; return; end
    end
end
end

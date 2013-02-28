function [xs, elems, type, var_nodes, var_elems] = ...
    readucd_unstr(filename, node_var_list, elems_var_list)
%READUCD_UNSTR Read in an ASCII Unstructured Cell Data file.
%
% [XS,ELEMS,TYPE,VAR_NODES,VAR_ELEMS] = READUCD_UNSTR(FILENAME, ...
% NODE_VAR_LIST,ELEMS_VAR_LIST) Reads an Unstructured Cell Data (UCD) file
% FILENAME, provided a list of node variables NODE_VAR_LIST, and a list of
% element variables ELEMS_VAR_LIST.  NODE_VAR_LIST, if present, is a cell
% structure containing the list of nodal variables to be read. If not
% present, then all nodal variables are read.  ELEM_VAR_LIST is analogous
% to NODE_VAR_LIST but is for elemental values..
%
% NOTE: Though the filetype is UCD, the file extension is ".inp".
%
% The output arguments are the coordinates of points in an nx3 matrix XS,
% a list of the elements in a mx2, mx3, mx4, or mx8 matrix ELEMS, the type
% of elements TYPE, the node variables VAR_NODES, and the element variables
% VAR_ELEMS.
%
% See also WRITEUCD_UNSTR

% Allow an alternative amount of inputs
switch nargin
    case 1
        node_var_list = [];
        elems_var_list = [];
    case 2
        elems_var_list = [];
    case 3
        % Do nothing
    otherwise
        error('Not a valid amount of inputs')
end

% Skip header until the beginning of section 1
fid = fopen(filename, 'r');

%check if file was opened
if (fid == -1)
    filename = ['can not open the file ' filename];
    error(filename);
end

% Obtain number of - xs, elems, node vars, and elem vars
s = get_nextline(fid);
parameters = sscanf(s, '%d', [1,5]);
n_xs = parameters(1);
n_elems = parameters(2);
n_nv = parameters(3);
n_ev = parameters(4);
% num_mdata = parameters(5);

% Read in coordinates
xs = zeros(n_xs,3);

s = get_nextline(fid);
tmp = sscanf(s, '%f');
n = length(tmp);
xs(1,:) = tmp(2:4);

[nodest,count] = fscanf(fid, '%g', [n,n_xs-1]);
if (count ~= (n_xs-1)*n)
    error('Error in nodal coordinates.');
end
xs(2:end,:) = nodest(2:4,:)';

% Read in elems
if(n_elems==0);return;end;
s = get_nextline(fid);
type = regexp(s, '[a-zA-Z]+', 'match'); type=type{1};
[npe,dim] = type2num(type);
n = length(regexp(s, '[0-9]+', 'match'));
if n~=npe+2
    error('Problem in the number of vertices per element.');
end

pat = ['%*d %*d %*s ' repmat('%d ',1,npe)];
elem1 = sscanf(s, pat);
% Read in connectivity
[elems,count] = fscanf(fid, pat, [npe,n_elems-1]);
if count == (n_elems-1)*npe
    % Regular mesh
    elems = [elem1'; elems'];
else
    % Likely a mixed mesh. Must read in differently. To be implemented.
    error('Error in element connectivity.');
end

% Read in nodal values
var_nodes = read_fields( fid, n_nv, n_xs, node_var_list);

% Read in facial values
var_elems = read_fields( fid, n_ev, n_elems, elems_var_list);

fclose(fid);

% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='#' || s(1)==13)
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

function [num,dim] = type2num(str_type)
%     Line line
%     Triangle tri
%     Quadrilateral quad
%     Hexahedron hex
%     Prism prism
%     Tetrahedron tet
%     Pyramid pyr
%     Point pt
if (strcmpi(str_type,'line'))
    num = 2; dim=1;
elseif (strcmpi(str_type,'tri'))
    num = 3; dim=2;
elseif (strcmpi(str_type,'quad'))
    num = 4; dim=2;
elseif (strcmpi(str_type,'hex'))
    num = 8; dim=3;
elseif (strcmpi(str_type,'prism'))
    num = 6; dim=3;
elseif (strcmpi(str_type,'tet'))
    num = 4; dim=3;
elseif (strcmpi(str_type,'pyr'))
    num = 5; dim=3;
elseif (strcmpi(str_type,'pt'))
    num = 1; dim=0;
else
    error(['unknown cell type ' str_type]);
end

function vars = read_fields( fid, nv, nrows, in_var_list)

vars = [];
if nv==0; return; end

% Read in fields of a structure
var_lengths_mat = fscanf(fid, '%d',[1,nv+1]);

if var_lengths_mat(1) ~= nv
    error('Wrong specification of variables');
end
%
ncol = sum(var_lengths_mat(2:end));

var_list = cell(nv,1);
var_units = cell(nv,1);

%
for ii = 1:nv
    s = get_nextline(fid);
    [var_list{ii},s] = strtok(s,'= ,'); %#ok<*STTOK>
    var_units{ii} = strtok(s,'= ,');
end

% Merge columns of fields into a single matrix
buf = fscanf(fid, ['%*d ' repmat('%g ',1,ncol)], [ncol,nrows])';

start = 1;
for kk=1:nv
    if match_name( var_list{kk}, in_var_list)
        vars.(var_list{kk}) = buf(:,start:start+var_lengths_mat(kk+1)-1);
        
        % use unit to determine whether field is integer or single-precision
        switch var_units{kk}
            case {'int','int32','integer'}
                vars.(var_list{kk}) = int32(buf(:,start:start+var_lengths_mat(kk+1)-1));
            case {'single','real'}
                vars.(var_list{kk}) = single(buf(:,start:start+var_lengths_mat(kk+1)-1));
            otherwise
                vars.(var_list{kk}) = buf(:,start:start+var_lengths_mat(kk+1)-1);
        end
    end
    start = start+var_lengths_mat(kk+1);
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

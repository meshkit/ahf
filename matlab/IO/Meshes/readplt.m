function [xs, elems, type] = readplt(filename)
%READPLT: Read in an ASCII Tecplot file
% Input: file name
% Output: Coordinates of points (nx3), list of elements (mx4 or mx3),
% and element type.
% NOTE: It only supports Tecplot files with nodal data, and it reads 
%       in only the coordinates and mesh connectivity.

% Skip header until the 'VARIABLE' or 'ZONE' keyword
fid = fopen(filename, 'r');
s = get_nextline(fid);

[t,s] = strtok(s,' =');
while ~strcmpi(t,'VARIABLES') && ~strcmpi(t,'ZONE') && ~feof(fid)
    s = get_nextline(fid);
    [t,s] = strtok(s,'= ,');
end

if strcmpi(t,'VARIABLES')
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
                var = [var, s(1:ind(1))];
                s = s(ind+1:end);
            end
        elseif strcmpi(var,'ZONE')
            break;
        end
        nvar = nvar + 1;

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
else
    nvar = 3;
end

% Find 'N=', 'Nodes=', 'NODES=', 'E=', 'Elements=', 'ELEMENTS=', 'ET=', and
% 'ZONETYPE=', 'DATAPACKING', 'F'
nv = 0; ne = 0; type=''; packing='POINT';
while true
    [tok,s] = strtok( s, '= ');
    [val,s] = strtok( s(2:end), ' ,');
    if val(1)=='"' && val(end)~='"'
        ind = strfind(s,'"');
        if isempty(ind)
            error('Mismatched quote');
        else
            val = [val, s(1:ind)];
            s = s(ind+1:end);
        end
    elseif val(1)=='('
        ind = strfind(s,')');
        if isempty(ind)
            error('Mismatched parenthasis');
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

% Read in coordinates
if strcmpi(packing, 'POINT')
    skip_comments(fid);

    % Permute if datapacking is POINT
    xs = fscanf(fid, '%g', [nvar,nv]);
    xs = xs(1:3,:)';
else
    xs = zeros(nv,3);
    for ii=1:nvar
        skip_comments(fid);
        if ii<=3
            xs(:,ii) = fscanf(fid, '%g', nv);
        else
            fscanf(fid, '%*g', nv);
        end
    end
end

% Read in connectivity
switch type
    case 'TRIANGLE'
        nvpe = 3;
    case {'QUADRILATERAL','TETRAHEDRON'}
        nvpe = 4;
end

skip_comments(fid);
elems = fscanf(fid, '%d', [nvpe,ne]);
elems = elems';

fclose( fid);
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

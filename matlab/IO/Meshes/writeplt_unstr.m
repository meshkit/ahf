function writeplt_unstr( fname_plt, xs, elems, type, var_nodes, var_faces)
% Write out file in ASCII Tecplot format.
% WRITEPLT_UNSTR( fname_plt, xs, elems, 'triangle', var_nodes, var_faces).
%
% Arguments:
% FILENAME is a character string, specifying the output file.
% XS is nx3 array containing nodal coordinates
% ELEMS is mx3 or mx4, containing element connectivity
% TYPE specifies element type, which is used only to resolve ambiguities
%    different of element types.
% VAR_NODES is a structure containing nodal values to be written out.
% VAR_ELEMS is a structure containing elemental values to be written out.
%
% Note that a field in VAR_NODES can be an nxd array, where d>1.
% In this case, each column will be written out as an individual variable
% name with variable name "<fieldname>-<column>" (e.g., "disp-1").
%
% See also readplt.
%
% Example
%     var_nodes.vdisp = disp;
%     var_nodes.vnrms = vnrms;
%     var_faces.fnrms = fnrms;
%     writeplt( 'test.plt', xs, elems, '', var_nodes, var_faces);
%     writeplt( 'test.plt', xs, elems, '', var_nodes);
%     writeplt( 'test.plt', xs, elems, '', [], var_faces);

nv = size( xs,1);

nvpe = size(elems, 2);
if nvpe==1
    [elems_buf, elems_type] = split_mixed_elems( elems);
    if isempty(elems_type)
        % There is actually only one type of elements
        elems = elems_buf;
        nelem = size(elems,1);
        nvpe = size(elems,2);
    else
        nelem = size(elems_type,1);
    end
else
    nelem = size(elems, 1);
end

% Write out in Tecplot format
fid = fopen(fname_plt, 'Wt');

% Write out header
fprintf(fid, 'TITLE="%s"\n', fname_plt);
fprintf(fid, 'VARIABLES= "x" "y" "z"');

if nargin>=5 && ~isempty(var_nodes)
    assert(isstruct(var_nodes));
    varlist_nodes = write_varlist( fid, var_nodes);
else
    varlist_nodes = {};
end
if nargin>=6  && ~isempty(var_faces)
    assert(isstruct(var_faces));
    varlist_faces = write_varlist( fid, var_faces);
else
    varlist_faces = {};
end

switch size(elems,2)
    case 1
        if min(elems_type)==3
            type = 'QUADRILATERAL'; % Write 2-D mixed elements as quadrilaterals
            dim = 2;
        else
            type = 'BRICK'; % Write 3-D mixed elements as bricks
            dim = 3;
        end
    case 2
        type = 'LINESEG';
        dim = 1;
    case 3
        type = 'TRIANGLE';
        dim = 2;
    case 4
        if nargin>=4 && ~isempty(type) && (type(1)=='Q' || type(1)=='q' ) || ...
                (nargin<4 || isempty(type)) && is_2dmesh_mex( size(xs,1), elems)
            type = 'QUADRILATERAL';
            dim = 2;
            
            % If fourth vertex ID is zero for any element, change to ID of
            % third vertex.
            empty = elems(:,4)==0;
            if any(empty)
                elems(empty,4)=elems(empty,3);
            end
        else
            dim = 3;
            type = 'TETRAHEDRON';
        end
    case 8
        dim = 3;
        type = 'BRICK';
    otherwise
        error('Unknown element type');
end

%fprintf(fid, '\nZONE T="00001", NODES=%d, ELEMENTS=%d, ZONETYPE=FE%s,...
%       DATAPACKING=BLOCK', nv, nelem, type);
fprintf(fid, '\nZONE T="00001", N=%d, E=%d, ET=%s, F=FEBLOCK', nv, nelem, type);

if ~isempty(varlist_faces) % Print out VARLOCATION
    fprintf(fid, ', VARLOCATION=([');
    
    if ~isempty(varlist_nodes)
        offset = 3+length(varlist_nodes);
    else
        offset = 3;
    end
    
    fprintf(fid, '%d', offset+1);
    for ii=2:length(varlist_faces)
        fprintf(fid, ',%d', offset+ii);
    end
    fprintf(fid, ']=CELLCENTERED)');
end

% Print out coordinates
fprintf(fid, '\n%g %g %g %g %g %g %g %g', xs);
% Print out nodal values
if ~isempty(varlist_nodes)
    write_values( fid, var_nodes);
end
% Print out elemental values
if ~isempty(varlist_faces)
    write_values( fid, var_faces);
end

if nvpe>1
    fprintf(fid, ['\n%d' repmat(' %d', 1, size(elems,2)-1)], elems');
    fprintf(fid, '\n');
elseif dim==2
    elems = zeros(nelem, 4,'int32');
    offset = 1;
    for i=1:nelem
        if elems_type(i)==3 % Triangle
            elems(i,1:3)= elems_buf(offset:offset+2);
            elems(i,4)= elems_buf(offset+2);
        elseif elems_type(i)==4 % Quadritalteral
            elems(i,:)= elems_buf(offset:offset+3);
        else
            error('Unsupported element type');
        end
        
        offset = offset+elems_type(i);
    end
    assert(offset==length(elems_buf)+1);
    
    fprintf(fid, ['\n%d' repmat(' %d', 1, 3)], elems');
    fprintf(fid, '\n');
else
    assert(dim==3);
    elems = zeros(nelem, 8,'int32');
    offset = 1;
    for i=1:nelem
        if elems_type(i)==4 % Tet
            elems(i,1:3)= elems_buf(offset:offset+2);
            elems(i,4)= elems_buf(offset+2);
            elems(i,5:8) = elems_buf(offset+3);
        elseif elems_type(i)==5 % Pyramid
            elems(i,1:4)= elems_buf(offset:offset+3);
            elems(i,5:7) = elems_buf(offset+4);
        elseif elems_type(i)==6 % Prism
            elems(i,1:3)= elems_buf(offset:offset+2);
            elems(i,5:7) = elems_buf(offset+3:offset+5);
            
            elems(i,4)= elems_buf(offset+2);
            elems(i,8) = elems_buf(offset+5);
        elseif elems_type(i)==8 % Hex
            elems(i,:)= elems_buf(offset:offset+7);
        else
            error('Unsupported element type');
        end
        
        offset = offset+elems_type(i);
    end
    assert(offset==length(elems_buf)+1);
    
    fprintf(fid, ['\n%d' repmat(' %d', 1, 7)], elems');
    fprintf(fid, '\n');
end

fclose( fid);
end

function varlist = write_varlist( fid, struct)
% Subfunction for writing out list of variable names.
fldlist = fieldnames(struct);
varlist = fldlist;

% Write out list of variable names
c = 1;
for ii=1:length(fldlist)
    ncol = size(struct.(fldlist{ii}),2);
    if ncol==1
        varlist{c} = fldlist{ii};
        fprintf(fid, ', "%s"', varlist{c});  c = c+1;
    else
        for jj=1:ncol
            % Store variable as var-<jj>
            varlist{c} = sprintf('%s-%d', fldlist{ii}, jj);
            fprintf(fid, ', "%s"', varlist{c}); c = c+1;
        end
    end
end
end

function write_values( fid, struct)
% Subfunction for writing out variables contained within a structure.

fldlist = fieldnames(struct);

% Write out list of variables
for ii=1:length(fldlist)
    fprintf(fid, ['\n%g' repmat(' %g', 1, 7)], struct.(fldlist{ii}));
end
end

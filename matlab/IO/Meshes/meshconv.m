function meshconv( infname, outfname)
%MESHCONV    Convert unstrcutured mesh file from one format into another.
%
% meshconv( infname, outfname)
%
% Example:
%    meshconv( 'infile.cgns', 'outfile.plt')
%
% Currently supported file formats include
%    CGNS        (.cgns or .cgn)
%    UCD/AVS     (.avs or .inp)
%    Tecplot     (.plt or .dat)
%    Legacy VTK  (.vtk)
%    GMV         (.gmv or .gmvb)
%
% In addition, partial support for the following file formats:
%    OFF         (.off. Surface mesh only).
%    Neutral     (.neu. Mesh only)

outsuffix = outfname(end-2:end);
if ~(strcmp(outsuffix,'avs') || strcmp(outsuffix,'inp') || ...
        strcmp(outsuffix,'gmv') || strcmp(outsuffix,'mvb') || ...
        strcmp(outsuffix,'gmb') || strcmp(outsuffix,'off') || ...
        strcmp(outsuffix,'vtk') || strcmp(outsuffix,'plt') || ...
        strcmp(outsuffix,'gns') || strcmp(outsuffix,'cgn'))
    error(['Unsupported output format ' outsuffix]);
end

% Invoke reader.
insuffix = infname(end-2:end);
typestr=''; var_nodes=[]; var_cells=[];
try
    switch insuffix
        case {'cgn','gns'}
            [ps,elems, typestr, var_nodes, var_cells] = readcgns_unstr(infname);
        case {'avs','inp'}
            [ps,elems, typestr, var_nodes, var_cells] = readucd_unstr(infname);
        case {'plt','dat'}
            [ps,elems, typestr, var_nodes, var_cells] = readplt_unstr(infname);
        case 'vtk'
            [ps,elems, typestr, var_nodes, var_cells] = readvtk_unstr(infname);
            
            % Only the mesh itself is supported for the following of files
        case 'neu'
            [ps,elems] = readneu(infname);
        case 'off'
            [ps,elems] = readoff(infname);
        otherwise
            error('Unsupported input format.');
    end
catch %#ok<CTCH>
    error(['Error occured when reading file ' infname ': ' lasterr]); %#ok<LERR>
end

% Invoke writer.
try
    switch outsuffix
        case {'cgn','gns'}
            writecgns_unstr(outfname,ps,elems,typestr, var_nodes, var_cells);
        case {'avs','inp'}
            if(strcmp(insuffix,'cgn') || strcmp(insuffix,'gns') )
                switch typestr
                    case {'TETRA_4'}
                        typestr='tet';
                end
            end
            writeucd_unstr(outfname,ps,elems,typestr, var_nodes, var_cells);
        case {'plt','dat'}
            writeplt_unstr(outfname,ps,elems,typestr, var_nodes, var_cells);
        case {'vtk'}
            writevtk_unstr(outfname,ps,elems,typestr, var_nodes, var_cells);
        case {'gmv','gmb','mvb'}
            writegmv_unstr(outfname,ps,elems,typestr, var_nodes, var_cells);
            
            % Only the mesh itself is supported for the following of files
        case 'off'
            if ~isempty(var_nodes) || ~isempty(var_cells)
                warning('Omitting field variables in input file.'); %#ok<WNTAG>
            end
            writeoff(outfname,ps,elems);
        otherwise
            error('Unsupported output format');
    end
catch %#ok<CTCH>
    error(['Error occured when writing file ' outfname]);
end

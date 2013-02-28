function writevtk( dataset, fname_vtk, descript, n_xs, xs, n_elems, ...
    elems, dim, datatype, orig, spac, x_coord, y_coord, z_coord)
%WRITEVTK Write a VTK File
% WRITEVTK(DATASET,FNAME_VTK,DESCRIPT,N_XS,XS,N_ELEMS,ELEMS,DIM, ...
% DATATYPE,ORIG,SPAC,X_COORD,Y_COORD,Z_COORD) Writes a VTK File, provided 
% inputs described below.  Depending on the provided dataset DATASET, 
% different inputs will be ignored, according to what is required to write 
% that type of dataset.  Possible dataset inputs are 'STRUCTURED_POINTS', 
% 'STRUCTURED_GRID', 'RECTILINEAR_GRID', 'POLYDATA' and 'UNSTRUCTURED_GRID' 
% (all letters must be capitalized).  Required inputs for each type of 
% dataset are also shown below.  Note: This is for ASCII Legacy format 
% only, datafile version 3.0.
%
% INPUT TYPES:
% Name:     Format:                       Info:
% DATASET   (string)                      The type of dataset used.
% FNAME_VTK (string)                      Name of VTK file to be written.
% DESCRIPT  (string)                      Description of plot.
% N_XS      (1 x 1)                       Number of vertices.
% XS        (N x 3)                       Rows are vertice coordinates.
% N_ELEMS   (1 x 1)                       Number of polygons.
% ELEMS     (N_ELEMS x {max. elem length})Connectivity matrix for polygons.
% DATATYPE  (string)                      The type of data stored.
% DIM       (3 x 1)                       Dimensions of x,y,z (integer).
% ORIG      (3 x 1)                       Origin coordinates (double).
% SPAC      (3 x 1)                       Spacing of vertices (double).
% X_COORD   (DIM(1,1) x 1)                x-coordinates of vertices.
% Y_COORD   (DIM(2,1) x 1)                y-coordinates of vertices.
% Z_COORD   (DIM(3,1) x 1)                z-coordinates of vertices.
%
% REQUIRED INPUTS PENDING ON DATASET TYPE:
%
% WRITEVTK('STRUCTURED_POINTS',FNAME_VTK,DESCRIPT,0,0,0,0,DIM,0,ORIG, ...
% SPAC,0,0,0) Writes VTK File with Structured Points format.  
%
% WRITEVTK('STRUCTURED_GRID',FNAME_VTK,DESCRIPT,N_XS,XS,0,0,DIM, ...
% DATATYPE,0,0,0,0,0) Writes VTK File with Structured Grid format.   
%
% WRITEVTK('RECTILINEAR_GRID',FNAME_VTK,DESCRIPT,0,0,0,0,DIM,DATATYPE, ...
% 0,0,X_COORD,Y_COORD,Z_COORD) Writes VTK File with Rectilinear grid
% format.  
% 
% WRITEVTK('POLYDATA',FNAME_VTK,DESCRIPT,N_XS,XS,N_ELEMS,ELEMS,0, ...
% DATATYPE,0,0,0,0,0) Writes VTK File with Polydata format.
%
% WRITEVTK('UNSTRUCTURED_GRID',FNAME_VTK,DESCRIPT,N_XS,XS,N_ELEMS,ELEMS ...
% 0,DATATYPE,0,0,0,0,0) Writes VTK File with Unstructured Grid format.
%
% See also READVTK

% Write out in VTK format
% Write out header
fid = fopen(fname_vtk, 'w');
fprintf(fid, '# vtk DataFile Version 3.0\n');
fprintf(fid, '%s\n', descript);
fprintf(fid, 'ASCII\n');

% Write out remaining VTK File pending on dataset type
switch dataset
    case 'STRUCTURED_POINTS'
        % Write out header
        fprintf(fid, 'DATASET %s\n', dataset);
        fprintf(fid, 'DIMENSIONS %i %i %i\n', dim(1), dim(2), dim(3));
        fprintf(fid, 'ORIGIN %d %d %d\n', orig(1), orig(2), orig(3));
        fprintf(fid, 'SPACING %d %d %d\n', spac(1), spac(2), spac(3));

    case 'STRUCTURED_GRID'
        % Write out header
        fprintf(fid, 'DATASET %s\n', dataset);
        fprintf(fid, 'DIMENSIONS %i %i %i\n', dim(1), dim(2), dim(3));
        fprintf(fid, 'POINTS %i %s', n_xs, datatype);

        % Write out vertices
        for i = 1:n_xs
            fprintf(fid, '\n%d %d %d', xs(i,1), xs(i,2), xs(i,3));
        end

    case 'RECTILINEAR_GRID'
        % Write out header
        fprintf(fid, 'DATASET %s\n', dataset);
        fprintf(fid, 'DIMENSIONS %i %i %i\n', dim(1), dim(2), dim(3));

        % Write out vertices
        fprintf(fid, 'X_COORDINATES %i %s\n', dim(1), datatype);
        for i = 1:dim(1)
            fprintf(fid, '%d ', x_coord(i));
        end
        fprintf(fid, '\nY_COORDINATES %i %s\n', dim(2), datatype);
        for i = 1:dim(2)
            fprintf(fid, '%d ', y_coord(i));
        end
        fprintf(fid, '\nZ_COORDINATES %i %s\n', dim(3), datatype);
        for i = 1:dim(3)
            fprintf(fid, '%d ', z_coord(i));
        end

    case 'POLYDATA' %Assumes polygons are of all the same type
        % Write out header
        fprintf(fid, 'DATASET %s\n', dataset);
        fprintf(fid, 'POINTS %i %s', n_xs, datatype);
        
        % Write out vertices
        for i = 1:n_xs
            fprintf(fid, '\n%d %d %d', xs(i,1), xs(i,2), xs(i,3));
        end
        
        % Write out connectivity header
        fprintf(fid, '\nPOLYGONS %i %i', n_elems, (size(elems,1))*(1+size(elems,2)));
        
        % Write out connectivity of vertices
        for i = 1:n_elems
            fprintf(fid, '\n%i', size(elems,2));
            for j = 1:(size(elems,2))
                fprintf(fid, ' %i', elems(i,j));
            end
        end
        
    case 'UNSTRUCTURED_GRID' % NEEDS MORE DEBUGGING AND MODIFICATIONS
        % Write out header
        fprintf(fid, 'DATASET %s\n', dataset);
        fprintf(fid, 'POINTS %i %s', n_xs, datatype);
        
        % Write out vertices
        for i = 1:n_xs
            fprintf(fid, '\n%d %d %d', xs(i,1), xs(i,2), xs(i,3));
        end
        
        % Write out connectivity header
        fprintf(fid, '\n\nCELLS %i %i', n_elems, size(elems,1)*(1+size(elems,2)));
        
        % Write out connectivity of vertices
        for i = 1:n_elems
            fprintf(fid, '\n%i', size(elems,2));
            for j = 1:(size(elems,2))
                fprintf(fid, ' %i', elems(i,j));
            end
        end
        
        % Write out cell types
        fprintf(fid, '\n\nCELL_TYPES %i', n_elems);
        switch size(elems,2)
            case 3
                for i = 1:n_elems
                    fprintf(fid, '\n%i', 5);
                end
            case 4
                for i = 1:n_elems
                    fprintf(fid, '\n%i', 9);
                end
        end
end
end
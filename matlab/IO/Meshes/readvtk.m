function [xs, elem, dataset_type] = readvtk(filename)
%READVTK Read in an ASCII Visualization Toolkit file
% [XS,ELEM,DATASET_TYPE]=READVTK(FILENAME) Reads Visualization Toolkit file
% FILENAME and outputs the coordinates of points in an nx3 matrix XS, a
% list of the elements in a mx4 or mx3 matrix ELEMS and the type of
% element TYPE.  It only supports VTK files that are Legacy ASCII format.
%
% See also WRITEVTK

% Skip header until the 'DATASET' keyword
fid = fopen(filename, 'r');
s = fgetl(fid);

[t,s] = strtok(s);
while ~strcmpi(t,'DATASET') && ~feof(fid)
    s = fgetl(fid);
    [t,s] = strtok(s);
end

dataset_type = 'No data set given';
%elem = 'N/A - this is not a mesh';

if strcmpi(t,'DATASET')
    assert( ~feof(fid));
    [t,s] = strtok(s);
    dataset_type = t;
    
    % Read dataset format pending on type
    switch t
        case 'STRUCTURED_POINTS'
            % We find dimensions, origin and spacing for our structured points

            % Collect dimensions DIM
            while ~strcmpi(t,'DIMENSIONS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'DIMENSIONS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                dim = ones(3,1);
                for i = 1:3
                    dim(i,:) = str2double(t);
                    [t,s] = strtok(s);
                end
            end

            % Find origin ORIGIN
            while ~strcmpi(t,'ORIGIN') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'ORIGIN')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                origin = zeros(3,1);
                for i = 1:3
                    origin(i,:) = str2double(t);
                    [t,s] = strtok(s);
                end
            end
            
            % Find spacing SPAC
            while ~strcmpi(t,'SPACING') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'SPACING')
                [t,s] = strtok(s);
                spac = ones(3,1);
                for i = 1:3
                    spac(i,:) = str2double(t);
                    [t,s] = strtok(s);
                end
            end

            % Find x-coordinates
            x_coords = zeros(dim(1),1);
            for i = 1:dim(1)
                x_coords(i,1) = x_coords(i,1) + (i-1)*spac(1);
            end

            % Find y-coordinates
            y_coords = zeros(dim(2),1);
            for i = 1:dim(2)
                y_coords(i,1) = y_coords(i,1) + (i-1)*spac(2);
            end

            % Find x-coordinates
            z_coords = zeros(dim(3),1);
            for i = 1:dim(3)
                z_coords(i,1) = z_coords(i,1) + (i-1)*spac(3);
            end

            % Find vertices XS
            xs = zeros((dim(1)*dim(2)*dim(3)),3);
            count = 1;
            for i = 1:dim(1)
                for j = 1:dim(2)
                    for k = 1:dim(3)
                        xs(count,:) = [x_coords(i,1) y_coords(j,1) z_coords(k,1)];
                        count = count +1;
                    end
                end
            end

        case 'STRUCTURED_GRID'
            % We find dimensions and points

            % Collect dimensions DIM
            while ~strcmpi(t,'DIMENSIONS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'DIMENSIONS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                dim = ones(3,1);
                for i = 1:3
                    dim(i,:) = str2double(t);
                    [t,s] = strtok(s);
                end
            end

            % Find number of points NUM_PTS and datatype DATATYPE
            while ~strcmpi(t,'POINTS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'POINTS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                num_pts = str2double(t);
                [t,s] = strtok(s);
                datatype = t;

                %Find vertices XS
                xs = zeros(num_pts,3);
                for i = 1:num_pts
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    xs(i,1) = str2double(t);
                    [t,s] = strtok(s);
                    xs(i,2) = str2double(t);
                    [t,s] = strtok(s);
                    xs(i,3) = str2double(t);
                end
            end


        case 'RECTILINEAR_GRID'
            % We find dimensions and points

            % Collect dimensions DIM
            s = fgetl(fid);
            [t,s] = strtok(s);
            
            while ~strcmpi(t,'DIMENSIONS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'DIMENSIONS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                dim = ones(3,1);
                for i = 1:3
                    dim(i,:) = str2double(t);
                    [t,s] = strtok(s);
                end
            end

            %Find vertices XS
            xs = zeros(max(dim),3);
            s = fgetl(fid);
            [t,s] = strtok(s);
            
            %Get x-coordinates
            while ~strcmpi(t,'X_COORDINATES') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end
            s = fgetl(fid);
            x_coords = zeros(dim(1),1);
            for i = 1:dim(1)
                [t,s] = strtok(s);
                x_coords(i,1) = str2double(t);
            end
            
            %Get y-coordinates
            while ~strcmpi(t,'Y_COORDINATES') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end
            s = fgetl(fid);
            y_coords = zeros(dim(2),1);
            for i = 1:dim(2)
                [t,s] = strtok(s);
                y_coords(i,1) = str2double(t);
            end
            
            %Get z-coordinates
            while ~strcmpi(t,'Z_COORDINATES') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end
            s = fgetl(fid);
            z_coords = zeros(dim(3),1);
            for i = 1:dim(3)
                [t,s] = strtok(s);
                z_coords(i,1) = str2double(t);
            end

            % Find vertices XS
            xs = zeros((dim(1)*dim(2)*dim(3)),3);
            count = 1;
            for i = 1:dim(1)
                for j = 1:dim(2)
                    for k = 1:dim(3)
                        xs(count,:) = [x_coords(i,1) y_coords(j,1) z_coords(k,1)];
                        count = count +1;
                    end
                end
            end

        case 'POLYDATA'
            % We find vertices, connectivity and datatype

            % Find number of points NUM_PTS and datatype DATATYPE
            s = fgetl(fid);
            [t,s] = strtok(s);
            while ~strcmpi(t,'POINTS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'POINTS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                num_pts = str2double(t);
                [t,s] = strtok(s);
                datatype = t;



                % Get vertices XS
                ts = fscanf(fid, '%g', [3,num_pts]);
                xs = ts';
            end

            % Find number of elements NUM_ELEM and size of matrix SIZE_MAT
            while ~strcmpi(t,'POLYGONS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'POLYGONS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                num_elem = str2double(t);
                [t,s] = strtok(s);
                size_mat = str2double(t);


                % Find connectivity of points, forming elements ELEM
                elem_length = (size_mat/num_elem)-1;
                elem = zeros(num_elem,elem_length, 'int32');

                for i = 1:num_elem
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    for j = 1:elem_length
                        [t,s] = strtok(s);
                        elem(i,j) = str2double(t);
                    end
                end
            end

        case 'UNSTRUCTURED_GRID'
            % We find vertices XS and connectivity ELEM

            % Find number of points NUM_PTS and datatype DATATYPE
            while ~strcmpi(t,'POINTS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'POINTS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                num_pts = str2double(t);
                [t,s] = strtok(s);
                datatype = t;

                xs = zeros(num_pts,3);
                for i = 1:num_pts
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    xs(i,1) = str2double(t);
                    [t,s] = strtok(s);
                    xs(i,2) = str2double(t);
                    [t,s] = strtok(s);
                    xs(i,3) = str2double(t);
                end
            end


            % Find number of cells NUM_CELL and number of cell points CELL_SIZE
            while ~strcmpi(t,'CELLS') && ~feof(fid)
                s = fgetl(fid);
                [t,s] = strtok(s);
            end

            if strcmpi(t,'CELLS')
                assert( ~feof(fid));

                [t,s] = strtok(s);
                num_cell = str2double(t);
                [t,s] = strtok(s);
                cell_size = str2double(t);
                
                % Find connectivity of points, forming polygons POLY
                elem = zeros(num_cell,(cell_size/num_cell)-1,'int32');
                for i = 1:num_cell
                    s = fgetl(fid);
                    [t,s] = strtok(s);
                    for j = 1:((cell_size/num_cell)-1)
                        [t,s] = strtok(s);
                        elem(i,j) = str2double(t)+1;
                    end
                end
            end
        case []
            error('No dataset type given');
    end
end
end
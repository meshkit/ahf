function nc_add_recs ( ncfile, new_data, varargin )
% NC_ADD_RECS:  add records onto the end of a netcdf file
%
% USAGE:  nc_add_recs ( ncfile, new_data, unlimited_dimension );
% 
% INPUT:
%   ncfile:  netcdf file
%   new_data:  Matlab structure.  Each field is a data array
%      to be written to the netcdf file.  Each array had
%      better be the same length.  All arrays are written
%      in the same fashion.
%   unlimited_dimension:
%      Optional.  Name of the unlimited dimension along which the data 
%      is written.  If not provided, we query for the first unlimited 
%      dimension (looking ahead to HDF5/NetCDF4).
%     
% OUTPUT:
%   None.  In case of an error, an exception is thrown.
%
% AUTHOR: 
%   johnevans@acm.org
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_add_recs.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nargchk(2,3,nargin);


%
% Check that we were given good inputs.
if ~isstruct ( new_data )
    err_id = 'SNCTOOLS:NC_ADD_RECS:badStruct';
    error ( err_id, '2nd input argument must be a structure .\n' );
end

%
% Check that each field of the structure has the same length.
varnames = fieldnames ( new_data );
num_fields = length(varnames);
if ( num_fields <= 0 )
    err_id = 'SNCTOOLS:NC_ADD_RECS:badRecord';
    error ( err_id, 'data record cannot be empty' );
end
field_length = zeros(num_fields,1);
for j = 1:num_fields

    v = nc_getvarinfo(ncfile,varnames{j});

    if getpref('SNCTOOLS','PRESERVE_FVD',false) 

        if numel(v.Size) == 1
            % netCDF variable is 1D
            field_length(j) = numel(new_data.(varnames{j}));
        elseif (numel(v.Size) == 2) 
            % netCDF variable is 2D
            field_length(j) = size(new_data.(varnames{j}),2);
        elseif (numel(v.Size) > 2) && (numel(v.Size) == (ndims(new_data.(varnames{j})) + 1))
            % netCDF variable is more than 2D, but we're given just one record.
            field_length(j) = 1;
        else
            % netCDF variable is n-D
            n = ndims(new_data.(varnames{j}));
            command = sprintf ( 'field_length(j) = size(new_data.%s,n);', varnames{j} );
            eval(command);
        end

    else
        if numel(v.Size) == 1
            % netCDF variable is 1D
            field_length(j) = numel(new_data.(varnames{j}));
        elseif (numel(v.Size) == 2) 
            % netCDF variable is 2D
            field_length(j) = size(new_data.(varnames{j}),1);
        elseif (numel(v.Size) > 2) && (numel(v.Size) == (ndims(new_data.(varnames{j})) + 1))
            % netCDF variable is more than 2D, but we're given just one record.
            field_length(j) = 1;
        else
            % netCDF variable is n-D
            command = sprintf ( 'field_length(j) = size(new_data.%s,1);', varnames{j} );
            eval(command);
        end

    end
end
if any(diff(field_length))
    err_id = 'SNCTOOLS:NC_ADD_RECS:badFieldLengths';
    error ( err_id, 'Some of the fields do not have the same length.\n' );
end

%
% So we have this many records to write.
record_count = field_length(1);


[unlim_dimname, unlim_dimlen, unlim_dimid] = get_unlimdim_info ( ncfile, varargin{:} );

varsize = get_all_varsizes ( ncfile, new_data, unlim_dimid );


%
% So we start writing here.
record_corner = unlim_dimlen;



%
% write out each data field, as well as the minimum and maximum
input_variable = fieldnames ( new_data );
num_vars = length(input_variable);
for i = 1:num_vars

    current_var = input_variable{i};
    %fprintf ( 1, '%s:  processing %s...\n', mfilename, current_var );

    current_var_data = new_data.(current_var);
    var_buffer_size = size(current_var_data);

    netcdf_var_size = varsize.(current_var);

    corner = zeros( 1, length(netcdf_var_size) );
    count = netcdf_var_size;

    if getpref('SNCTOOLS','PRESERVE_FVD',false)
        % record dimension is last.
        corner(end) = record_corner;
        count(end) = record_count;
    else
        % Old school
        corner(1) = record_corner;
        count(1) = record_count;
    end



    %
    % Ok, we are finally ready to write some data.
    nc_varput ( ncfile, current_var, current_var_data, corner, count );
   

end


return









%--------------------------------------------------------------------------
function varsize = get_all_varsizes ( ncfile, new_data,unlimited_dimension_dimid )

switch ( version('-release') )
case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
    varsize = get_all_varsizes_mexnc(ncfile, new_data,unlimited_dimension_dimid);
otherwise
    varsize = get_all_varsizes_tmw(ncfile, new_data,unlimited_dimension_dimid);
end




%--------------------------------------------------------------------------
function varsize = get_all_varsizes_tmw ( ncfile, new_data,unlimited_dimension_dimid )

ncid=netcdf.open(ncfile, nc_nowrite_mode );


%
% For each field of "new_data" buffer, inquire as to the dimensions in the
% NetCDF file.  We need this data to properly tell nc_varput how to write
% the data
input_variable = fieldnames ( new_data );
num_vars = length(input_variable);
varsize = [];
for j = 1:num_vars

    varid = netcdf.inqVarID(ncid, input_variable{j} );
    [dud,dud,dimids,dud] = netcdf.inqVar(ncid, varid);
    ndims = length(dimids);
    dimsize = zeros(1,ndims);


    %
    % make sure that this variable is defined along the unlimited dimension.
    if ~any(find(dimids==unlimited_dimension_dimid))
        netcdf.close(ncid);
        format = 'variable %s must be defined along unlimited dimension %s.\n';
        error ( 'SNCTOOLS:NC_ADD_RECS:missingUnlimitedDimension', ...
                format, input_variable{j}, unlimited_dimension_name );
    end

    for k = 1:ndims
        [dud,dim_length] = netcdf.inqDim(ncid, dimids(k) );
        dimsize(k) = dim_length;
    end

    % R2008b reports in opposite order of C API
    if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
        dimsize = fliplr(dimsize);
    end
    varsize.(input_variable{j}) = dimsize;


end

netcdf.close(ncid);


%--------------------------------------------------------------------------
function varsize = get_all_varsizes_mexnc ( ncfile, new_data,unlimited_dimension_dimid )
[ncid,status ]=mexnc( 'open', ncfile, nc_nowrite_mode );
if status ~= 0
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_RECS:openFailed';
    error ( error_id, ncerr );
end



%
% For each field of "new_data" buffer, inquire as to the dimensions in the
% NetCDF file.  We need this data to properly tell nc_varput how to write
% the data
input_variable = fieldnames ( new_data );
num_vars = length(input_variable);
varsize = [];
for j = 1:num_vars

    [varid, status] = mexnc('INQ_VARID', ncid, input_variable{j} );
    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error_id = 'SNCTOOLS:NC_ADD_RECS:inq_varidFailed';
        error ( error_id, ncerr );
    end

    [dimids, status] = mexnc('INQ_VARDIMID', ncid, varid);
    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error_id = 'SNCTOOLS:NC_ADD_RECS:inq_vardimidFailed';
        error ( error_id, ncerr );
    end
    ndims = length(dimids);
    dimsize = zeros(1,ndims);


    %
    % make sure that this variable is defined along the unlimited dimension.
    if ~any(find(dimids==unlimited_dimension_dimid))
        mexnc('close',ncid);
        format = 'variable %s must be defined along unlimited dimension %s.\n';
        error ( 'SNCTOOLS:NC_ADD_RECS:missingUnlimitedDimension', ...
                format, input_variable{j}, unlimited_dimension_name );
    end

    for k = 1:ndims
        [dim_length, status] = mexnc('INQ_DIMLEN', ncid, dimids(k) );
        if ( status ~= 0 )
            mexnc('close',ncid);
            ncerr = mexnc ( 'strerror', status );
            error_id = 'SNCTOOLS:NC_ADD_RECS:inq_dimlenFailed';
            error ( error_id, ncerr );
        end
        dimsize(k) = dim_length;
    end

    % If we want to preserve the fastest varying dimension, then we
	% have to flip the dimensions.
    if getpref('SNCTOOLS','PRESERVE_FVD',false)
        dimsize = fliplr(dimsize);
    end
    varsize.(input_variable{j}) = dimsize;
    varsize.(input_variable{j}) = dimsize;

end

status = mexnc('close',ncid);
if status ~= 0 
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_RECS:closeFailed';
    error ( error_id, ncerr );
end
    






%--------------------------------------------------------------------------
function [dimname, dimlen, dimid] = get_unlimdim_info ( ncfile, varargin )

switch ( version('-release') )
case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
    [dimname, dimlen, dimid] = get_unlimdim_info_mexnc ( ncfile, varargin{:} );
otherwise
    [dimname, dimlen, dimid] = get_unlimdim_info_tmw ( ncfile, varargin{:} );
end



%--------------------------------------------------------------------------
function [dimname, dimlen, dimid] = get_unlimdim_info_tmw ( ncfile, varargin )
ncid=netcdf.open(ncfile, nc_nowrite_mode );


%
% If we were not given the name of an unlimited dimension, get it now
if nargin < 2
    [dud,dud,dud,dimid] = netcdf.inq(ncid );

    dimname = netcdf.inqDim(ncid, dimid );

    if dimid == -1
        error_id = 'SNCTOOLS:NC_ADD_RECS:noUnlimitedDimension';
        error ( error_id, '%s is missing an unlimited dimension, %s requires it', ncfile, mfilename );
    end

else
    
    dimname = varargin{1};
    dimid = netcdf.inqDimID(ncid, dimname );
    
end
    
[dud,dimlen] = netcdf.inqDim(ncid, dimid );
netcdf.close(ncid);

    
%--------------------------------------------------------------------------
function [dimname, dimlen, dimid] = get_unlimdim_info_mexnc ( ncfile, varargin )
[ncid,status ]=mexnc( 'open', ncfile, nc_nowrite_mode );
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ADD_RECS:openFailed', ncerr );
end



%
% If we were not given the name of an unlimited dimension, get it now
if nargin < 2
    [dimid, status] = mexnc ( 'inq_unlimdim', ncid );
    if status ~= 0
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_ADD_RECS:inq_unlimdimFailed', ncerr );
    end

    [dimname, status] = mexnc ( 'INQ_DIMNAME', ncid, dimid );
    if status ~= 0
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_ADD_RECS:inq_dimnameFailed', ncerr );
    end

    if dimid == -1
        error_id = 'SNCTOOLS:NC_ADD_RECS:noUnlimitedDimension';
        error ( error_id, '%s is missing an unlimited dimension, %s requires it', ncfile, mfilename );
    end


else
    
    dimname = varargin{1};
    [dimid, status] = mexnc ( 'inq_dimid', ncid, dimname );
    if status ~= 0
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error_id = 'SNCTOOLS:NC_ADD_RECS:inq_dimidFailed';
        error ( 'SNCTOOLS:NC_ADD_RECS:OPEN', ncerr );
    end
    
end
    
[dimlen, status] = mexnc ( 'INQ_DIMLEN', ncid, dimid );
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ADD_RECS:inq_dimlenFailed', ncerr );
end

status = mexnc('close',ncid);
if status ~= 0 
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ADD_RECS:closeFailed', ncerr );
end


return




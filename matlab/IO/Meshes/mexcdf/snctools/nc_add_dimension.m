function nc_add_dimension ( ncfile, dimension_name, dimension_length )
% NC_ADD_DIMENSION:  adds a dimension to an existing netcdf file
%
% USAGE:  nc_add_dimension ( ncfile, dimension_name, dimension_size );
%
% PARAMETERS:
% Input:
%     ncfile:  path to netcdf file
%     dimension_name:  name of dimension to be added
%     dimension_size:  length of new dimension.  If zero, it will be an
%         unlimited dimension.
% Output:
%     none
%
% In case of an error, an exception is thrown.
%
% Because of underlying limitations, this m-file requires mexnc.
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_add_dimension.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(3,3,nargin);

switch ( version('-release') )
case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
    nc_add_dimension_mex ( ncfile, dimension_name, dimension_length )
otherwise
    nc_add_dimension_tmw ( ncfile, dimension_name, dimension_length )
end

return



%-----------------------------------------------------------------------
function nc_add_dimension_tmw ( ncfile, dimension_name, dimension_length )

ncid = netcdf.open(ncfile, nc_write_mode );

try
    netcdf.reDef(ncid );
    dimid = netcdf.defDim(ncid, dimension_name, dimension_length);
    netcdf.endDef(ncid );
    netcdf.close(ncid );
catch myException
    netcdf.close(ncid);
    rethrow(myException);
end



return







%-----------------------------------------------------------------------
function nc_add_dimension_mex ( ncfile, dimension_name, dimension_length )
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if status
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_DIMENSION:openFailed';
    error ( error_id, ncerr );
end

status = mexnc ( 'redef', ncid );
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_DIMENSION:redefFailed';
    error ( error_id, ncerr );
end

[dimid, status] = mexnc ( 'def_dim', ncid, dimension_name, dimension_length );
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_DIMENSION:defdimFailed';
    error ( error_id, ncerr );
end

status = mexnc ( 'enddef', ncid );
if status
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_DIMENSION:enddefFailed';
    error ( error_id, ncerr );
end


status = mexnc ( 'close', ncid );
if status 
    ncerr = mexnc ( 'strerror', status );
    error_id = 'SNCTOOLS:NC_ADD_DIMENSION:closeFailed';
    error ( error_id, ncerr );
end



return













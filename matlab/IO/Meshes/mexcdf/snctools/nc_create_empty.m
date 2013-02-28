function nc_create_empty ( ncfile, mode )
% NC_CREATE_EMPTY:  creates an empty netCDF file 
%     NC_CREATE_EMPTY(NCFILE,MODE) creates the empty netCDF file NCFILE
%     with the given MODE.  MODE is optional, defaulting to 
%     nc_clobber_mode.
%
% EXAMPLE:
%     Suppose you wish to create a netCDF file with large file support.  
%     This would do it.
%
%     >> my_mode = bitor ( nc_clobber_mode, nc_64bit_offset_mode );
%     >> nc_create_empty ( 'test.nc', my_mode );
%
% SEE ALSO:  
%     nc_noclobber_mode, nc_clobber_mode, nc_64bit_offset_mode
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id:$
% $LastChangedDate:$
% $LastChangedRevision:$
% $LastChangedBy:$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(1,2,nargin);

% Set the default mode if necessary.
if nargin == 1
    mode = nc_clobber_mode;
end

switch ( version('-release') )
    case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
        [ncid, status] = mexnc ( 'CREATE', ncfile, mode );
        if ( status ~= 0 )
            ncerr = mexnc ( 'STRERROR', status );
            error ( 'SNCTOOLS:NC_CREATE_EMPTY:MEXNC:CREATE', ncerr );
        end
        
        status = mexnc ( 'CLOSE', ncid );
        if ( status ~= 0 )
            ncerr = mexnc ( 'STRERROR', status );
            error ( 'SNCTOOLS:NC_CREATE:MEXNC:CLOSE', ncerr );
        end
    otherwise
        ncid = netcdf.create(ncfile, mode );
        netcdf.close(ncid);
end

    
end


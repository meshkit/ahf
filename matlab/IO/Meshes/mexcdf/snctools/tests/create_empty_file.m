function create_empty_file ( ncfile )
% CREATE_EMPTY_FILE:  Does just that, makes an empty netcdf file.
%
% USAGE:  create_empty_file ( ncfile );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: create_empty_file.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

if snctools_use_tmw
	ncid_1 = netcdf.create(ncfile, nc_clobber_mode );
	netcdf.close(ncid_1);
else
	[ncid_1, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
	if ( status ~= 0 )
		ncerr_msg = mexnc ( 'strerror', status );
		msg = sprintf ( '%s:  ''create'' failed, error message '' %s ''\n', mfilename, ncerr_msg );
		error ( msg );
	end
	
	%
	% CLOSE
	status = mexnc ( 'close', ncid_1 );
	if ( status ~= 0 )
		error ( 'CLOSE failed' );
	end
end
return

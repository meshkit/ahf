function test_nc_varsize ( )
% TEST_NC_VARSIZE:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests, routine should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 4:  inputs are not all character
% test 5:  not a netcdf file
% test 6:  empty netcdf file
% test 7:  given variable is not present
%
% 2nd set of tests, routine should succeed
% test 8:  given singleton variable is present
% test 9:  given 1D variable is present
% test 10:  given 1D-unlimited-but-empty variable is present
% test 11:  given 2D variable is present

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_varsize.m 2515 2008-07-03 20:36:38Z johnevans007 $
% $LastChangedDate: 2008-07-03 16:36:38 -0400 (Thu, 03 Jul 2008) $
% $LastChangedRevision: 2515 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fprintf ( 1, 'NC_VARSIZE:  starting test suite...\n' );

test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'testdata/empty.nc' );
test_005 ( 'testdata/empty.nc' );
test_006 ( 'testdata/empty.nc' );
test_007 ( 'testdata/full.nc' );
test_008 ( 'testdata/full.nc' );
test_009 ( 'testdata/full.nc' );
test_010 ( 'testdata/full.nc' );
test_011 ( 'testdata/full.nc' );

return



function test_001 ( ncfile )

try
	v = nc_varsize;
	error ( '%s:  succeeded when it should have failed.\n', mfilename );
end
return











function test_002 ( ncfile )

try
	v = nc_varsize ( ncfile );
	error ( '%s:  succeeded when it should have failed.\n', mfilename );
end
return










function test_003 ( ncfile )

try
	v = nc_varsize ( ncfile, 'x', 'y' );
	error ( '%s:  succeeded when it should have failed.\n', mfilename );
end
return










function test_004 ( ncfile )

try
	v = nc_varsize ( ncfile, 1 );
	error ( '%s:  succeeded when it should have failed.\n', mfilename );
end
return











function test_005 ( ncfile )

% test 5:  not a netcdf file
try
	v = nc_varsize ( mfilename, 't' );
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
return














function test_006 ( ncfile )

try
	v = nc_varsize ( ncfile, 't' );
	msg = sprintf ( '%s:  succceeded when it should have failed.\n', mfilename );
	error ( msg );
end
return










function test_007 ( ncfile )

try
	v = nc_varsize ( ncfile, 'xyz' );
	error ( '%s:  succeeded when it should have failed.\n', mfilename );
end
return











function test_008 ( ncfile )

varsize = nc_varsize ( ncfile, 's' );
if ( varsize ~= 1 )
	error ( '%s:  varsize was not right.\n', mfilename );
end
return









function test_009 ( ncfile )

varsize = nc_varsize ( ncfile, 's' );
if ( varsize ~= 1 )
	error ( '%s:  varsize was not right.\n', mfilename );
end
return











function test_010 ( ncfile )

varsize = nc_varsize ( ncfile, 't3' );
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    if ( varsize(1) ~= 1 ) & ( varsize(2) ~= 0 )
        error ( '%s:  varsize was not right.\n', mfilename );
    end
else
    if ( varsize(1) ~= 0 ) & ( varsize(2) ~= 1 )
        error ( '%s:  varsize was not right.\n', mfilename );
    end
end
return










function test_011 ( ncfile )


varsize = nc_varsize ( ncfile, 'v' );
if ( varsize(1) ~= 1 ) & ( varsize(2) ~= 1 )
	error ( '%s:  varsize was not right.\n', mfilename );
end
return










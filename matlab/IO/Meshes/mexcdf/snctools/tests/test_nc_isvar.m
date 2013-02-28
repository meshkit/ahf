function test_nc_isvar ( )
% TEST_NC_ISVAR:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests, routine should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 4:  both inputs are not character
% test 5:  not a netcdf file
% test 6:  empty netcdf file
% test 7:  netcdf file has dimensions, but no variables.
%
% 2nd set of tests, routine should succeed
% test 8:  given variable is not present
% test 9:  given 1D variable is present

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_isvar.m 2426 2007-11-11 03:56:45Z johnevans007 $
% $LastChangedDate: 2007-11-10 22:56:45 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2426 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_ISVAR:  starting test suite...\n' );

test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'testdata/empty.nc' );
test_005 ( 'testdata/empty.nc' );
test_006 ( 'testdata/empty.nc' );
test_007 ( 'testdata/empty.nc' );
test_008 ( 'testdata/full.nc' );
test_009 ( 'testdata/full.nc' );

return





function test_001 ( ncfile )

try
	nc = nc_isvar;
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return









function test_002 ( ncfile )

try
	nc = nc_isvar ( ncfile );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return










function test_003 ( ncfile )

try
	nc = nc_isvar ( ncfile, 'blah', 'blah2' );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return









function test_004 ( ncfile )



try
	nc = nc_isvar ( ncfile, 5 );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return













function test_005 ( ncfile )

% test 5:  not a netcdf file
try
	nc = nc_isvar ( mfilename, 't' );
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
return










function test_006 ( ncfile )

yn = nc_isvar ( ncfile, 't' );
if ( yn == 1 )
	msg = sprintf ( '%s:  incorrectly classified.\n', mfilename );
	error ( msg );
end
return











function test_007 ( ncfile )

yn = nc_isvar ( ncfile, 't' );
if ( yn == 1 )
	msg = sprintf ( '%s:  incorrectly classified.\n', mfilename );
	error ( msg );
end
return













function test_008 ( ncfile )


b = nc_isvar ( ncfile, 'y' );
if ( b ~= 0 )
	msg = sprintf ( '%s:  incorrect result.\n', mfilename );
	error ( msg );
end
return











function test_009 ( ncfile )



b = nc_isvar ( ncfile, 't' );
if ( b ~= 1 )
	msg = sprintf ( '%s:   incorrect result.\n', mfilename );
	error ( msg );
end
return

function test_nc_isunlimitedvar ( )
% TEST_NC_ISUNLIMITEDVAR:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests, routine should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 4:  both inputs are not character
% test 5:  not a netcdf file
% test 6:  no such var
%
% 2nd set of tests, routine should succeed
% test 9:  given variable is not an unlimited variable
% test 10:  given 1D variable is an unlimited variable
% test 11:  given 2D variable is an unlimited variable

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_isunlimitedvar.m 2416 2007-11-10 13:09:55Z johnevans007 $
% $LastChangedDate: 2007-11-10 08:09:55 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2416 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_ISUNLIMITEDVAR:  starting test suite...\n' );

test_001 ( 'testdata/full.nc' );
test_002 ( 'testdata/full.nc' );
test_003 ( 'testdata/full.nc' );
test_004 ( 'testdata/full.nc' );
test_005 ( 'testdata/full.nc' );
test_006 ( 'testdata/full.nc' );
test_009 ( 'testdata/full.nc' );
test_010 ( 'testdata/full.nc' );
test_011 ( 'testdata/full.nc' );


return








function test_001 ( ncfile )

try
	nc = nc_isunlimitedvar;
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end










function test_002 ( ncfile )

try
	nc = nc_isunlimitedvar ( ncfile );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return











function test_003 ( ncfile )

try
	nc = nc_isunlimitedvar ( ncfile, 'blah', 'blah2' );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end

return









function test_004 ( ncfile )



try
	nc = nc_isunlimitedvar ( ncfile, 5 );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return







function test_005  ( ncfile )

try
	nc = nc_isunlimitedvar ( 'test_nc_isunlimitedvar.m', 't' );
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
return











function test_006 ( ncfile )

b = nc_isunlimitedvar ( ncfile, 'tt' );
if b 
    error ( 'succeeded when it should have failed.\n' );
end
return

















function test_009 ( ncfile )

b = nc_isunlimitedvar ( ncfile, 's' );
if b
	msg = sprintf ( '%s:  incorrect result.\n', mfilename );
	error ( msg );
end
return








function test_010 ( ncfile )

b = nc_isunlimitedvar ( ncfile, 't2' );
if ~b
	msg = sprintf ( '%s:  incorrect result.\n', mfilename );
	error ( msg );
end
return









function test_011 ( ncfile )

b = nc_isunlimitedvar ( ncfile, 't3' );
if ( ~b  )
	msg = sprintf ( '%s: incorrect result.\n', mfilename );
	error ( msg );
end

return





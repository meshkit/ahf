function test_nc_getlast ( )
% TEST_NC_GETLAST:
%
% This first set of tests should all fail.
% Test 1:  No inputs.
% Test 2:  One input.
% Test 3:  Four inputs.
% Test 4:  1st input is not character.
% Test 5:  2nd input is not character.
% Test 6:  3rd input is not numeric.
% Test 7:  1st input is not a netcdf file.
% Test 8:  2nd input is not a netcdf variable.
% Test 9:  2nd input is a netcdf variable, but not unlimited.
% Test 10:  Non-positive "num_records"
% Test 12:  Time series variables have data, but fewer than what was 
%           requested.
%
% This second set of tests should all succeed.
% Test 13:  Two inputs, should return the last record.
% Test 14:  Three valid inputs.
% Test 15:  Get everything

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_getlast.m 2426 2007-11-11 03:56:45Z johnevans007 $
% $LastChangedDate: 2007-11-10 22:56:45 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2426 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fprintf ( 1, 'NC_GETLAST:  starting test suite...\n' );
test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'testdata/empty.nc' );
test_005 ( 'testdata/empty.nc' );
test_006 ( 'testdata/empty.nc' );
test_007 ( 'testdata/empty.nc' );
test_008 ( 'testdata/getlast.nc' );
test_009 ( 'testdata/getlast.nc' );
test_010 ( 'testdata/getlast.nc' );
test_012 ( 'testdata/getlast.nc' );
test_013 ( 'testdata/getlast.nc' );
test_014 ( 'testdata/getlast.nc' );
test_015 ( 'testdata/getlast.nc' );

return




function test_001 ( ncfile )

try
	nb = nc_getlast;
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return







function test_002 ( ncfile )

try
	nc_getlast ( ncfile );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_003 ( ncfile )

try
	nb = nc_getlast ( ncfile, 't1', 3, 4 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_004 ( ncfile )

try
	nb = nc_getlast ( 0, 't1' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_005 ( ncfile )

try
	nb = nc_getlast ( ncfile, 0 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_006 ( ncfile )

try
	nb = nc_getlast ( ncfile, 't1', 'a' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_007 ( ncfile )

try
	nb = nc_getlast ( 'test_nc_getlast.m', 't1', 1 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_008 ( ncfile )

try
	nb = nc_getlast ( ncfile, 't4', 1 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_009 ( ncfile )

try
	nb = nc_getlast ( ncfile, 'x', 1 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_010 ( ncfile )

try
	nb = nc_getlast ( ncfile, 't1', 0 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return






function test_012 ( ncfile )


try
	nb = nc_getlast ( ncfile, 't1', 12 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return







function test_013 ( ncfile )

v = nc_getlast ( ncfile, 't1' );
if ( length(v) ~= 1 )
	error ( 'return value length was wrong' );
end
return




function test_014 ( ncfile )
v = nc_getlast ( ncfile, 't1', 7 );
if ( length(v) ~= 7 )
	msg = sprintf ( '%s:  : return value length was wrong.\n', mfilename  );
	error ( msg );
end
return



function test_015 ( ncfile )

v = nc_getlast ( ncfile, 't1', 10 );
if ( length(v) ~= 10 )
	msg = sprintf ( '%s:  : return value length was wrong.\n', mfilename  );
	error ( msg );
end
return



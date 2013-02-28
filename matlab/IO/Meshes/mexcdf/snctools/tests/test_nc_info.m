function test_nc_info ( )
% TEST_NC_INFO:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests should fail
% test 1:  no input arguments, should fail
% test 2:  too many inputs
% test 3:  1 input, not a netcdf file
%
% 2nd set of tests should succeed
% test 4:  empty netcdf file
% test 5:  netcdf file has dimensions, but no variables.
% test 6:  netcdf file has unlimited variables, fixed variables
%          and fixed variables, and global attributes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_info.m 2426 2007-11-11 03:56:45Z johnevans007 $
% $LastChangedDate: 2007-11-10 22:56:45 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2426 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_INFO:  starting test suite...\n' );
test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( mfilename );
test_004 ( 'testdata/empty.nc' );
test_005 ( 'testdata/just_one_dimension.nc' );
test_006 ( 'testdata/full.nc' );
return





function test_001 ( ncfile )
try
	nc = nc_info;
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_002 ( ncfile )
try
	nc = nc_info ( ncfile, 'blah' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_003 (ncfile)
try
	nc = nc_info ( ncfile );
	error ( 'succeeded when it should have failed.' );
end
return







function test_004 ( ncfile )

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	msg = sprintf ( '%s:  :  Filename was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dimension ) ~= 0 )
	msg = sprintf ( '%s:  :  Dimension was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dataset ) ~= 0 )
	msg = sprintf ( '%s:  :  Dataset was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Attribute ) ~= 0 )
	msg = sprintf ( '%s:  :  Attribute was wrong.\n', mfilename  );
	error ( msg );
end
return









function test_005 ( ncfile )

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	msg = sprintf ( '%s:  :  Filename was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dimension ) ~= 1 )
	msg = sprintf ( '%s:  :  Dimension was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dataset ) ~= 0 )
	msg = sprintf ( '%s:  :  Dataset was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Attribute ) ~= 0 )
	msg = sprintf ( '%s:  :  Attribute was wrong.\n', mfilename  );
	error ( msg );
end
return










function test_006 ( ncfile )


nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	msg = sprintf ( '%s:  :  Filename was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dimension ) ~= 5 )
	msg = sprintf ( '%s:  :  Dimension was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Dataset ) ~= 6 )
	msg = sprintf ( '%s:  :  Dataset was wrong.\n', mfilename  );
	error ( msg );
end
if ( length ( nc.Attribute ) ~= 1 )
	msg = sprintf ( '%s:  :  Attribute was wrong.\n', mfilename  );
	error ( msg );
end
return







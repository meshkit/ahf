function test_nc_iscoordvar ( )
% TEST_NC_ISCOORDVAR:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests should fail
% test 1:  no input arguments
% test 2:  1 input
% test 3:  too many inputs
% test 5:  not a netcdf file
% test 6:  empty netcdf file
% test 8:  given variable is not present  
% test 9:  given variable's dimension is not of the same name
% test 10:  given variable has more than one dimension
%
% 2nd set of tests should succeed
% test 11:  netcdf file has singleton variable, but no dimensions.
% test 12:  given variable has one dimension of the same name

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_iscoordvar.m 2514 2008-07-03 20:35:32Z johnevans007 $
% $LastChangedDate: 2008-07-03 16:35:32 -0400 (Thu, 03 Jul 2008) $
% $LastChangedRevision: 2514 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fprintf ( 1, 'NC_ISCOORDVAR:  starting test suite...\n' );
test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_005 ( 'test_iscoordvar.m' );
test_006 ( 'testdata/empty.nc' );
test_008 ( 'testdata/iscoordvar.nc' );
test_009 ( 'testdata/iscoordvar.nc' );
test_010 ( 'testdata/iscoordvar.nc' );
test_011 ( 'testdata/iscoordvar.nc' );
test_012 ( 'testdata/iscoordvar.nc' );

return









function test_001 ( ncfile )
try
	nc = nc_iscoordvar;
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end




function test_002 ( ncfile )

try
	nc = nc_iscoordvar ( ncfile );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_003 ( ncfile )

try
	nc = nc_iscoordvar ( ncfile, 'blah', 'blah2' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return










function test_005 ( ncfile )
% test 5:  not a netcdf file
try
	nc = nc_iscoordvar ( 'test_iscoordvar.m', 't' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return







function test_006 ( ncfile )

try
	nc = nc_iscoordvar ( ncfile, 't' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return










function test_008 ( ncfile )

try
	nc = nc_iscoordvar ( ncfile, 'y' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return








function test_009 ( ncfile )

% 2nd set of tests should succeed
% test 9:  given variable's dimension is not of the same name

b = nc_iscoordvar ( ncfile, 'u' );
if ( b ~= 0 )
	msg = sprintf ( '%s:    incorrect result.\n', mfilename  );
	error ( msg );
end
return






function test_010 ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ( ~b )
	error ( 'incorrect result.\n' );
end
return







function test_011 ( ncfile )

yn = nc_iscoordvar ( ncfile, 't' );
if ( yn )
	error ( 'incorrect result.\n'  );
end

return






function test_012 ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ~b
	error ( 'incorrect result.\n'  );
end

return










function test_nc_attget ( )
% TEST_NC_ATTGET
%
% Tests run include
%
% 1.  retrieve a double attribute
% 2.  retrieve a float attribute
% 3.  retrieve a int attribute
% 4.  retrieve a short int attribute
% 5.  retrieve a uint8 attribute
% 6.  retrieve a int8 attribute
% 7.  retrieve a text attribute
% 9.  write/retrieve a global attribute, using -1 as the variable name.
% 10.  write/retrieve a global attribute, using nc_global as the variable name.
% 11.  write/retrieve a global attribute, using 'GLOBAL' as the variable name.
% 12.  Try to retrieve a non existing attribute, should fail
% 13.  Retrieve from a netcdf-4 file

% 401:  try to retrieve an attribute from a non dods url

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_attget_attput.m 2394 2007-11-08 13:27:30Z johnevans007 $
% $LastChangedDate: 2007-11-08 08:27:30 -0500 (Thu, 08 Nov 2007) $
% $LastChangedRevision: 2394 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_ATTGET:  starting test suite...\n' );

ncfile = 'testdata/attget.nc';

test_01 ( ncfile );
test_02 ( ncfile );
test_03 ( ncfile );
test_04 ( ncfile );
test_05 ( ncfile );
test_06 ( ncfile );
test_07 ( ncfile );
test_08 ( ncfile );
test_09 ( ncfile );
test_10 ( ncfile );
test_11 ( ncfile );
test_12 ( ncfile );
test_130 ( 'testdata/tst_pres_temp_4D_netcdf4.nc' );




return




function test_401 (ncfile)

if ~ ( getpref ( 'SNCTOOLS', 'TEST_REMOTE', false ) )
	return;
end
url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';
fprintf ( 1, 'Testing remote URL access %s...\n', url );
w = nc_attget ( url, 'w', 'valid_range' );
if ~strcmp(class(w),'single')
	error ( 'Class of retrieve attribute was not single' );
end
if (abs(double(w(1)) - 0.5) < eps)
	error ( 'valid max did not match' );
end
if (abs(double(w(2)) - 0.5) < eps)
	error ( 'valid max did not match' );
end
return


function test_03 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_int_att' );
if ( ~strcmp(class(attvalue), 'int32' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int32.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= int32(3) )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename);
	error ( msg );
end

return











function test_04 ( ncfile )




attvalue = nc_attget ( ncfile, 'x_db', 'test_short_att' );
if ( ~strcmp(class(attvalue), 'int16' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int16.\n', mfilename );
	error ( msg );
end
if ( length(attvalue) ~= 2 )
	msg = sprintf ( '%s:  retrieved attribute length differs from what was written.\n', mfilename );
	error ( msg );
end
if ( any(double(attvalue) - [5 7])  )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename  );
	error ( msg );
end

return






function test_05 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_uchar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int8.\n', mfilename );
	error ( msg );
end
if ( uint8(attvalue) ~= uint8(100) )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return




function test_06 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_schar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int8.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= int8(-100) )
	msg = sprintf ( '%s:  %s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return






function test_07 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_text_att' );
if ( ~strcmp(class(attvalue), 'char' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not char.\n', mfilename );
	error ( msg );
end

if ( ~strcmp(attvalue,'abcdefghijklmnopqrstuvwxyz') )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return





function test_08 ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );

attvalue = nc_attget ( ncfile, '', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= 3.14159 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );

return





function test_09 ( ncfile )

attvalue = nc_attget ( ncfile, -1, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= 3.14159 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return





function test_10 ( ncfile )

attvalue = nc_attget ( ncfile, nc_global, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= 3.14159 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename  );
	error ( msg );
end

return 






function test_11 ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );

attvalue = nc_attget ( ncfile, 'GLOBAL', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= 3.14159 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename  );
	error ( msg );
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'on', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );

return





function test_12 ( ncfile )

try
	attvalue = nc_attget ( ncfile, 'z_double', 'test_double_att' );
	msg = sprintf ( '%s:  %s:  nc_attget succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end

return



function test_130 ( ncfile )

try
	attvalue = nc_attget ( ncfile, 'longitude', 'units' );
catch
	[emsg,eid] = lasterr;
	switch ( eid )
		case { 'MATLAB:netcdf:open:notANetcdfFile', ...
		       'SNCTOOLS:nc_attget:noRetrievalMethodAvailable' }
			   return
	otherwise
		error ( eid, emsg );
	end
end

if ~strcmp(attvalue,'degrees_east')
	error('unable to retrieve attribute from NC4 file');
end

return















function test_01 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end
if ( attvalue ~= 3.14159 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return




function test_02 ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_float_att' );
if ( ~strcmp(class(attvalue), 'single' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not single.\n', mfilename );
	error ( msg );
end
if ( abs(double(attvalue) - 3.14159) > 1e-6 )
	msg = sprintf ( '%s:  retrieved attribute differs from what was written.\n', mfilename );
	error ( msg );
end

return



function test_nc_attput ( ncfile )
% TEST_NC_ATTPUT
%
% Tests run include
%
% 21.  write/retrieve a new double attribute
% 22.  write/retrieve a new float attribute
% 23.  write/retrieve a new int attribute
% 24.  write/retrieve a new short int attribute
% 25.  write/retrieve a new uint8 attribute
% 26.  write/retrieve a new int8 attribute
% 27.  write/retrieve a new text attribute

% 401:  try to retrieve an attribute from a non dods url

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_attput.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_ATTGET, NC_ATTPUT:  starting test suite...\n' );


if nargin == 0
	ncfile = 'foo.nc';
end

create_test_ncfile ( ncfile )

test_21 ( ncfile );
test_22 ( ncfile );
test_23 ( ncfile );
test_24 ( ncfile );
test_25 ( ncfile );
test_26 ( ncfile );
test_27 ( ncfile );



return




function create_test_ncfile ( ncfile )

if snctools_use_tmw
	ncid = netcdf.create(ncfile, nc_clobber_mode );
	
	%
	% Create two fixed dimensions.  
	len_x = 1;
	xdimid = netcdf.defDim(ncid, 'x', len_x );
	len_y = 1;
	ydimid = netcdf.defDim(ncid, 'y', len_y );
	
	xvarid = netcdf.defVar(ncid, 'x_db', 'NC_DOUBLE', [xdimid ydimid] );
	zvarid = netcdf.defVar(ncid, 'z_double', 'NC_DOUBLE', [xdimid ydimid] );
	
	
	%
	% Define attributes for all datatypes for x_db, but not z_double
	% The short int attribute will have length 2
	netcdf.putAtt(ncid, xvarid, 'test_double_att', 3.14159 );
	netcdf.putAtt(ncid, xvarid, 'test_float_att', single(3.14159) );
	netcdf.putAtt(ncid, xvarid, 'test_int_att', int32(3) );
	netcdf.putAtt(ncid, xvarid, 'test_short_att', int16([5 7]) );
	netcdf.putAtt(ncid, xvarid, 'test_uchar_att', uint8([100]) );
	netcdf.putAtt(ncid, xvarid, 'test_schar_att', int8([-100]) );
	netcdf.putAtt(ncid, xvarid, 'test_text_att', 'abcdefghijklmnopqrstuvwxyz' );
	
	netcdf.putAtt(ncid, nc_global, 'test_double_att', 3.14159 );
	
	netcdf.endDef(ncid);
	netcdf.close(ncid);
	
	
else
	%
	% ok, first create this baby.
	[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	
	%
	% Create two fixed dimensions.  
	len_x = 1;
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	len_y = 1;
	[ydimid, status] = mexnc ( 'def_dim', ncid, 'y', len_y );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	[xvarid, status] = mexnc ( 'def_var', ncid, 'x_db', 'NC_DOUBLE', 2, [ydimid xdimid] );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	[zvarid, status] = mexnc ( 'def_var', ncid, 'z_double', 'NC_DOUBLE', 2, [ydimid xdimid] );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	%
	% Define attributes for all datatypes for x_db, but not z_double
	% The short int attribute will have length 2
	status = mexnc ( 'put_att_double', ncid, xvarid, 'test_double_att', nc_double, 1, 3.14159 );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_float', ncid, xvarid, 'test_float_att', nc_float, 1, single(3.14159) );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_int', ncid, xvarid, 'test_int_att', nc_int, 1, int32(3) );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_short', ncid, xvarid, 'test_short_att', nc_short, 2, int16([5 7]) );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_uchar', ncid, xvarid, 'test_uchar_att', nc_byte, 1, uint8(100) );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_schar', ncid, xvarid, 'test_schar_att', nc_byte, 1, int8(-100) );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_text', ncid, xvarid, 'test_text_att', nc_char, 26, 'abcdefghijklmnopqrstuvwxyz' );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	status = mexnc ( 'put_att_double', ncid, nc_global, 'test_double_att', nc_double, 1, 3.14159 );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	
	
	[status] = mexnc ( 'end_def', ncid );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
	
	%
	% CLOSE
	status = mexnc ( 'close', ncid );
	if ( status ~= 0 ), mexnc ( 'strerror', status ), end
	
end

return

function test_02 ( ncfile )

create_test_ncfile ( ncfile );

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



function test_21 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', 0 );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'double' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not double.\n', mfilename );
	error ( msg );
end

if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end

return




function test_22 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', single(0) );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'single' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not single.\n', mfilename );
	error ( msg );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


function test_23 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', int32(0) );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'int32' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int32.\n', mfilename );
	error ( msg );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


function test_24 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', int16(0) );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'int16' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int16.\n', mfilename );
	error ( msg );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


function test_25 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', int8(0) );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'int8' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not int8.\n', mfilename );
	error ( msg );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


function test_26 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', uint8(0) );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'int8' ) )
	msg = sprintf ( 'class of retrieved attribute was %s and not int8.\n', class(x) );
	error ( msg );
end
if ( double(x) ~= 0 )
	error ( 'retrieved attribute was not same as written value' );
end


function test_27 ( ncfile )

nc_attput ( ncfile, 'x_db', 'new_att', '0' );
x = nc_attget ( ncfile, 'x_db', 'new_att' );

if ( ~strcmp(class(x), 'char' ) )
	msg = sprintf ( '%s:  class of retrieved attribute was not char.\n', mfilename );
	error ( msg );
end
if (x ~= '0' )
	error ( 'retrieved attribute was not same as written value' );
end


return






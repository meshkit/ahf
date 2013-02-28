function test_put_get_att ( ncfile )
% TEST_PUT_GET_ATT:  tests the PUT_ATT and GET_ATT family of calls
%
% Test 8:  Read and write a NC_DOUBLE attribute, using PUT/GET_ATT_DOUBLE.
% Test 9:  Read and write a NC_FLOAT attribute, using PUT/GET_ATT_FLOAT.
% Test 10: Read and write a NC_INT attribute, using PUT/GET_ATT_INT.
% Test 11: Read and write a NC_SHORT attribute, using PUT/GET_ATT_SHORT.
% Test 12: Read and write a NC_SCHAR attribute, using PUT/GET_ATT_SCHAR.
% Test 13: Read and write a NC_CHAR attribute using PUT/GET_ATT_TEXT.
%
% Test 14:  read a float attribute back as double
% Test 15:  Write a double attribute, read back as float
% Test 16:  Write a double attribute, read back as int
% Test 17:  Write a double attribute, read back as short
% Test 18:  Write a double attribute, read back as uint8
% Test 19:  Write a double attribute, read back as int8
%
% Test 020:  Write a single precision attribute, read it back as double


create_test_file ( ncfile );

test_eight ( ncfile );
fprintf ( 1, 'PUT_ATT_DOUBLE succeeded.\n' );
fprintf ( 1, 'GET_ATT_DOUBLE succeeded.\n' );


test_nine ( ncfile );
fprintf ( 1, 'PUT_ATT_FLOAT succeeded.\n' );
fprintf ( 1, 'GET_ATT_FLOAT succeeded.\n' );


test_ten ( ncfile );
fprintf ( 1, 'PUT_ATT_INT succeeded.\n' );
fprintf ( 1, 'GET_ATT_INT succeeded.\n' );


test_11 ( ncfile );
fprintf ( 1, 'PUT_ATT_SHORT succeeded.\n' );
fprintf ( 1, 'GET_ATT_SHORT succeeded.\n' );


test_12 ( ncfile );
fprintf ( 1, 'PUT_ATT_SCHAR succeeded.\n' );
fprintf ( 1, 'GET_ATT_SCHAR succeeded.\n' );


test_13 ( ncfile );
fprintf ( 1, 'PUT_ATT_TEXT succeeded.\n' );
fprintf ( 1, 'GET_ATT_TEXT succeeded.\n' );


test_014 ( ncfile );
test_015 ( ncfile );
test_016 ( ncfile );
test_017 ( ncfile );
test_018 ( ncfile );
test_019 ( ncfile );
test_020 ( ncfile );

return;










% Test 13:  Write and read back an NC_CHAR attribute using PUT/GET_ATT_TEXT.
function test_13 ( ncfile );

testid = 'Test 13';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = 'abcdefghijklmnopqrstuvwxyz';
status = mexnc ( 'put_att_text', ncid, nc_global, 'test_att_text', nc_char, length(input_data), input_data );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[output_data, status] = mexnc ( 'get_att_text', ncid, nc_global, 'test_att_text' );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	error ( err_msg );
end

return









% Test 12:  Write and read back an NC_BYTE attribute using PUT/GET_ATT_SCHAR.
function test_12 ( ncfile );

testid = 'Test 12';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = int8([-3 6 9]);
status = mexnc ( 'put_att_schar', ncid, nc_global, 'test_int8', nc_byte, 3, input_data );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[output_data, status] = mexnc ( 'get_att_schar', ncid, nc_global, 'test_int8' );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	[input_data output_data]
	error ( err_msg );
end







% Test 11:  Write and read back an NC_SHORT attribute using PUT/GET_ATT_SHORT.
function test_11 ( ncfile );

testid = 'Test 11';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = int16([3 6 9]);
status = mexnc ( 'put_att_short', ncid, nc_global, 'test_int16', nc_short, 3, input_data );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[output_data, status] = mexnc ( 'get_att_short', ncid, nc_global, 'test_int16' );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	[input_data output_data]
	error ( err_msg );
end







% Test 10:  Write and read back an NC_FLOAT attribute using PUT/GET_ATT_DOUBLE.
function test_ten ( ncfile );

testid = 'Test 10';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = int32([3 6 9]);
status = mexnc ( 'put_att_int', ncid, nc_global, 'test_int32', nc_int, 3, input_data );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[output_data, status] = mexnc ( 'get_att_int', ncid, nc_global, 'test_int32' );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	[input_data output_data]
	error ( err_msg );
end

return






% Test 9:  Write and read back an NC_FLOAT attribute using PUT/GET_ATT_FLOAT.
function test_nine ( ncfile );

testid = 'Test 9';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = single([3 6 9]);
status = mexnc ( 'put_att_float', ncid, nc_global, 'test_float9', nc_float, 3, input_data );
if status, error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_float', ncid, nc_global, 'test_float9' );
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	error ( err_msg );
end

return






% Test 8:  Write and read back an NC_DOUBLE attribute using PUT/GET_ATT_DOUBLE.
function test_eight ( ncfile );

testid = 'Test 8';
[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = [3 6 9];
status = mexnc ( 'put_att_double', ncid, nc_global, 'test_double2', nc_double, 3, input_data );
if status, error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_double', ncid, nc_global, 'test_double2' );
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if status, error ( mexnc('strerror',status) ), end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	error ( err_msg );
end

return







function test_014 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_float', ncid, nc_global, 'float_to_other', nc_float, 1, single(3.14) );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as double precision
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_double', ncid, nc_global, 'float_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'double') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function test_015 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_double', ncid, nc_global, 'double_to_other', nc_double, 1, 3.14 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as double precision
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_float', ncid, nc_global, 'double_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'single') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return





function test_016 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_double', ncid, nc_global, 'double_to_other', nc_double, 1, 3.14 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as int32 
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_int', ncid, nc_global, 'double_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'int32') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function test_017 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_double', ncid, nc_global, 'double_to_other', nc_double, 1, 3.14 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as int16
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_short', ncid, nc_global, 'double_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'int16') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function test_018 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_double', ncid, nc_global, 'double_to_other', nc_double, 1, 3.14 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as int8 
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_schar', ncid, nc_global, 'double_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'int8') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function test_019 ( ncfile )

create_test_file ( ncfile );

%
% Add the float attribute
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'redef', ncid  );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'put_att_double', ncid, nc_global, 'double_to_other', nc_double, 1, 3.14 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% read back the attribute as uint8 
[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_uchar', ncid, nc_global, 'double_to_other' );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

if ( ~strcmp(class(output_data),'uint8') )
	error ( 'attribute not converted to desired class' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function create_test_file ( ncfile )


%
% ok, first create this baby.
mode = nc_clobber_mode;
[ncid, status] = mexnc ( 'create', ncfile, mode );
if ( status ~= 0 )
	ncerr_msg = mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  ''create'' failed on %s, error message '' %s ''\n', mfilename, ncfile, ncerr_msg );
	error ( msg );
end


status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end





return





function c = load_text_into_cell ( file )


afid = fopen ( file, 'r' );
count = 0;
while 1
	line = fgetl ( afid );
	if ~ischar(line)
		break;
	end
	count = count + 1;
	c{count,1} = line;
end
fclose ( afid );
return










% Test 020:  Write a single precision attribute, read it back as double
function test_020 ( ncfile );

[ncid, status] = mexnc('OPEN', ncfile, nc_write_mode);
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'REDEF', ncid );
if status, error ( mexnc('strerror',status) ), end

input_data = [3 6 9];
status = mexnc ( 'put_att_double', ncid, nc_global, 'test_att', nc_float, 3, input_data );
if status, error ( mexnc('strerror',status) ), end

[output_data, status] = mexnc ( 'get_att_double', ncid, nc_global, 'test_att' );
if status, error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if status, error ( mexnc('strerror',status) ), end

if any ( double(input_data(:)) - double(output_data(:)) )
	err_msg = sprintf ( '%s:  %s:  attribute values differ.\n', mfilename, testid );
	error ( err_msg );
end

if ~strcmp ( class(output_data),'double')
	error ( 'Class of output data was not correct' );
end

return







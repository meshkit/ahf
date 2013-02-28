function test_varput ( ncfile )
% TEST_VARPUT
%
% This routine tests VARGET, VARPUT
%
% Test 1:  test VARPUT/VARGET with double precision data
% Test 2:  test VARPUT/VARGET with float data
% Test 3:  test VARPUT/VARGET with scaling
% Test 4:  test VARPUT/VARGET with scaling flag set to 0.
% Test 005:  test 2D VARPUT/VARGET 
% Test 006:  test 2D VARPUT/VARGET on lower right quadrant 
% Test 010:  test writing a short datum to a double precision variable
% Test 100:  VARPUT with a bad ncid
% Test 101:  VARGET with a bad ncid
% Test 102:  VARPUT with a bad varid

if ( nargin < 1 )
	ncfile = 'foo.nc';
end

mexnc ( 'setopts', 0 );

create_testfile ( ncfile );
test_001 ( ncfile );
test_002 ( ncfile );
test_003 ( ncfile );
test_004 ( ncfile );
test_005 ( ncfile );
test_010 ( ncfile );
test_100 ( ncfile );
test_101 ( ncfile );
test_102 ( ncfile );

fprintf ( 1, 'VARPUT succeeded\n' );
fprintf ( 1, 'VARGET succeeded\n' );

return




function create_testfile ( ncfile )


%
% ok, first create this baby.
[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



%
% Create the fixed dimension.  
len_x = 100;
len_y = 200;
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[ydimid, status] = mexnc ( 'def_dim', ncid, 'y', len_y );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


[z_double_varid, status] = mexnc ( 'def_var', ncid, 'z_double', nc_double, 1, [xdimid] );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


[z_float_varid, status] = mexnc ( 'def_var', ncid, 'z_float', nc_float, 1, [xdimid] );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end



[z_short_varid, status] = mexnc ( 'def_var', ncid, 'z_short', nc_short, 1, [xdimid] );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[twod_varid, status] = mexnc ( 'def_var', ncid, 'twoD', nc_double, 2, [ydimid xdimid] );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


eps = 0.01;
status = mexnc ( 'put_att_double', ncid, z_short_varid, 'scale_factor', nc_double, 1, eps );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


status = mexnc ( 'put_att_double', ncid, z_short_varid, 'add_offset', nc_double, 1, 0.00 );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[status] = mexnc ( 'enddef', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


%
% CLOSE
status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return















function test_001 ( ncfile );


[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_double_varid, status] = mexnc('INQ_VARID', ncid, 'z_double');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = rand(50,1);
status = mexnc ( 'VARPUT', ncid, z_double_varid, [1], [50], input_data );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

mexnc('sync',ncid);

[output_data, status] = mexnc ( 'VARGET', ncid, z_double_varid, [1], [50] );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

output_data = output_data(:);

d = max(abs(output_data-input_data))';
if (any(d))
	error ( 'values written by VARGET do not match what was retrieved by VARPUT\n'  );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_002 ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[varid, status] = mexnc('INQ_VARID', ncid, 'z_float');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = single(rand(50,1));
try
	status = mexnc ( 'VARPUT', ncid, varid, [1], [50], input_data );
	error ( 'Succeeded when it should have failed.' );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return









function test_010 ( ncfile );


[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[varid, status] = mexnc('INQ_VARID', ncid, 'z_double');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = int16(rand(50,1)*100);
try
	status = mexnc ( 'VARPUT', ncid, varid, [1], [50], input_data );
	error ( 'Succeeded when it should have failed.' );
end


status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return









function test_100 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_double_varid, status] = mexnc('INQ_VARID', ncid, 'z_double');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = rand(50,1);
try
    status = mexnc ( 'VARPUT', -100, z_double_varid, [1], [50], input_data );
	msg = sprintf ( '%s:  %s:  VARPUT succeeded with a bad ncid\n', mfilename, testid );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return







function test_101 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_double_varid, status] = mexnc('INQ_VARID', ncid, 'z_double');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

try
    [output_data, status] = mexnc ( 'VARGET', -100, z_double_varid, [1], [50] );
	msg = sprintf ( '%s:  %s:  VARGET succeeded with a bad ncid\n', mfilename, testid );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_102 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_double_varid, status] = mexnc('INQ_VARID', ncid, 'z_double');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = rand(50,1);
try
    status = mexnc ( 'VARPUT', ncid, -500, [1], [50], input_data );
	msg = sprintf ( '%s:  %s:  VARPUT succeeded with a bad varid\n', mfilename, testid );
	error ( msg );
end


status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return



function test_003 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_short_varid, status] = mexnc('INQ_VARID', ncid, 'z_short');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[dimid, status] = mexnc('INQ_DIMID', ncid, 'x');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_x, status] = mexnc('INQ_DIMLEN', ncid, dimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[scale_factor, status] = mexnc('GET_ATT_DOUBLE', ncid, z_short_varid, 'scale_factor');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


input_data = rand(len_x,1);
status = mexnc ( 'VARPUT', ncid, z_short_varid, [0], [len_x], input_data', 1 );
if ( status ~= 0 )
	ncerr_msg = mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  VARPUT failed, (%s)\n', mfilename, ncerr_msg );
	error ( msg );
end


[output_data, status] = mexnc ( 'VARGET', ncid, z_short_varid, [0], [len_x], 1 );
if ( status ~= 0 )
	msg = sprintf ( '%s:  VARGET failed, msg ''%s''\n', mfilename, mexnc ( 'strerror', status ) );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

output_data = output_data';

if (~strcmp(class(output_data),'double'))
	msg = sprintf ( 'data was not double precision' );
	error ( msg );
end

d = max(abs(output_data-input_data))';
ind = find ( d > abs(scale_factor)/2 );
if (any(ind))
	msg = sprintf ( 'values written by VARPUT do not match what was retrieved by VARGET' );
	error ( msg );
end







function test_004 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[z_short_varid, status] = mexnc('INQ_VARID', ncid, 'z_short');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[dimid, status] = mexnc('INQ_DIMID', ncid, 'x');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_x, status] = mexnc('INQ_DIMLEN', ncid, dimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = int16(rand(len_x,1)*100);
input_data = double(input_data);

status = mexnc ( 'VARPUT', ncid, z_short_varid, [0], [len_x], input_data', 0 );
if ( status ~= 0 )
	ncerr_msg = mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  VARPUT failed, (%s)\n', mfilename, ncerr_msg );
	error ( msg );
end


[output_data, status] = mexnc ( 'VARGET', ncid, z_short_varid, [0], [len_x], 0 );
if ( status ~= 0 )
	msg = sprintf ( '%s:  VARGET failed, msg ''%s''\n', mfilename, mexnc ( 'strerror', status ) );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

output_data = output_data';

if (~strcmp(class(output_data),'double'))
	msg = sprintf ( 'data was not double precision' );
	error ( msg );
end

d = max(abs(output_data-input_data))';
ind = find ( d > 0 );
if (any(ind))
	msg = sprintf ( 'values written by VARPUT do not match what was retrieved by VARGET' );
	error ( msg );
end



function test_005 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[varid, status] = mexnc('INQ_VARID', ncid, 'twoD');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[xdimid, status] = mexnc('INQ_DIMID', ncid, 'x');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[ydimid, status] = mexnc('INQ_DIMID', ncid, 'y');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_x, status] = mexnc('INQ_DIMLEN', ncid, xdimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_y, status] = mexnc('INQ_DIMLEN', ncid, ydimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = [1:len_y*len_x];
input_data = reshape(input_data,[len_y len_x]);

status = mexnc ( 'VARPUT', ncid, varid, [0 0], [len_y len_x], input_data' );
if ( status ~= 0 )
	ncerr_msg = mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  VARPUT failed, (%s)\n', mfilename, ncerr_msg );
	error ( msg );
end


[output_data, status] = mexnc ( 'VARGET', ncid, varid, [0 0], [len_y len_x] );
if ( status ~= 0 )
	msg = sprintf ( '%s:  VARGET failed, msg ''%s''\n', mfilename, mexnc ( 'strerror', status ) );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

output_data = output_data';

if (~strcmp(class(output_data),'double'))
	msg = sprintf ( 'data was not double precision' );
	error ( msg );
end

d = max(abs(output_data-input_data))';
ind = find ( d > 0 );
if (any(ind))
	msg = sprintf ( 'values written by VARPUT do not match what was retrieved by VARGET' );
	error ( msg );
end



function test_006 ( ncfile )

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[varid, status] = mexnc('INQ_VARID', ncid, 'twoD');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[xdimid, status] = mexnc('INQ_DIMID', ncid, 'x');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[ydimid, status] = mexnc('INQ_DIMID', ncid, 'y');
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_x, status] = mexnc('INQ_DIMLEN', ncid, xdimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

[len_y, status] = mexnc('INQ_DIMLEN', ncid, ydimid);
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

input_data = [1:len_y*len_x];
input_data = reshape(input_data,[len_y len_x]);
input_data = input_data(end-8:end,end-6:end);

status = mexnc ( 'VARPUT', ncid, varid, [len_y-8 len_x-6], [8 6], input_data' );
if ( status ~= 0 )
	ncerr_msg = mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  VARPUT failed, (%s)\n', mfilename, ncerr_msg );
	error ( msg );
end


[output_data, status] = mexnc ( 'VARGET', ncid, varid, [len_y-8 len_x-6], [8 8] );
if ( status ~= 0 )
	msg = sprintf ( '%s:  VARGET failed, msg ''%s''\n', mfilename, mexnc ( 'strerror', status ) );
	error ( msg );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

output_data = output_data';

if (~strcmp(class(output_data),'double'))
	msg = sprintf ( 'data was not double precision' );
	error ( msg );
end

d = max(abs(output_data-input_data))';
ind = find ( d > 0 );
if (any(ind))
	msg = sprintf ( 'values written by VARPUT do not match what was retrieved by VARGET' );
	error ( msg );
end




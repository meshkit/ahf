function test_dimdef ( ncfile )
% TEST_DIMDEF
%
% Test 1:  Define a dimension.
% Test 2:  Bad ncid.
% Test 3:  Empty string name.
% Test 4:  Empty set name.
% Test 5:  Negative dimension length
% Test 6:  Empty set length.

error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% DIMDEF
%
% Test 1
testid = 'Test 1';
[xdimid, status] = mexnc ( 'dimdef', ncid, 'x', 20 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[status] = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

[dimid, status] = mexnc ( 'inq_dimid', ncid, 'x' );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if dimid ~= xdimid
	err_msg = sprintf ( '%s:  INQ_DIMID did not validate DIMDEF\n', mfilename, ncerr );
	error ( err_msg );
end

%
% try a bad ncid
status = mexnc ( 'redef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

%
% DIMDEF
% Test 2:  Bad ncid.
testid = 'Test 2';
[xdimid, status] = mexnc ( 'dimdef', -3, 'x', 20 );
if ( status == 0 )
	err_msg = sprintf ( '%s:  %s:   succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end

% Test 3:  Empty string name.
testid = 'Test 3';
try
	[xdimid, status] = mexnc ( 'dimdef', ncid, '', 20 );
	err_msg = sprintf ( '%s:  %s:   succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end



% Test 4:  Empty set name.
testid = 'Test 4';
try
	[xdimid, status] = mexnc ( 'dimdef', ncid, [], 20 );
	error_condition = 1;
end
if error_condition
	err_msg = sprintf ( '%s:  %s failed to throw an exception.\n', mfilename, testid );
	error ( err_msg );
end


% Test 5:  Negative dimension length
testid = 'Test 5';
[xdimid, status] = mexnc ( 'dimdef', ncid, 'x2', -5 );
if ( status == 0 )
	err_msg = sprintf ( '%s:  %s:   succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end


% Test 6:  Empty set length.
try
	[xdimid, status] = mexnc ( 'dimdef', ncid, 'x3', [] );
	err_msg = sprintf ( '%s:  %s:   succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end


status = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

status = mexnc ( 'close', ncid );
if status, error ( mexnc('strerror',status) ), end

fprintf ( 1, 'DIMDEF succeeded.\n' );


return














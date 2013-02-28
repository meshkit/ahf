function test_redef_def_dim ( ncfile )
% TEST_REDEF_DEF_DIM
%
% Tests DEF_DIM by defining a new dimension.  Then tests
% REDEF by defining another dimension.
%
% Test 1:  Define a dimension.
% Test 2:  Bad ncid.
% Test 3:  ncid = []
% Test 4:  ncid is non numeric
% Test 5:  Dimension name already exists.
% Test 6:  Dimension name is ''
% Test 7:  Dimension name is []
% Test 8:  Dimension name is non character
% Test 9:  dim length == []
% Test 10:  dim length is negative
% Test 11:  dim length is non numeric
% Test 12:  REDEF:  ncid is []
% Test 13:  REDEF:  ncid is non numeric

error_condition = 0;

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status < 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% DIMDEF
% Test 1:  Define a dimension.
testid = 'Test 1';
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

%
% ENDEF
[status] = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

%
% REDEF
[status] = mexnc ( 'redef', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

[ydimid, status] = mexnc ( 'def_dim', ncid, 'y', 24 );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end




% Test 2:  Bad ncid.
testid = 'Test 2';
[xdimid, status] = mexnc ( 'def_dim', -2000, 'a1', 25 );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 3:  ncid = []
testid = 'Test 3';
try
	[xdimid, status] = mexnc ( 'def_dim', [], 'a1', 25 );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 4:  ncid is non numeric
testid = 'Test 4';
try
	[xdimid, status] = mexnc ( 'def_dim', 'ncid', 'a1', 25 );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end






% Test 5:  Dimension name already exists.
testid = 'Test 5';
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 25 );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 6:  Dimension name is ''
testid = 'Test 6';
try
	[xdimid, status] = mexnc ( 'def_dim', ncid, '', 25 );
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 7:  Dimension name is []
testid = 'Test 7';
try
	[xdimid, status] = mexnc ( 'def_dim', ncid, [], 25 );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 8:  Dimension name is non character
testid = 'Test 8';
try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 25, 25 );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 9:  dim length == []
testid = 'Test 9';
try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'b1', [] );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end



% Test 10:  dim length is negative
testid = 'Test 10';
[xdimid, status] = mexnc ( 'def_dim', ncid, 'b1', -25 );
if ( status == 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end





% Test 11:  dim length is non numeric
testid = 'Test 11';
try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'b3', 'wardrobe malfunction' );
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end


% Test 12:  REDEF:  ncid is []
testid = 'Test 12';
try
	[status] = mexnc ( 'redef', [] );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end




% Test 13:  REDEF:  ncid is non numeric
testid = 'Test 13';
try
	[status] = mexnc ( 'redef', 'ncid' );
	error_condition = 1;
end
if ( error_condition == 1 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid, ncerr );
	error ( err_msg );
end




status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end

fprintf ( 1, 'DEF_DIM succeeded.\n' );
fprintf ( 1, 'END_DEF succeeded.\n' );
fprintf ( 1, 'REDEF succeeded.\n' );


return













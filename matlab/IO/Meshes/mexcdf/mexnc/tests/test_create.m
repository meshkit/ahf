function test_create ( ncfile )
% Tests run are open with
% Test 1:   nc_clobber_mode
% Test 2:   nc_noclobber_mode
% Test 3:   clobber and share and 64 bit offset
% Test 4:  share mode.  Should also clobber it.
% Test 5:  share | 64bit_offset
% Test 6:  64 bit offset.  Should also clobber it.
% Test 7:  noclobber mode.  Should not succeed.
% Test 8:  only one input, should not succeed
% Test 9:  Filename is empty
% Test 10:  mode argument not supplied
% Test 11:  mode argument is 'clobber'.  Deprecated, please don't use this.
% Test 12:  mode argument is 'noclobber'.  Deprecated, please don't use this.
%

if nargin == 0
	ncfile = 'foo.nc';
end

error_condition = 0;

%
% Test 1:   nc_clobber_mode
testid = 'Test 1';
[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	error ( 'CLOSE failed with nc_clobber_mode' );
end





%
% Test 2:   nc_noclobber_mode | nc_share_mode
testid = 'Test 2';
mode = bitor ( nc_clobber_mode, nc_share_mode );
[ncid, status] = mexnc ( 'create', ncfile, mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_clobber_mode | nc_share_mode' );
end




%
% Test 3:   clobber and share and 64 bit offset
testid = 'Test 3';
mode = bitor ( nc_clobber_mode, nc_share_mode );
mode = bitor ( mode, nc_64bit_offset_mode );
[ncid, status] = mexnc ( 'create', ncfile, mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_clobber_mode | nc_share_mode | nc_64bit_offset_mode' );
end


%
% Test 4:  share mode.  Should also clobber it.
testid = 'Test 4';
[ncid, status] = mexnc ( 'create', ncfile, nc_share_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_share_mode' );
end


%
% Test 5:  share | 64bit_offset
testid = 'Test 5';
mode = bitor ( nc_share_mode, nc_64bit_offset_mode );
[ncid, status] = mexnc ( 'create', ncfile, mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_share_mode | nc_64bit_offset_mode' );
end



%
% Test 6:  64 bit offset.  Should also clobber it.
testid = 'Test 6';
[ncid, status] = mexnc ( 'create', ncfile, nc_64bit_offset_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end
status = mexnc ( 'close', ncid );
if ( status < 0 )
	error ( 'CLOSE failed with nc_64bit_offset_mode' );
end


%
% Test 7:  noclobber mode.  Should not succeed.
[ncid, status] = mexnc ( 'create', ncfile, nc_noclobber_mode );
if ( status == 0 )
	msg = sprintf ( '%s:  ''create'' succeeded on nc_noclobber_mode, should have failed\n', mfilename );
	error ( msg );
end


%
% Test 8:  only one input, should not succeed.  Throws an exception, 
%          because there are way too few arguments.
testid = 'Test 8';
try
	[ncid, status] = mexnc ( 'create' );
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
catch	
	;
end





%
% Test 9:  Filename is empty
testid = 'Test 9';
try
	[ncid, status] = mexnc ( 'create', '', nc_clobber_mode );
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
end


%
% Test 10:  Only two arguments.
testid = 'Test 10';
[ncid, status] = mexnc ( 'create', 'foo2.nc' );
if ( status ~= 0 )
	msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, mexnc ( 'strerror', status ) );
	error ( msg );
end
status = mexnc ( 'close', ncid );
if status, error ( mexnc ( 'strerror', status ) ), end


fprintf ( 'CREATE succeeded.\n' );



test_11 ( ncfile );
test_12 ( ncfile );


return


function test_11 ( ncfile )

[ncid, status] = mexnc ( 'create', ncfile, 'clobber' );
if ( status ~= 0 ), error ( mexnc ( 'strerror', status ) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc ( 'strerror', status ) ), end

return






function test_12 ( ncfile )

delete ( ncfile );

[ncid, status] = mexnc ( 'create', ncfile, 'noclobber' );
if ( status ~= 0 ), error ( mexnc ( 'strerror', status ) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc ( 'strerror', status ) ), end

return






%
% Test 11:  3rd argument is not a valid mode
testid = 'Test 11';
[ncid, status] = mexnc ( 'create', ncfile, -5 );
if ( status == 0 )
	msg = sprintf ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid );
	error ( msg );
end




return

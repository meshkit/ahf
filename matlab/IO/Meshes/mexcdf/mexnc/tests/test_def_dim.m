function test_def_dim ( ncfile )
% TEST_DEF_DIM
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


test_001 ( ncfile );
test_002 ( ncfile );
test_003 ( ncfile );
test_004 ( ncfile );
test_005 ( ncfile );
test_006 ( ncfile );
test_007 ( ncfile );
test_008 ( ncfile );
test_009 ( ncfile );
test_010 ( ncfile );
test_011 ( ncfile );

fprintf ( 1, 'DEF_DIM succeeded.\n' );




function create_ncfile ( ncfile )

[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return







function test_001 ( ncfile )
% Define a dimension.
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

%
% Reopen the file and check for it.
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

[xdimid, status] = mexnc ( 'INQ_DIMID', ncid, 'x' );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


return










function test_002 ( ncfile )
% Call DEF_DIM with a bad ncid.
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

[xdimid, status] = mexnc ( 'def_dim', -2000, 'a1', 25 );
if ( status == 0 ), error('succeeded when it should have failed'), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return





function test_003 ( ncfile )
% Call DEF_DIM with a bad ncid of [].
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', [], 'a1', 25 );
	error('succeeded when it should have failed');
end


status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return






function test_004 ( ncfile )
% Call DEF_DIM with non-numeric ncid
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', 'ncid', 'a1', 25 );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_005 ( ncfile )
% Try to define a dimension that already exists.
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

%
% Reopen the file and try to define another x dimension
[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

[xdimid2, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status == 0 ), error('succeeded when it should have failed'), end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end


return







function test_006 ( ncfile )
% Negative test:  dimname is ''
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, '', 20 );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return







function test_007 ( ncfile )
% Negative test:  dimname is []
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, [], 20 );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_008 ( ncfile )
% Negative test:  dimname is non-character
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 20, 20 );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return







function test_009 ( ncfile )
% Negative test:  dimlength is []
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', [] );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_010 ( ncfile )
% Negative test:  dimlength is negative
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', -1 );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return








function test_011 ( ncfile )
% Negative test:  dimlength is non-numeric
%

create_ncfile ( ncfile );

[ncid, status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 ), error(mexnc('strerror',status)), end

try
	[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', '10' );
	error('succeeded when it should have failed');
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 ), error ( mexnc('strerror',status) ), end

return










return
















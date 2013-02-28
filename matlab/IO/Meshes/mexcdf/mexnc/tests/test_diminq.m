function test_dim_inq ( ncfile )
% TEST_DIM_INQ
%
% Tests number of dimensions, variables, global attributes, record dimension for
% foo.nc.  
%
% Tests bad ncid as well.
%
% Test 1:  Normal inquiry
% Test 2:  Bad ncid.
% Test 3:  Empty set ncid.
% Test 4:  Bad dimid.
% Test 5:  Empty set dimid.

%
% Create a netcdf file with
[ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 )
	error ( 'CREATE failed' );
end


%
% DIMDEF
[xdimid, status] = mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status ~= 0 )
	error ( 'DEF_DIM failed on X' );
end
[ydimid, status] = mexnc ( 'def_dim', ncid, 'y', 24 );
if ( status ~= 0 )
	error ( 'DEF_DIM failed on y' );
end
[zdimid, status] = mexnc ( 'def_dim', ncid, 'z', 32 );
if ( status ~= 0 )
	error ( 'DEF_DIM failed on z' );
end


%
% ENDEF
[status] = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
	error ( 'ENDEF failed with write' );
end


%
% dimension 0 should have name 'x', length 20
% Test 1:  Normal inquiry
testid = 'Test 1';
[name, length, status] = mexnc('DIMINQ', ncid, xdimid);
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  %s:  ''%s''\n', mfilename, testid, ncerr );
	error ( err_msg );
end

if ~strcmp ( name, 'x' )
	msg = sprintf ( 'DIMINQ returned ''%s'' as a name, but it should have been ''x''', name );
	error ( msg );
end
if ( length ~= 20 )
	msg = sprintf ( 'DIMINQ returned %d as x''s length, but it should have been 20', length );
	error ( msg );
end


% Test 2:  Bad ncid.
testid = 'Test 2';
[name, length, status] = mexnc('DIMINQ', -5, xdimid);
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end





% Test 3:  Empty set ncid.
testid = 'Test 2';
try
	[name, length, status] = mexnc('DIMINQ', [], xdimid);
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end





% Test 4:  Bad dimid.
testid = 'Test 4';
[name, length, status] = mexnc('DIMINQ', ncid, -5000);
if ( status >= 0 )
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end




% Test 5:  Empty set dimid.
testid = 'Test 5';
try
	[name, length, status] = mexnc('DIMINQ', ncid, []);
	err_msg = sprintf ( '%s:  %s:  succeeded when it should have failed.\n', mfilename, testid );
	error ( err_msg );
end





fprintf ( 1, 'DIMINQ succeeded\n' );







status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	error ( 'CLOSE failed on nowrite' );
end



return













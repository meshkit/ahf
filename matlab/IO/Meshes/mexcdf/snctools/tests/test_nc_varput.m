function test_nc_varput ( ncfile )
% TEST_NC_VARPUT:
%
%
% Generic Tests, should all fail gracefully.
% Test 001:  pass 0 arguments into nc_varput.
% Test 002:  pass 1 arguments into nc_varput.
% Test 003:  pass 2 arguments into nc_varput.
% Test 004:  bad filename into nc_varput.
% Test 005:  bad varname into nc_varput.
% Test 006:  try to write a 2D matrix to a singleton
% Test 007:  try to write a 2D matrix to a 2D var using 'put_var', 
%            but having the wrong size
% Test 008:  try to write a 2D matrix to a 2D var using 'put_vara', 
%            but having the wrong size
% Test 009:  try to write a 2D matrix to a 2D var using 'put_vars', 
%            but having the wrong size
% Test 010:  try to write a 2D matrix to a 2D var using 'put_vara',
%            but with too long of a count argument
% Test 011:  try to write a 2D matrix to a 2D var using 'put_vars',
%            but with too long of a stride argument
% Test 012:  try to write a 2D matrix to a 2D var using 'put_vars',
%            but with too long of a start, count, stride argument
% Test 013:  try a bad start index
%            
%            
%
% put_var1
% Test 100:  write to a singleton variable and read it back.
% Test 101:  write to a 1D variable with just a count
% Test 102:  write to a 1D variable with a bad count
% Test 103:  write to a 1D variable with a good count
% Test 104:  write to a 1D variable with a bad stride
% Test 105:  write to a 1D variable with a good stride.
% Test 106:  write more than 1 datum to a singleton variable.  This should fail.
% Test 107:  write 1 datum to a singleton variable, bad start.  Should fail.
% Test 108:  write 1 datum to a singleton variable, bad count.  Should fail.
% Test 109:  write 1 datum to a singleton variable, give a stride.  Should fail.
%
% put_var
% Test 200:  using put_var, write all the data to a 2D dataset.
% Test 201:  using put_vara, write a chunk of the data to a 2D dataset.
% Test 202:  using put_vara, write a chunk of data to a 2D dataset.
% Test 203:  using put_vars, write a chunk of data to a 2D dataset.
% Test 204:  write too much to a 2D dataset (using put_var).  Should fail.
% Test 205:  write too little to a 2D dataset (using put_var).  Should fail.
% Test 206:  use put_vara, write with a bad offset.  Should fail.
% Test 207:  use put_vars, write with a bad start.  Should fail.
% Test 208:  use put_vara, write with a bad count.  Should fail.
% Test 209:  use put_vars, write with a bad stride.  Should fail.
%
% Test 301:  test reading with scale factors, add offsets.
% Test 302:  test writing with scale factors, add offsets.
% Test 303:  test reading with scale factor, no add offset.
% Test 304:  test writing/reading with _FillValue
% Test 305:  test reading with missing_value
% Test 306:  test reading with floating point scale factor
% Test 307:  test with _FillValue and missing_value
%
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_varput.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_VARGET, NC_VARPUT:  starting test suite...\n' );
if nargin == 0
	ncfile = 'foo.nc';
end


create_test_file ( ncfile );

test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'i_do_not_exist.nc' );
test_005 ( ncfile );
test_006 ( ncfile );
test_007 ( ncfile );
test_008 ( ncfile );
test_009 ( ncfile );
test_010 ( ncfile );
test_011 ( ncfile );

test_100 ( ncfile );
test_101 ( ncfile );
test_102 ( ncfile );
test_103 ( ncfile );
test_104 ( ncfile );
test_105 ( ncfile );

test_106 ( ncfile );
test_107 ( ncfile );
test_108 ( ncfile );
test_109 ( ncfile );


test_200 ( ncfile );
test_201 ( ncfile );
test_202 ( ncfile );
test_203 ( ncfile );

test_204 ( ncfile );
test_205 ( ncfile );
test_206 ( ncfile );

test_207 ( ncfile );
test_208 ( ncfile );
test_209 ( ncfile );


test_301 ( ncfile );
test_302 ( ncfile );
test_303 ( ncfile );
test_304 ( ncfile );
test_305 ( ncfile );
test_306 ( ncfile );
test_307 ( ncfile );

return





function create_test_file ( ncfile, arg2 )

if snctools_use_tmw
    %
    % ok, first create the first file
    ncid_1 = netcdf.create(ncfile, nc_clobber_mode );
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    xdimid = netcdf.defDim(ncid_1, 'x', len_x );
    
    %
    % Create a fixed dimension.  
    len_y = 6;
    ydimid = netcdf.defDim(ncid_1, 'y', len_y );
    
    netcdf.close(ncid_1);
elseif snctools_use_mexnc
    %
    % ok, first create the first file
    [ncid_1, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        msg = sprintf ( '%s:  ''create'' failed, error message '' %s ''\n', mfilename, ncerr_msg );
        error ( msg );
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid_1, 'x', len_x );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        msg = sprintf ( '%s:  ''def_dim'' failed on dim x, file %s, error message '' %s ''\n', mfilename, ncfile, ncerr_msg );
        error ( msg );
    end
    
    %
    % Create a fixed dimension.  
    len_y = 6;
    [ydimid, status] = mexnc ( 'def_dim', ncid_1, 'y', len_y );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        msg = sprintf ( '%s:  ''def_dim'' failed on dim y, file %s, error message '' %s ''\n', mfilename, ncfile, ncerr_msg );
        error ( msg );
    end
    
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid_1 );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
else
	error('No mexnc or native matlab support, this test cannot be run.');
end

%
% Add a singleton
varstruct.Name = 'test_singleton';
varstruct.Nctype = 'double';
varstruct.Dimension = [];

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'test_1D';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'y' };

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'test_2D';
varstruct.Nctype = 'double';
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    varstruct.Dimension = { 'x', 'y' };
else
    varstruct.Dimension = { 'y', 'x' };
end

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'test_2D_float';
varstruct.Nctype = 'float';
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    varstruct.Dimension = { 'x', 'y' };
else
    varstruct.Dimension = { 'y', 'x' };
end

nc_addvar ( ncfile, varstruct );


clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );
return












function test_001 ( ncfile )

try
    nc_varput;
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return



function test_002 ( ncfile )
try
    nc_varput ( ncfile );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end
return


function test_003 ( ncfile )

try
    nc_varput ( ncfile, 'test_2d' );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return



















function test_106 ( ncfile )

input_data = [3.14159; 2];
nc_varput ( ncfile, 'test_1D', input_data, 0, 2, 2 );
output_data = nc_varget ( ncfile, 'test_1D', 0, 2, 2 );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data.\n', mfilename );
    error ( msg );
end

return




function test_004 ( ncfile )

try
    nc_varput ( ncfile, 'test_2d' );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return






function test_005 ( ncfile )

try
    nc_varput ( ncfile, 'bad', 5 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return







function test_006 ( ncfile )

try
    nc_varput ( ncfile, 'test_singleton', [2 1] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return







function test_007 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(7,4) );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_008 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(3,4), [0 0], [3 3] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_009 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(3,2), [0 0], [3 2], [2 2] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_010 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(6,4), [0 0], [6 4 1] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_011 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(3,2), [0 0], [3 2], [2 2 1] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_012 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(3,2), [0 0 0], [3 2 1], [2 2 1] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return





function test_013 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(6,4), [1 0], [6 4] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return






function test_021 ( ncfile )

try
    nc_varput ( ncfile, 'test_2D', ones(3,2), [0 0 0], [3 2], [2 2 1] );
    msg = sprintf ( '%s:  test failed, ''%s''.\n', mfilename, lasterr );
    error ( msg );
end

return







function test_100 ( ncfile )


input_data = 3.14159;
nc_varput ( ncfile, 'test_singleton', input_data );
output_data = nc_varget ( ncfile, 'test_singleton' );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data.\n', mfilename );
    error ( msg );
end

return




function test_101 ( ncfile )

input_data = 3.14159;
try
    nc_varput ( ncfile, 'test_1D', input_data, 8 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should have failed.\n', mfilename );
    error ( msg );
end

return




function test_102 ( ncfile )

input_data = 3.14159;
try
    nc_varput ( ncfile, 'test_1D', input_data, 4, 2 );
    msg = sprintf ( '%s:  nc_varput succeeded in when it should have failed.\n', mfilename );
    error ( msg );
end

return







function test_103 ( ncfile )

input_data = 3.14159;
nc_varput ( ncfile, 'test_1D', input_data, 0, 1 );
output_data = nc_varget ( ncfile, 'test_1D', 0, 1 );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data.\n', mfilename );
    error ( msg );
end

return




function test_104 ( ncfile )

input_data = [3.14159; 2];
try
    nc_varput ( ncfile, 'test_1D', input_data, 0, 2, 8 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should have failed.\n', mfilename );
    error ( msg );
end


return





function test_105 ( ncfile )

input_data = [3.14159 2];
try
    nc_varput ( ncfile, 'test_singleton', input_data );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return







function test_107 ( ncfile )

input_data = 3.14159;
try
    nc_varput ( ncfile, 'test_singleton', input_data, 4, 1 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return





function test_108 ( ncfile )

input_data = 3.14159;
try
    nc_varput ( ncfile, 'test_singleton', input_data, 0, 2 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return








function test_109 ( ncfile )

input_data = 3.14159;
try
    nc_varput ( ncfile, 'test_singleton', input_data, 0, 1, 1 );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return







function test_200 ( ncfile )

input_data = [1:24];

count = nc_varsize(ncfile,'test_2D');
input_data = reshape(input_data,count);
nc_varput ( ncfile, 'test_2D', input_data );
output_data = nc_varget ( ncfile, 'test_2D' );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data \n', mfilename );
    error ( msg );
end

return







function test_201 ( ncfile )

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz-1;

input_data = [1:prod(count)];

input_data = reshape(input_data,count);
nc_varput ( ncfile, 'test_2D', input_data, start, count );
output_data = nc_varget ( ncfile, 'test_2D', start, count );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data .\n', mfilename );
    error ( msg );
end

return





function test_202 ( ncfile )

sz = nc_varsize(ncfile,'test_2D');
start = [1 1];
count = sz-1;

input_data = [1:prod(count)] - 5;
input_data = reshape(input_data,count);

nc_varput ( ncfile, 'test_2D', input_data, start, count );
output_data = nc_varget ( ncfile, 'test_2D', start, count );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data .\n', mfilename );
    error ( msg );
end


return












function test_203 ( ncfile )

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz/2;
stride = [2 2];

input_data = [1:prod(count)];

input_data = reshape(input_data,count);
nc_varput ( ncfile, 'test_2D', input_data, start, count, stride );
output_data = nc_varget ( ncfile, 'test_2D', start, count, stride );

ddiff = abs(input_data - output_data);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data.\n', mfilename );
    error ( msg );
end

return








function test_204 ( ncfile )

input_data = [1:49];
input_data = reshape(input_data,7,7);
try
    nc_varput ( ncfile, 'test_2D', input_data );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end


return






function test_205 ( ncfile )

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz-1;

input_data = [1:prod(count)];
input_data = reshape(input_data,count);
try
    nc_varput ( ncfile, 'test_2D', input_data );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end

return






function test_206 ( ncfile )
% write with a bad offset

sz = nc_varsize(ncfile,'test_2D');
start = [1 1];
count = sz;

input_data = [1:prod(count)];
input_data = reshape(input_data,count);
try
    nc_varput ( ncfile, 'test_2D', input_data, start, count );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end
return








function test_207 ( ncfile )
% write using put_vars with a bad offset

sz = nc_varsize(ncfile,'test_2D');
start = [1 1];
count = sz/2;
stride = [2 2];

input_data = [1:prod(count)] + 3.14159;
input_data = reshape(input_data,count);

try
    nc_varput ( ncfile, 'test_2D', input_data, start, count, stride);
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end
return






function test_208 ( ncfile )
% vara with bad count
sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz+1;

input_data = [1:prod(count)] + 3.14159;
input_data = reshape(input_data,count);
try
    nc_varput ( ncfile, 'test_2D', input_data, start, count );
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end
return






function test_209 ( ncfile )

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz/2;
stride = [3 3];

input_data = [1:prod(count)] + 3.14159;
input_data = reshape(input_data,count);
try
    nc_varput ( ncfile, 'test_2D', input_data, start, count, stride);
    msg = sprintf ( '%s:  nc_varput succeeded when it should not have.\n', mfilename );
    error ( msg );
end
return





function test_301 ( ncfile )

%
% Write some data, then put a scale factor of 2 and add offset of 1.  The
% data read back should be twice as large plus 1.
create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);

nc_varput ( ncfile, 'test_2D', input_data );
nc_attput ( ncfile, 'test_2D', 'scale_factor', 2.0 );
nc_attput ( ncfile, 'test_2D', 'add_offset', 1.0 );
output_data = nc_varget ( ncfile, 'test_2D' );

ddiff = abs(input_data - (output_data-1)/2);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data in Test 13.\n', mfilename );
    error ( msg );
end
return





function test_302 ( ncfile )
%
% Put a scale factor of 2 and add offset of 1.
% Write some data, 
% Put a scale factor of 4 and add offset of 2.
% data read back should be twice as large 
create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);


nc_attput ( ncfile, 'test_2D', 'scale_factor', 2.0 );
nc_attput ( ncfile, 'test_2D', 'add_offset', 1.0 );
nc_varput ( ncfile, 'test_2D', input_data );
nc_attput ( ncfile, 'test_2D', 'scale_factor', 4.0 );
nc_attput ( ncfile, 'test_2D', 'add_offset', 2.0 );
output_data = nc_varget ( ncfile, 'test_2D' );
ddiff = abs(input_data - (output_data)/2);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data .\n', mfilename );
    error ( msg );
end
return









function test_303 ( ncfile )
%
% Put a scale factor of 2 and no add offset.
% Write some data.  
create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);


nc_attput ( ncfile, 'test_2D', 'scale_factor', 2.0 );
nc_varput ( ncfile, 'test_2D', input_data );

%
% Now change the scale_factor, doubling it.
nc_attput ( ncfile, 'test_2D', 'scale_factor', 4.0 );
output_data = nc_varget ( ncfile, 'test_2D' );

if output_data(1) ~= 2
    msg = sprintf ( '%s:  input data ~= output data .\n', mfilename );
    error ( msg );
end
return








function test_304 ( ncfile )

create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);


input_data(1,1) = NaN;

nc_attput ( ncfile, 'test_2D', '_FillValue', -1 );
nc_varput ( ncfile, 'test_2D', input_data );

%
% Now change the _FillValue, to -2.  
nc_attput ( ncfile, 'test_2D', '_FillValue', -2 );

%
% Now read the data back.  Should have a -1 in position (1,1).
output_data = nc_varget ( ncfile, 'test_2D' );

if output_data(1) ~= -1 
    msg = sprintf ( '%s:  input data ~= output data .\n', mfilename );
    error ( msg );
end
return









function test_305 ( ncfile )

create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);


input_data(1,1) = NaN;

nc_attput ( ncfile, 'test_2D', 'missing_value', -1 );
nc_varput ( ncfile, 'test_2D', input_data );

%
% Now change the _FillValue, to -2.  
nc_attput ( ncfile, 'test_2D', '_FillValue', -2 );

%
% Now read the data back.  Should have a NaN in position (1,1).
output_data = nc_varget ( ncfile, 'test_2D' );

if ~isnan(output_data(1,1))
    msg = sprintf ( '%s:  output data is not correct.\n', mfilename );
    error ( msg );
end
return






% Read from a single precision dataset with a single precision scale factor.
% Should still produce single precision.
function test_306 ( ncfile )

%
% Write some data, then put a scale factor of 2 and add offset of 1.  The
% data read back should be twice as large plus 1.
create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = rand(1,prod(count));
input_data = reshape(input_data,count);


scale_factor = single(0.5);
add_offset = single(1.0);
nc_attput ( ncfile, 'test_2D_float', 'scale_factor', scale_factor );
nc_attput ( ncfile, 'test_2D_float', 'add_offset', add_offset );
nc_varput ( ncfile, 'test_2D_float', input_data );
output_data = nc_varget ( ncfile, 'test_2D_float' );

ddiff = abs(input_data - output_data);
if any( find(ddiff > 1e-6) )
    msg = sprintf ( 'input data ~= output data.\n' );
    error ( msg );
end

return


%
% Test a fill value / missing value conflict.  The fill value should take precedence.
function test_307 ( ncfile )

create_test_file ( ncfile );

sz = nc_varsize(ncfile,'test_2D');
start = [0 0];
count = sz;
input_data = [1:prod(count)];
input_data = reshape(input_data,count);


input_data(1,1) = NaN;

nc_attput ( ncfile, 'test_2D', '_FillValue', -1 );
nc_attput ( ncfile, 'test_2D', 'missing_value', -1 );
nc_varput ( ncfile, 'test_2D', input_data );


%
% Now read the data back.  Should have a NaN in position (1,1).
output_data = nc_varget ( ncfile, 'test_2D' );

if ~isnan(output_data(1,1))
    msg = sprintf ( '%s:  output data is not correct.\n', mfilename );
    error ( msg );
end
return







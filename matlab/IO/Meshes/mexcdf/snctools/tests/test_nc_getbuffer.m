function test_nc_getbuffer ( )
% TEST_NC_GETBUFFER
%
% Relies upon nc_addvar, nc_addnewrecs, nc_add_dimension
%
% test 1:  no input arguments, should fail
% test 2:  2 inputs, 2nd is not a cell array, should fail
% test 3:  3 inputs, 2nd and 3rd are not numbers, should fail
% test 4:  4 inputs, 2nd is not a cell array, should fail
% test 5:  4 inputs, 3rd and 4th are not numbers, should fail
% test 6:  1 input, 1st is not a file, should fail.
% test 7:  5 inputs, should fail
% test 8:  1 input, an empty netcdf with no variables, should fail
%          because no record variable was found
%
% test 9:  1 input, 5 record variables. Should succeed.
% test 10:  2 inputs, same netcdf file as 9.  Restrict output to two
%           of the variables.  Should succeed.
% test 11:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range, which is given as valid.
% test 12:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  Start is negative number.  Result 
%           should be the last few "count" records.
% test 13:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  count is negative number.  Result 
%           should be everything from start to "end - count"
% test 14:  4 inputs.  Otherwise the same as test 11.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_getbuffer.m 2515 2008-07-03 20:36:38Z johnevans007 $
% $LastChangedDate: 2008-07-03 16:36:38 -0400 (Thu, 03 Jul 2008) $
% $LastChangedRevision: 2515 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_GETBUFFER:  starting test suite...\n' );
test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'testdata/empty.nc' );
test_005 ( 'testdata/empty.nc' );
test_006 ( 'testdata/empty.nc' );
test_007 ( 'testdata/empty.nc' );
test_008 ( 'testdata/empty.nc' );
test_009 ( 'testdata/getlast.nc' );
test_010 ( 'testdata/getlast.nc' );
test_011 ( 'testdata/getlast.nc' );
test_012 ( 'testdata/getlast.nc' );
test_013 ( 'testdata/getlast.nc' );
test_014 ( 'testdata/getlast.nc' );
return







function test_001 ( ncfile )
try
    nb = nc_getbuffer;
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return




function test_002 ( ncfile )
try
    nb = nc_getbuffer ( ncfile, 1 );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return




function test_003 ( ncfile )
try
    nb = nc_getbuffer ( ncfile, 'a', 'b' );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return





function test_004 ( ncfile )
try
    nb = nc_getbuffer ( ncfile, 1, 1, 2 );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return





function test_005 ( ncfile )
try
    nb = nc_getbuffer ( ncfile, cell(1), 'a', 'b' );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return





function test_006 ( ncfile )
try
    nb = nc_getbuffer ( 5 );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return





function test_007 ( ncfile )
try
    nb = nc_getbuffer ( ncfile, cell(1), 3, 4, 5 );
    msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return





function test_008 ( ncfile )
try
    nb = nc_getbuffer ( ncfile );
    msg = sprintf ( '%s:  : succeeded when it should have failed.\n', mfilename  );
    error ( msg );
end
return




function test_009 ( ncfile )

nb = nc_getbuffer ( ncfile );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    msg = sprintf ( '%s:  : output buffer did not have 4 fields.\n', mfilename  );
    error ( msg );
end
for j = 1:4
    fname = f{j};
    d = getfield ( nb, fname );
    if ( size(d,1) ~= 10 )
        msg = sprintf ( '%s:  : length of field %s in the output buffer was not 10.\n', mfilename  );
        error ( msg );
    end
end
return





function test_010 ( ncfile )

nb = nc_getbuffer ( ncfile, {'t1', 't2'} );

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
    msg = sprintf ( '%s:  : output buffer did not have 2 fields.\n', mfilename  );
    error ( msg );
end
for j = 1:2
    fname = f{j};
    d = getfield ( nb, fname );
    if ( length(d) ~= 10 )
        msg = sprintf ( '%s:  : length of field %s in the output buffer was not 10.\n', mfilename  );
        error ( msg );
    end
end
return






function test_011 ( ncfile )


nb = nc_getbuffer ( ncfile, 5, 3 );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    msg = sprintf ( '%s:  : output buffer did not have 5 fields.\n', mfilename  );
    error ( msg );
end


for j = 1:n
    fname = f{j};
    d = getfield ( nb, fname );
    if getpref('SNCTOOLS','PRESERVE_FVD',false) && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 3 )
        msg = sprintf ( '%s:  : length of field %s in the output buffer was not 10.\n', mfilename  );
        error ( msg );
    end
end

%
% t1 should be [5 6 7]
if any ( nb.t1 - [5 6 7]' )
    msg = sprintf ( '%s:  : t1 was not what we thought it should be.\n', mfilename  );
    error ( msg );
end
return







function test_012 ( ncfile )

nb = nc_getbuffer ( ncfile, -1, 3 );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    msg = sprintf ( '%s:  : output buffer did not have 4 fields.\n', mfilename  );
    error ( msg );
end
for j = 1:n
    fname = f{j};
    d = getfield ( nb, fname );
    if getpref('SNCTOOLS','PRESERVE_FVD',false) && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 3 )
        msg = sprintf ( '%s:  : length of field %s in the output buffer was not 10.\n', mfilename  );
        error ( msg );
    end
end

%
% t1 should be [7 8 9]
if any ( nb.t1 - [7 8 9]' )
    msg = sprintf ( '%s:  : t1 was not what we thought it should be.\n', mfilename  );
    error ( msg );
end
return







function test_013 ( ncfile )

nb = nc_getbuffer ( ncfile, 5, -1 );
%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    msg = sprintf ( 'output buffer did not have 4 fields.' );
    error ( msg );
end
for j = 1:n
    fname = f{j};
    d = getfield ( nb, fname );
    if getpref('SNCTOOLS','PRESERVE_FVD',false) && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 5 )
        msg = sprintf ( 'length of field %s in the output buffer was not 5.\n' );
        error ( msg );
    end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
    msg = sprintf ( 't1 was not what we thought it should be' );
    error ( msg );
end
return







function test_014 ( ncfile )

nb = nc_getbuffer ( ncfile, {'t1', 't2' }, 5, -1 );

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
    msg = sprintf ( 'output buffer did not have 2 fields.' );
    error ( msg );
end
for j = 1:n
    fname = f{j};
    d = getfield ( nb, fname );
    if ( size(d,1) ~= 5 )
        msg = sprintf ( 'length of field %s in the output buffer was not 10.', fname  );
        error ( msg );
    end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
    msg = sprintf ( 't1 was not what we thought it should be.' );
    error ( msg );
end
return





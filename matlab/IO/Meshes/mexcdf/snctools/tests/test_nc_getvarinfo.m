function test_nc_getvarinfo ( )
% TEST_NC_GETVARINFO:
%
% Depends upon nc_add_dimension, nc_addvar
%
% 1st set of tests should fail
% test 1:  no input arguments, should fail
% test 2:  one input
% test 3:  too many inputs
% test 4:  2 inputs, 1st is not a netcdf file
% test 5:  2 inputs, 2nd is not a netcdf variable
% test 6:  2 inputs, 1st is character, 2nd is numeric
% test 7:  2 inputs, 2nd is character, 1st is numeric
%
% 2nd set of tests should succeed
% test 8:  limited variable
% test 9:  unlimited variable
% test 10:  unlimited variable with one attribute


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_getvarinfo.m 2426 2007-11-11 03:56:45Z johnevans007 $
% $LastChangedDate: 2007-11-10 22:56:45 -0500 (Sat, 10 Nov 2007) $
% $LastChangedRevision: 2426 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 'NC_GETVARINFO:  starting test suite...\n' );

test_01 ( 'testdata/full.nc' );
test_02 ( 'testdata/full.nc' );
test_03 ( 'testdata/full.nc' );
test_04 ( 'testdata/full.nc' );
test_05 ( 'testdata/full.nc' );
test_06 ( 'testdata/full.nc' );
test_07 ( 'testdata/full.nc' );


test_08 ( 'testdata/getlast.nc' );
test_09 ( 'testdata/getlast.nc' );
test_10 ( 'testdata/getlast.nc' );



return











function test_01 ( ncfile )

try
	nb = nc_getvarinfo;
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end

return






function test_02 ( ncfile )

try
	nb = nc_getvarinfo ( ncfile );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end

return





function test_03 ( ncfile )
try
	nb = nc_getvarinfo ( ncfile, 't1' );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
catch
	;
end

return





function test_04 ( ncfile )

try
	nb = nc_getvarinfo ( 'iamnotarealfilenoreally', 't1' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end

return






function populate_ncfile ( ncfile );

%
% make all the variable definitions.
nc_add_dimension ( ncfile, 'ocean_time', 0 );
nc_add_dimension ( ncfile, 'x', 2 );
nc_add_dimension ( ncfile, 'y', 6 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'ocean_time';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
varstruct.Attribute(1).Name = 'test_att';
varstruct.Attribute(1).Value = 'dud';
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'y';
varstruct.Nctype = 'double';
varstruct.Dimension = [];
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'z';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'y', 'x' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'c';
varstruct.Nctype = 'char';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

return











function test_05 ( ncfile )

try
	nb = nc_getvarinfo ( ncfile, 't5' );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return









function test_06 ( ncfile )
try
	nb = nc_getvarinfo ( ncfile, 0 );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return




function test_07 ( ncfile )
try
	nb = nc_getvarinfo ( 0, 't1' );
	msg = sprintf ( '%s:  succeeded when it should have failed.\n', mfilename );
	error ( msg );
end
return




function test_08 ( ncfile )
v = nc_getvarinfo ( ncfile, 'x' );

if ~strcmp(v.Name, 'x' )
	msg = sprintf ( '%s:  Name was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Nctype~=6 )
	msg = sprintf ( '%s:  Nctype was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Unlimited~=0 )
	msg = sprintf ( '%s:  Unlimited was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Dimension)~=1 )
	msg = sprintf ( '%s:  Dimension was not correct.\n', mfilename  );
	error ( msg );
end
if ( ~strcmp(v.Dimension{1},'x') )
	msg = sprintf ( '%s:  Dimension was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Size~=2 )
	msg = sprintf ( '%s:  Size was not correct.\n', mfilename  );
	error ( msg );
end
if (numel(v.Size)~=1 )
	msg = sprintf ( '%s:  Rank was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Attribute)~=0 )
	msg = sprintf ( '%s:  Attribute was not correct.\n', mfilename  );
	error ( msg );
end

return





function test_09 ( ncfile )

v = nc_getvarinfo ( ncfile, 't1' );

if ~strcmp(v.Name, 't1' )
	msg = sprintf ( '%s:  Name was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Nctype~=6 )
	msg = sprintf ( '%s:  Nctype was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Unlimited~=1 )
	msg = sprintf ( '%s:  Unlimited was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Dimension)~=1 )
	msg = sprintf ( '%s:  Dimension was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Size~=10 )
	msg = sprintf ( '%s:  Size was not correct.\n', mfilename  );
	error ( msg );
end
if (numel(v.Size)~=1 )
	msg = sprintf ( '%s:  Rank was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Attribute)~=0 )
	msg = sprintf ( '%s:  Attribute was not correct.\n', mfilename  );
	error ( msg );
end

return







function test_10 ( ncfile )

v = nc_getvarinfo ( ncfile, 't4' );

if ~strcmp(v.Name, 't4' )
	msg = sprintf ( '%s:  Name was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Nctype~=6 )
	msg = sprintf ( '%s:  Nctype was not correct.\n', mfilename  );
	error ( msg );
end
if (v.Unlimited~=1 )
	msg = sprintf ( '%s:  Unlimited was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Dimension)~=2 )
	msg = sprintf ( '%s:  Dimension was not correct.\n', mfilename  );
	error ( msg );
end
if (numel(v.Size)~=2 )
	msg = sprintf ( '%s:  Rank was not correct.\n', mfilename  );
	error ( msg );
end
if (length(v.Attribute)~=1 )
	msg = sprintf ( '%s:  Attribute was not correct.\n', mfilename  );
	error ( msg );
end

return


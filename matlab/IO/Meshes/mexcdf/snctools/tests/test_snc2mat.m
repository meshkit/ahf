function test_ssnc2mat ( ncfile )
% TEST_SNC2MAT
% Relies upon nc_varput, nc_add_dimension, nc_addvar
%
% Tests
% Test 1:  netcdf file does not exist.
% Test 2:  try a pretty generic netcdf file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_snc2mat.m 2528 2008-11-03 23:06:25Z johnevans007 $
% $LastChangedDate: 2008-11-03 18:06:25 -0500 (Mon, 03 Nov 2008) $
% $LastChangedRevision: 2528 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
	ncfile = 'foo.nc';
end


fprintf ( 1, 'SNC2MAT:  starting test suite...\n' );
test_001 ( ncfile );
test_002 ( ncfile );
return











function test_001 ( ncfile )


%
% Test 1:  netcdf file does not exist.
matfile_name = [ ncfile '.mat' ];
try
	snc2mat ( 'bad.nc', matfile_name );
	format = '%s:  snc2mat succeeded with a bad netcdf file when it should have failed.\n';
	error ( format, mfilename);
end
return









function test_002 ( ncfile )

create_empty_file ( ncfile );
len_x = 4; len_y = 6;
nc_add_dimension ( ncfile, 'x', len_x );
nc_add_dimension ( ncfile, 'y', len_y );

clear varstruct;
varstruct.Name = 'z_double';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'y', 'x' };
nc_addvar ( ncfile, varstruct );




input_data = [1:1:len_y*len_x];
input_data = reshape ( input_data, len_y, len_x );

nc_varput ( ncfile, 'z_double', input_data );



matfile_name = [ ncfile '.mat' ];
snc2mat ( ncfile, matfile_name );


%
% now check it
d = load ( matfile_name );
output_data = d.z_double.data;



d = max(abs(output_data-input_data))';
if (any(d))
	error ( '%s:  values written by NC2MAT do not match what was retrieved by LOAD\n', mfilename  );
end
return












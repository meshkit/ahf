function test_nc_varget( )
% TEST_NC_VARGET:
%
%
% % test start and count
% Test 101:  read a single value from a 1D variable
% Test 102:  read a single value from a 2D variable
% Test 103:  read a 2x2 hyperslab from a 2D variable
% Test 140:  read a single value from a 1D variable (nc4)
%
% test full retrieval
% Test 200:  read from a singleton variable
% Test 201:  read a double precision variable
% Test 220:  read a float precision variable (nc4, java)
%
% % test start and count and stride
% Test 300:  read a double precision variable
%
%
% Test 401:  test reading a variable from an opendap URL
% Test 402:  test reading a variable from an opendap URL, regression
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_varget_varput.m 2394 2007-11-08 13:27:30Z johnevans007 $
% $LastChangedDate: 2007-11-08 08:27:30 -0500 (Thu, 08 Nov 2007) $
% $LastChangedRevision: 2394 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_VARGET:  starting test suite...\n' );

%create_test_file ( ncfile );


test_101 ( 'testdata/varget.nc' );
test_102 ( 'testdata/varget.nc' );
test_103 ( 'testdata/varget.nc' );

test_140 ( 'testdata/tst_pres_temp_4D_netcdf4.nc' );

test_200 ( 'testdata/varget.nc' );
test_201 ( 'testdata/varget.nc' );
test_220 ( 'testdata/tst_pres_temp_4D_netcdf4.nc' );

test_300 ( 'testdata/varget.nc' );

test_401;
test_402;

return





function test_401 ()
if snctools_use_java && getpref('SNCTOOLS','TEST_OPENDAP',true)
	url = 'http://motherlode.ucar.edu:8080/thredds/dodsC/nexrad/composite/1km/agg';
	fprintf ( 1, 'Testing remote URL access %s...\n', url );
	w = nc_varget ( url, 'y', [0], [1] );
end
return



%==============================================================================
% TEST_402
%
% Regression test.  If the URL is wrong, then the error message must give the
% name of the wrong url.   01-04-2007
% 
function test_402 ()
if snctools_use_java
	url = 'http://doesntexits:8080/thredds/dodsC/nexrad/composite/1km/agg';
	try
	    w = nc_varget ( url, 'y', [0], [1] );
	catch
	    [msg,id] = lasterr;
	    if ~strcmp(id, 'SNCTOOLS:nc_varget_java:fileOpenFailure')
	        error ( 'Error id ''%s'' was not expected.', id );
	    end
	    if ~findstr(msg, url)
	        error ( 'Error message did not contain the incorrect url.');
	    end
	end
end
return







function test_101 ( ncfile )

expData = 1.2;
actData = nc_varget ( ncfile, 'test_1D', 1, 1 );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    msg = sprintf ( 'input data ~= output data.' );
    error ( msg );
end

return








function test_102 ( ncfile )

expData = [1.5];
actData = nc_varget ( ncfile, 'test_2D', [2 2], [1 1] );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    msg = sprintf ( '%s:  input data ~= output data.\n', mfilename );
    error ( msg );
end

return




function test_103 ( ncfile )

expData = [1.5 2.1; 1.6 2.2];
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end
actData = nc_varget ( ncfile, 'test_2D', [2 2], [2 2] );

if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 4
    error ( 'rank of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return







%--------------------------------------------------------------------------
function test_140_backend_neutral ( actData )

expData = 30;
if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 1
    error ( 'rank of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return



function test_140 ( ncfile )

if snctools_use_java
    actData = nc_varget ( ncfile, 'latitude', 1, 1 );

    test_140_backend_neutral(actData);
    
end
return





function test_200 ( ncfile )


expData = 3.14159;
actData = nc_varget ( ncfile, 'test_singleton' );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return



function test_201 ( ncfile )


expData = [1:24];
expData = reshape(expData,6,4) / 10;

if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end

actData = nc_varget ( ncfile, 'test_2D' );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return




%---------------------------------------------------------------------------
function test_220_backend_neutral ( actData )

expData = [25 30 35 40 45 50];

if ndims(actData) ~= 2
    error ( 'rank of output data was not correct' );
end
if numel(actData) ~= 6
    error ( 'rank of output data was not correct' );
end
ddiff = abs(expData(:) - actData(:));
if any( find(ddiff > eps) )
    error ( 'input data ~= output data ' );
end

return



function test_220 ( ncfile )

if snctools_use_java
    actData = nc_varget ( ncfile, 'latitude');
	test_220_backend_neutral(actData);
end
return




function test_300 ( ncfile )


expData = [1:24];
expData = reshape(expData,6,4) / 10;
expData = expData(1:2:3,1:2:3);
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    expData = expData';
end

actData = nc_varget ( ncfile, 'test_2D', [0 0], [2 2], [2 2] );

ddiff = abs(expData - actData);
if any( find(ddiff > eps) )
    error ( 'input data ~= output data.\n'  );
end

return





function test_snctools()
% TEST_SNCTOOLS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_snctools.m 2586 2008-12-24 18:49:37Z johnevans007 $
% $LastChangedDate: 2008-12-24 13:49:37 -0500 (Wed, 24 Dec 2008) $
% $LastChangedRevision: 2586 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% switch off some warnings
mver = version('-release');
switch mver
    case {'11', '12'}
        error ( 'This version of MATLAB is too old, SNCTOOLS will not run.' );
    case {'13'}
        error ( 'R13 is not supported in this release of SNCTOOLS');
    otherwise
        warning('off', 'SNCTOOLS:nc_archive_buffer:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_datatype_string:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_diff:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_getall:deprecatedMessage' );
        warning('off', 'SNCTOOLS:snc2mat:deprecatedMessage' );
end


switch mver
    case {'14', '2006a', '2006b', '2007a', '2007b', '2008a'}
		fprintf ( 1, 'Your version of MATLAB is %s, SNCTOOLS will require MEXNC in order to run local I/O tests.\n', mver );
		pause(1);

    otherwise
		v = mexnc('inq_libvers');
		if ( v(1) == '4' )
			fprintf ( 1, 'Your version of MATLAB is %s, but you have a netcdf4-enabled version of the classic mex-file.  SNCTOOLS will use the classic mex-file to run all local I/O tests.\n\n\n', mver );
		else
			fprintf ( 1, 'Your version of MATLAB is %s, SNCTOOLS will use the MATLAB native netCDF package to run all local I/O tests.\n\n\n', mver );
		end

		pause(1);
		
end

if snctools_use_java
	fprintf ( 1, 'Good, looks like you have java support ready to go, we can test OPeNDAP URLs.\n\n\n' );
	pause(1);
end


run_backend_neutral_tests;
run_backend_mex_tests;

fprintf ( 1, '\nAll  possible tests for your configuration have been run.  Bye.\n\n' );

return




%----------------------------------------------------------------------
function run_mexnc_tests()

% Is mexnc ok?
mexnc_loc = which ( 'mexnc' );
mexnc_ok = ~isempty(which('mexnc'));

pause_duration = 3;
if ~mexnc_ok
    fprintf ( 1, 'MEXNC was not found, so the tests requiring mexnc\n' );
    fprintf ( 1, 'will not be run.\n\n' );
    return
end

fprintf ( 1, '\n' );
fprintf ( 1, 'Ok, we found mexnc.  ' );
fprintf ( 1, 'Remote OPeNDAP/mexnc tests ' );
if getpref('SNCTOOLS','TEST_REMOTE_MEXNC',false)
    fprintf ( 1, 'will ' );
    setpref('SNCTOOLS','TEST_REMOTE',true)
else
    fprintf ( 1, 'will NOT ' );
    setpref('SNCTOOLS','TEST_REMOTE',false)
end
fprintf ( 1, 'be run.\n  Starting tests in ' );
for j = 1:pause_duration
    fprintf ( 1, '%d... ', pause_duration - j + 1 );
    pause(1);
end
fprintf ( 1, '\n' );

run_backend_neutral_tests;
run_backend_mexnc_tests;


return


%----------------------------------------------------------------------
function run_all_tests()

fprintf ( 1, 'Ok, about to start testing in  ' );
pause_duration = 3;
for j = 1:pause_duration
    fprintf ( 1, '%d... ', pause_duration - j + 1 );
    pause(1);
end
fprintf ( 1, '\n' );

test_nc_attget;
test_nc_datatype_string;
test_nc_iscoordvar;
test_nc_isunlimitedvar;
test_nc_dump;
test_nc_getlast;
test_nc_isvar;
test_nc_varsize;
test_nc_getvarinfo;
test_nc_info;
test_nc_getbuffer;
test_nc_varget;
test_nc_getdiminfo;

test_nc_varput           ( 'test.nc' );
test_nc_add_dimension    ( 'test.nc' );
test_nc_addhist          ( 'test.nc' );
test_nc_addvar           ( 'test.nc' );
test_nc_attput           ( 'test.nc' );
test_nc_create_empty     ( 'test.nc' );
test_nc_varrename        ( 'test.nc' );
test_nc_addnewrecs       ( 'test.nc' );
test_nc_add_recs         ( 'test.nc' );
test_nc_archive_buffer   ( 'test.nc' );

test_snc2mat             ( 'test.nc' );
test_nc_getall           ( 'test.nc' );
test_nc_diff             ( 'test1.nc', 'test2.nc' );
test_nc_cat_a;


return




%----------------------------------------------------------------------
function run_tmw_tests()

% Is use_tmw ok?
tmw_ok = strcmp(version('-release'),'2008b') && getpref('SNCTOOLS','USE_TMW',false);
if ~tmw_ok
    return
end

fprintf ( 1, 'Ok, about to start TMW testing in  ' );
pause_duration = 3;
for j = 1:pause_duration
    fprintf ( 1, '%d... ', pause_duration - j + 1 );
    pause(1);
end
fprintf ( 1, '\n' );

run_backend_neutral_tests;
run_backend_mexnc_tests;

return





%----------------------------------------------------------------------
function run_backend_neutral_tests()

test_nc_attget;
test_nc_datatype_string;
test_nc_iscoordvar;
test_nc_isunlimitedvar;
test_nc_dump;
test_nc_getlast;
test_nc_isvar;
test_nc_varsize;
test_nc_getvarinfo;
test_nc_info;
test_nc_getbuffer;
test_nc_varget;
test_nc_getdiminfo;


return




%----------------------------------------------------------------------
function run_backend_mex_tests()

if ~(snctools_use_tmw || snctools_use_mexnc)
	fprintf ( 1, 'Cannot use native netcdf support or mexnc, no tests requiring netcdf output can be run.\n' );	
	return
end

test_nc_varput           ( 'test.nc' );
test_nc_add_dimension    ( 'test.nc' );
test_nc_addhist          ( 'test.nc' );
test_nc_addvar           ( 'test.nc' );
test_nc_attput           ( 'test.nc' );
test_nc_create_empty     ( 'test.nc' );
test_nc_varrename        ( 'test.nc' );
test_nc_addnewrecs       ( 'test.nc' );
test_nc_add_recs         ( 'test.nc' );
test_nc_archive_buffer   ( 'test.nc' );

test_snc2mat             ( 'test.nc' );
test_nc_getall           ( 'test.nc' );
test_nc_diff             ( 'test1.nc', 'test2.nc' );
test_nc_cat_a;



return


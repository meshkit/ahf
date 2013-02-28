function tf = nc_isvar ( ncfile, varname )
% NC_ISVAR:  determines if a variable is present in a netCDF file
%
% BOOL = NC_ISVAR(NCFILE,VARNAME) returns true if the variable VARNAME is 
% present in the netCDF file NCFILE.  Otherwise false is returned.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_isvar.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(2,2,nargin);
nargoutchk(1,1,nargout);

%
% Both inputs must be character
if nargin ~= 2
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'must have two inputs' );
end
if ~ischar(ncfile)
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'first argument must be character.' );
end
if ~ischar(varname)
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'second argument must be character.' );
end


nc_method = determine_retrieval_method(ncfile);

tf = nc_method(ncfile,varname);



%-------------------------------------------------------------------------
function retrieval_method = determine_retrieval_method(ncfile)
switch ( version('-release') )
	case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		can_use_tmw = false;
	otherwise
		can_use_tmw = true;
end

file_is_nc3 = exist(ncfile,'file') && isnc3(ncfile);
file_is_nc4 = exist(ncfile,'file') && isnc4(ncfile);
file_is_url = ~isempty(regexp(ncfile,'\<http[s]*'));
mexnc_available = (exist('mexnc') == 2);
java_available = (exist('NetcdfFile') == 8);

% Need this in order to determine if we can use java.
import ucar.nc2.*

if file_is_nc3
    % If the version is R2008b or later, use native matlab
    if can_use_tmw
        retrieval_method = @nc_isvar_tmw;
    elseif mexnc_available
        retrieval_method = @nc_isvar_mexnc;
    elseif java_available
        retrieval_method = @nc_isvar_java;
    else
        error('SNCTOOLS:nc_isvar:noRetrievalMethodAvailable', ...
              'Neither MATLAB, MEXNC, nor JAVA is available to retrieve data from your netcdf-3 file.');
    end

elseif file_is_url

    if java_available
        retrieval_method = @nc_isvar_java;
    else % just try mexnc
        retrieval_method = @nc_isvar_mexnc;
    end

elseif file_is_nc4

    if java_available && ~mexnc_available
        retrieval_method = @nc_isvar_java;
    elseif mexnc_available
        v = mexnc('inq_libvers');
        if (v(1) == '4')
            retrieval_method = @nc_isvar_mexnc;
        end
    end

end

if isempty(retrieval_method)
    error('SNCTOOLS:nc_isvar:noRetrievalMethodAvailable', ...
          'Neither MATLAB, MEXNC, nor JAVA is available to retrieve data from your file.');
end







%-----------------------------------------------------------------------
function bool = nc_isvar_tmw ( ncfile, varname )

ncid = netcdf.open(ncfile, nc_nowrite_mode );
try
	varid = netcdf.inqVarID(ncid,varname);
	bool = true;
catch myException
	bool = false;
end

netcdf.close(ncid);
return









%-----------------------------------------------------------------------
function bool = nc_isvar_mexnc ( ncfile, varname )

[ncid,status] = mexnc('open',ncfile, nc_nowrite_mode );
if status ~= 0
	ncerr = mexnc ( 'STRERROR', status );
	error ( 'SNCTOOLS:NC_ISVAR:MEXNC:OPEN', ncerr );
end


[varid,status] = mexnc('INQ_VARID',ncid,varname);
if ( status ~= 0 )
	bool = false;
elseif varid >= 0
	bool = true;
else
	error ( 'SNCTOOLS:NC_ISVAR:unknownResult', ...
	        'Unknown result, INQ_VARID succeeded, but returned a negative varid.  That should not happen.' );
end

mexnc('close',ncid);
return








%--------------------------------------------------------------------------
function bool = nc_isvar_java ( ncfile, varname )
% assume false until we know otherwise
bool = false;

import ucar.nc2.dods.*     
import ucar.nc2.*         
                         


%
% Try it as a local file.  If not a local file, try as
% via HTTP, then as dods
if exist(ncfile,'file')
	jncid = NetcdfFile.open(ncfile);
else
	try 
		jncid = NetcdfFile.open ( ncfile )
	catch
		try
			jncid = DODSNetcdfFile(ncfile);
		catch
			msg = sprintf ( 'Could not open ''%s'' as either a local file, a regular URL, or as a DODS URL.' );
			error ( 'SNCTOOLS:nc_varget_java:fileOpenFailure', msg );
		end
	end
end




jvarid = jncid.findVariable(varname);

%
% Did we find anything?
if ~isempty(jvarid)
	bool = true;
end

close(jncid);

return


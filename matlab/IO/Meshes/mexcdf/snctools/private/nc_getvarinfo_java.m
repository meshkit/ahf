function Dataset = nc_getvarinfo_java ( arg1, arg2 )
%
% This function handles the java case.

snc_turnoff_log4j;

switch ( class(arg1) )
case { 'ucar.nc2.NetcdfFile', 'ucar.nc2.Group', 'ucar.nc2.dods.DODSNetcdfFile' }
	Dataset = snc_java_varid_info ( arg2 );
case 'char'
	Dataset = get_varinfo_closed ( arg1, arg2 );
end

return





%===============================================================================
function Dataset = get_varinfo_closed ( ncfile, varname )

import ucar.nc2.dods.*     % import opendap reader classes
import ucar.nc2.*          % have to import this (NetcdfFile) as well for local reads
                           
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
			msg = sprintf ( 'Could not open ''%s'' as either a local file, a regular URL, or as a DODS URL.', ncfile );
			error ( 'SNCTOOLS:nc_varget_java:fileOpenFailure', msg );
		end
	end
end



jvarid = jncid.findVariable(varname);
if isempty(jvarid)
	close(jncid);
	msg = sprintf ('Could not locate variable %s', varname );
	snc_error ( 'SNCTOOLS:NC_GETVARINFO:badVariableName', msg );
end



Dataset = snc_java_varid_info ( jvarid );

close ( jncid );

return


%===============================================================================
function Dataset = get_varinfo_open ( jncid, jvarid )




%
% All the details are hidden here because we need the exact same
% functionality in nc_info.


return

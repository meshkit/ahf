function nc_varrename ( ncfile, old_variable_name, new_variable_name )
% NC_VARRENAME:  renames a NetCDF variable.
%
% NC_VARRENAME(NCFILE,OLD_VARNAME,NEW_VARNAME) renames a netCDF variable from
% OLD_VARNAME to NEW_VARNAME.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_varrename.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nargchk(3,3,nargin);
nargoutchk(0,0,nargout);

switch ( version('-release') )
	case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
    	nc_varrename_mexnc( ncfile, old_variable_name, new_variable_name )
	otherwise
    	nc_varrename_tmw( ncfile, old_variable_name, new_variable_name )
end


%--------------------------------------------------------------------------
function nc_varrename_tmw ( ncfile, old_variable_name, new_variable_name )
ncid=netcdf.open(ncfile,nc_write_mode);
try
    netcdf.reDef(ncid);
    varid = netcdf.inqVarID(ncid, old_variable_name);
    netcdf.renameVar(ncid, varid, new_variable_name);
    netcdf.endDef(ncid);
    netcdf.close(ncid);
catch myException
    netcdf.close(ncid);
    rethrow(myException);
end

%--------------------------------------------------------------------------
function nc_varrename_mexnc ( ncfile, old_variable_name, new_variable_name )
[ncid,status ]=mexnc('OPEN',ncfile,nc_write_mode);
if status ~= 0
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:OPEN', ncerr );
end


status = mexnc('REDEF', ncid);
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:REDEF', ncerr );
end


[varid, status] = mexnc('INQ_VARID', ncid, old_variable_name);
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ncerr );
end


status = mexnc('RENAME_VAR', ncid, varid, new_variable_name);
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:RENAME_VAR', ncerr );
end


status = mexnc('ENDDEF', ncid);
if status ~= 0
    mexnc('close',ncid);
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:ENDDEF', ncerr );
end


status = mexnc('close',ncid);
if status ~= 0
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:CLOSE', ncerr );
end



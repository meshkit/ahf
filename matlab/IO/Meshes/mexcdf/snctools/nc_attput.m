function nc_attput ( ncfile, varname, attribute_name, attval )
% NC_ATTPUT:  writes an attribute into a netCDF file
%     NC_ATTPUT(NCFILE,VARNAME,ATTNAME,ATTVAL) writes the data in ATTVAL to
%     the attribute ATTNAME of the variable VARNAME of the netCDF file NCFILE.
%     VARNAME should be the name of a netCDF VARIABLE, but one can also use the
%     mnemonic nc_global to specify a global attribute.  Do not use 'global'.
%
% The attribute datatype will match that of the class of ATTVAL.  So if
% if you want to have a 16-bit short integer attribute, make class of
% ATTVAL to be INT16.
%

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_attput.m 2559 2008-11-28 21:53:27Z johnevans007 $
% $LastChangedDate: 2008-11-28 16:53:27 -0500 (Fri, 28 Nov 2008) $
% $LastChangedRevision: 2559 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(4,4,nargin);
nargoutchk(0,0,nargout);

switch ( version('-release') )
	case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
    	nc_attput_mex ( ncfile, varname, attribute_name, attval )
	otherwise
    	nc_attput_tmw ( ncfile, varname, attribute_name, attval )
end


return




%-----------------------------------------------------------------------
function nc_attput_tmw ( ncfile, varname, attribute_name, attval )

ncid  =netcdf.open(ncfile, nc_write_mode );

try
    netcdf.redef(ncid);

    if isnumeric(varname)
        varid = varname;
    else
        varid = netcdf.inqVarID(ncid, varname );
    end
    
    netcdf.putAtt(ncid,varid,attribute_name,attval);
    netcdf.endDef(ncid);
    netcdf.close(ncid);

catch myException
    netcdf.close(ncid);
    rethrow(myException);
end


return;
%-----------------------------------------------------------------------
function nc_attput_mex ( ncfile, varname, attribute_name, attval )

[ncid, status] =mexnc( 'open', ncfile, nc_write_mode );
if  status ~= 0 
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:badFile', ncerr );
end


%
% Put into define mode.
status = mexnc ( 'redef', ncid );
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:REDEF', ncerr );
end


if isnumeric(varname)
    varid = varname;
else
    [varid, status] = mexnc ( 'inq_varid', ncid, varname );
    if ( status ~= 0 )
        mexnc ( 'close', ncid );
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_ATTGET:MEXNC:INQ_VARID', ncerr );
    end
end



%
% Figure out which mexnc operation to perform.
switch class(attval)

    case 'double'
        funcstr = 'put_att_double';
        atttype = nc_double;
    case 'single'
        funcstr = 'put_att_float';
        atttype = nc_float;
    case 'int32'
        funcstr = 'put_att_int';
        atttype = nc_int;
    case 'int16'
        funcstr = 'put_att_short';
        atttype = nc_short;
    case 'int8'
        funcstr = 'put_att_schar';
        atttype = nc_byte;
    case 'uint8'
        funcstr = 'put_att_uchar';
        atttype = nc_byte;
    case 'char'
        funcstr = 'put_att_text';
        atttype = nc_char;
    otherwise
        msg = sprintf ('attribute class %s is not handled by %s', class(attval), mfilename );
        error ( 'SNCTOOLS:NC_ATTGET:unhandleDatatype', msg );
end

status = mexnc ( funcstr, ncid, varid, attribute_name, atttype, length(attval), attval);
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( ['SNCTOOLS:NC_ATTGET:MEXNC:' upper(funcstr)], ncerr );
end



%
% End define mode.
status = mexnc ( 'enddef', ncid );
if ( status ~= 0 )
    mexnc ( 'close', ncid );
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:ENDDEF', ncerr );
end


status = mexnc('close',ncid);
if ( status ~= 0 )
    ncerr = mexnc ( 'strerror', status );
    error ( 'SNCTOOLS:NC_ATTGET:MEXNC:CLOSE', ncerr );
end


return;




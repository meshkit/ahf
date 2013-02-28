function attribute = nc_get_attribute_struct_tmw ( cdfid, varid, attnum )
% NC_GET_ATTRIBUTE_STRUCT_TMW:  Returns a NetCDF attribute as a structure
%
% You don't want to be calling this routine directly.  Just don't use 
% it.  Use nc_attget instead.  Go away.  Nothing to see here, folks.  
% Move along, move along.
%
% USAGE:  attstruct = nc_get_attribute_struct_tmw ( cdfid, varid, attnum );
%
% PARAMETERS:
% Input:
%     cdfid:  NetCDF file id
%     varid:  NetCDF variable id
%     attnum:  number of attribute
% Output:
%     attstruct:  structure with "Name", "Nctype", "Attnum", and "Value" fields
%
% In case of an error, an exception is thrown.
%
% USED BY:  nc_getinfo.m, nc_getvarinfo.m
%
%



%
% Fill the attribute struct with default values
attribute.Name = '';
attribute.Nctype = NaN;
attribute.Attnum = attnum;   % we know this at this point
attribute.Value = NaN;       % In case the routine fails?


attname = netcdf.inqAttName(cdfid, varid, attnum);
attribute.Name = attname;

[att_datatype,dud] = netcdf.inqAtt(cdfid, varid, attname);
attribute.Nctype = att_datatype;

switch att_datatype
case 0
	attval = NaN;
case nc_char
	attval=netcdf.getAtt(cdfid,varid,attname);
case { nc_double, nc_float, nc_int, nc_short, nc_byte }
	attval=netcdf.getAtt(cdfid,varid,attname,'double');
otherwise
	msg = sprintf ( 'att_datatype is %d.\n', att_datatype );
	error ( msg );
end

%
% this puts the attribute into the variable structure
attribute.Value = attval;


return



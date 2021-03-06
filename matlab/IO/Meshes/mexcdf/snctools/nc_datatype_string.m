function str = nc_datatype_string ( datatype_id )
% NC_DATATYPE_STRING:  constructs string representation of a netcdf type id
%
% DSTRING = NC_DATATYPE_STRING(TYPE_ID) takes a numeric type TYPE_ID and 
% returns a string equivalent, DSTRING.  
%
% This function is deprecated and may not be supported in future releases of
% SNCTOOLS.
%
% The type conversions are as follows:
%
%          0 ==> 'NC_NAT'.
%          1 ==> 'NC_BYTE'.
%          2 ==> 'NC_CHAR'.
%          3 ==> 'NC_SHORT'.
%          4 ==> 'NC_INT'.
%          5 ==> 'NC_FLOAT'.
%          6 ==> 'NC_DOUBLE'.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_datatype_string.m 2528 2008-11-03 23:06:25Z johnevans007 $
% $LastChangedDate: 2008-11-03 18:06:25 -0500 (Mon, 03 Nov 2008) $
% $LastChangedRevision: 2528 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wid = sprintf ( 'SNCTOOLS:%s:deprecatedMessage', lower(mfilename) );
msg = sprintf( '%s is deprecated and may be removed in a future version of SNCTOOLS.', upper(mfilename) );
warning ( wid, msg );

nargchk(1,1,nargin);
nargoutchk(1,1,nargout);

if ~isnumeric ( datatype_id )
	error ( 'SNCTOOLS:NC_DATATYPE_STRING:badInput', 'datatype ID must be numeric' );
end

switch ( datatype_id )
case nc_nat 
	str = 'NC_NAT';
case nc_byte
	str = 'NC_BYTE';
case nc_char
	str = 'NC_CHAR';
case nc_short
	str = 'NC_SHORT';
case nc_int
	str = 'NC_INT';
case nc_float
	str = 'NC_FLOAT';
case nc_double
	str = 'NC_DOUBLE';
otherwise
	msg = sprintf ('unhandled type ID %d', datatype_id );
	error ( 'SNCTOOLS:NC_DATATYPE_STRING:badInput', msg );
end

return

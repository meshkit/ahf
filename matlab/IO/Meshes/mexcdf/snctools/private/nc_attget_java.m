function values = nc_attget_java(ncfile, varname, attribute_name )
% NC_ATTGET_JAVA:  This function retrieves an attribute using the java API

%
% Import the relevent classes.
import ucar.nc2.dods.*    
import ucar.nc2.*         
                           
snc_turnoff_log4j;


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





jatt = get_attribute_from_variable ( jncid, varname, attribute_name );


%
% Retrieve the values.  Convert it to the appropriate matlab datatype.
if ( jatt.isString() ) 
    values = jatt.getStringValue();
    values = char ( values );
    close(jncid);
	return
end


%
% Ok, so it's numeric data.
% convert it to a numeric array.
j_array = jatt.getValues();
values = j_array.copyTo1DJavaArray();
values = values';


theDataTypeString = char ( jatt.getDataType.toString() ) ;
switch ( theDataTypeString )
case 'double'
    values = double(values);
case 'float'
    values = single(values);
case 'int'
    values = int32(values);
case 'short'
    values = int16(values);
case 'byte'
    values = int8(values);
otherwise
    close(jncid);
    fmt = 'Unhandled attribute type ''%s'' for attribute ''%s''';
    msg = sprintf ( fmt, theDataTypeString, attribute_name );
    snc_error ( 'SNCTOOLS:NC_ATTGET:badDatatype', msg );
end

close(jncid);

return






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jatt = get_attribute_from_variable ( jncid, varname, attribute_name )

if ischar ( varname ) && (length(varname) == 0)

	%
	% The user passed in ''.  That means NC_GLOBAL.
	warning ( 'SNCTOOLS:nc_attget:java:doNotUseGlobalString', ...
	          'Please consider using the m-file NC_GLOBAL.M instead of the empty string.' );
    jatt = jncid.findGlobalAttribute ( attribute_name );

elseif ischar ( varname ) && (strcmp(lower(varname),'global'))

	%
	% The user passed in 'global'.   Is there a variable named 'global'?
    jvarid = jncid.findVariable(varname);
	if isempty(jvarid)
		% No, it's a global attribute.
		warning ( 'SNCTOOLS:nc_attget:java:doNotUseGlobalString', ...
			'Please consider using the m-file NC_GLOBAL.M instead of the empty string.' );
    	jatt = jncid.findGlobalAttribute ( attribute_name );
	else
    	jatt = jvarid.findAttribute ( attribute_name );
	end

elseif ischar ( varname )

    %
    % Ok, it was just a regular variable.
    jvarid = jncid.findVariable(varname);
    jatt = jvarid.findAttribute ( attribute_name );


else

    %
    % The user passed a numeric identifier for the variable.  
    % Assume that this means a global attribute.
    jatt = jncid.findGlobalAttribute ( attribute_name );
end


if isempty(jatt)
    close(jncid);
    msg = sprintf( '%s:  Could not locate attribute %s', mfilename, attribute_name );
    snc_error ( '%s:  Could not locate attribute %s', msg);
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Dataset = snc_java_varid_info ( jvarid )
% SNC_JAVA_VARID_INFO:  returns metadata structure for a netcdf variable
%
% This function is private to SNCTOOLS.  It is called by nc_info and
% nc_getvarinfo, and uses the java API.
%
% USAGE:   Dataset = snc_java_varid_info ( jvarid );
% 
% PARAMETERS:
% Input:
%     jvarid:  
%         of type ucar.nc2.dods.DODSVariable
% Output:
%     Dataset:
%         array of metadata structures.  The fields are
%         
%         Name
%         Nctype
%         Unlimited
%         Dimension
%         Attribute
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id$
% $LastChangedDate$
% $LastChangedRevision$
% $LastChangedBy$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dataset.Name = char ( jvarid.getName() );

%
% Get the datatype, store as an integer
datatype = char(jvarid.getDataType().toString());
switch ( datatype )
case 'double'
	Dataset.Nctype = nc_double;
case 'float'
	Dataset.Nctype = nc_float;
case 'int'
	Dataset.Nctype = nc_int;
case 'short'
	Dataset.Nctype = nc_short;

%
% So apparently, DODSNetcdfFile returns 'String', while
% NetcdfFile returns 'char'???
case { 'String', 'char' }
	Dataset.Nctype = nc_char;
case 'byte'
	Dataset.Nctype = nc_byte;
otherwise 
	msg = sprintf ( '%s:  unhandled datatype ''%s''\n', mfilename, datatype );
	error ( msg );
end




%
% determine if it is unlimited or not
Dataset.Unlimited = double ( jvarid.isUnlimited() );


%
% Retrieve the dimensions
Dimension = {};
dims = jvarid.getDimensions();
nvdims = dims.size();
for j = 1:nvdims
	theDim = jvarid.getDimension(j-1);
	Dimension{j} = char ( theDim.getName() );
end
Dataset.Dimension = Dimension;



%
% Get the size of the variable
if nvdims == 0
	Dataset.Size = 1;
else
	Size = double ( jvarid.getShape() );
	Dataset.Size = Size';
end

if getpref('SNCTOOLS','PRESERVE_FVD',false)
	Dataset.Dimension = fliplr(Dataset.Dimension);
	Dataset.Size = fliplr(Dataset.Size);
end


%
% Get the list of attributes.
%
Attribute = [];
j_att_list = jvarid.getAttributes();
Dataset.Attribute = snc_java_bundle_atts ( j_att_list );


return


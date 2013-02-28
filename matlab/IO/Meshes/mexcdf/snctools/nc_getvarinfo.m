function Dataset = nc_getvarinfo ( arg1, arg2 )
% NC_GETVARINFO:  returns metadata about a specific NetCDF variable
%
% VINFO = NC_GETVARINFO(NCFILE,VARNAME) returns a metadata structure VINFO about
% the variable VARNAME in the netCDF file NCFILE.
%
% VINFO = NC_GETVARINFO(NCID,VARID) returns a metadata structure VINFO about
% the variable whose netCDF variable-id is VARID, and whose parent file-id is 
% NCID.  The netCDF file is assumed to be open, and in this case the file will
% not be closed upon completion.
%
% VINFO will have the following fields:
%
%    Name:  
%       a string containing the name of the variable.
%    Nctype:  
%       a string specifying the NetCDF datatype of this variable.
%    Unlimited:  
%       Flag, either 1 if the variable has an unlimited dimension or 0 if not.
%    Dimensions:  
%       a cell array with the names of the dimensions upon which this variable 
%       depends.
%    Attribute:  
%       An array of structures corresponding to the attributes defined for the 
%       specified variable.
%                         
%    Each "Attribute" element contains the following fields.
%
%       Name:  
%           a string containing the name of the attribute.
%       Nctype:  
%           a string specifying the NetCDF datatype of this attribute.
%       Attnum:  
%           a scalar specifying the attribute id
%       Value: 
%           either a string or a double precision value corresponding to the 
%           value of the attribute
%
% In case of an error, an exception is thrown.
%
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_getvarinfo.m 2581 2008-12-09 01:42:39Z johnevans007 $
% $LastChangedDate: 2008-12-08 20:42:39 -0500 (Mon, 08 Dec 2008) $
% $LastChangedRevision: 2581 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% Show usage if too few arguments.
nargchk(2,2,nargin);
nargoutchk(1,1,nargout);

nc_method = determine_retrieval_method(arg1,arg2);

Dataset = nc_method(arg1,arg2);



%-------------------------------------------------------------------------
function retrieval_method = determine_retrieval_method(arg1,arg2)

% Default method is always mexnc.
retrieval_method = @nc_getvarinfo_mexnc;

switch ( version('-release') )
	case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		can_use_tmw = false;
	otherwise
		can_use_tmw = true;
end

% Need this in order to determine if we can use java.
import ucar.nc2.*

file_is_nc3 = ischar(arg1) && exist(arg1,'file') && isnc3(arg1);
file_is_nc4 = ischar(arg1) && exist(arg1,'file') && isnc4(arg1);
file_is_url = ischar(arg1) && ~isempty(regexp(arg1,'\<http[s]*'));
java_available = (exist('NetcdfFile') == 8);

v = mexnc('inq_libvers');
mexnc_is_nc4_capable = (v(1) == '4');


if file_is_nc3

    if mexnc_is_nc4_capable
        retrieval_method = @nc_getvarinfo_mexnc;
    elseif can_use_tmw
        retrieval_method = @nc_getvarinfo_tmw;
    elseif java_available
        retrieval_method = @nc_getvarinfo_java;
    end

elseif file_is_url

    if java_available
        retrieval_method = @nc_getvarinfo_java;
    end

elseif file_is_nc4

    if mexnc_is_nc4_capable
        retrieval_method = @nc_getvarinfo_mexnc;
	elseif java_available
        retrieval_method = @nc_getvarinfo_java;
    end

elseif isnumeric(arg1)

	if mexnc_is_nc4_capable
        retrieval_method = @nc_getvarinfo_mexnc;
	elseif can_use_tmw
        retrieval_method = @nc_getvarinfo_tmw;
	end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset = nc_getvarinfo_tmw ( arg1, arg2 )

%
% If we are here, then we must have been given something local.
if ischar(arg1) && ischar(arg2)

	ncfile = arg1;
	varname = arg2;


	try
		ncid=netcdf.open(ncfile,nc_nowrite_mode);
		varid = netcdf.inqVarid(ncid, varname);
		Dataset = get_varinfo_tmw ( ncid,  varid );
		netcdf.close(ncid);
	catch myException
		if exist('ncid','var')
			netcdf.close(ncid);
			rethrow(myException);
		end
	end

elseif isnumeric ( arg1 ) && isnumeric ( arg2 )

	ncid = arg1;
	varid = arg2;

	Dataset = get_varinfo_tmw ( ncid,  varid );

else
	error ( 'SNCTOOLS:NC_GETVARINFO:tmw:badTypes', ...
	        'Must have either both character inputs, or both numeric.' );
end


return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset = nc_getvarinfo_mexnc ( arg1, arg2 )

%
% If we are here, then we must have been given something local.
if ischar(arg1) && ischar(arg2)

	ncfile = arg1;
	varname = arg2;


	[ncid,status ]=mexnc('open',ncfile,nc_nowrite_mode);
	if status ~= 0
    	ncerr = mexnc('strerror', status);
	    error ( 'SNCTOOLS:NC_VARGET:MEXNC:OPEN', ncerr );
	end


	[varid, status] = mexnc('INQ_VARID', ncid, varname);
	if ( status ~= 0 )
    	ncerr = mexnc('strerror', status);
	    mexnc('close',ncid);
	    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ncerr );
	end

	
	Dataset = get_varinfo ( ncid,  varid );

	%
	% close whether or not we were successful.
	mexnc('close',ncid);


elseif isnumeric ( arg1 ) && isnumeric ( arg2 )

	ncid = arg1;
	varid = arg2;

	Dataset = get_varinfo ( ncid,  varid );

else
	error ( 'SNCTOOLS:NC_GETVARINFO:badTypes', ...
	        'Must have either both character inputs, or both numeric.' );
end


return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset = get_varinfo ( ncid, varid )


[record_dimension, status] = mexnc ( 'INQ_UNLIMDIM', ncid );
if status ~= 0
   	ncerr = mexnc('strerror', status);
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_UNLIMDIM', ncerr );
end



[varname, datatype, ndims, dims, natts, status] = mexnc('INQ_VAR', ncid, varid);
if status ~= 0 
   	ncerr = mexnc('strerror', status);
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VAR', ncerr );
end



Dataset.Name = varname;
Dataset.Nctype = datatype;

%
% Assume the current variable does not have an unlimited dimension until
% we know that it does.
Dataset.Unlimited = false;

if ndims == 0
	Dataset.Dimension = {};
	Dataset.Size = 1;
else

	for j = 1:ndims
	
		[dimname, dimlength, status] = mexnc('INQ_DIM', ncid, dims(j));
		if ( status ~= 0 )
   			ncerr = mexnc('strerror', status);
		    mexnc('close',ncid);
		    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_DIM', ncerr );
		end
	
		Dataset.Dimension{j} = dimname; 
		Dataset.Size(j) = dimlength;
	
		if dims(j) == record_dimension
			Dataset.Unlimited = true;
		end
	end
end

%
% get all the attributes
if natts == 0
	Dataset.Attribute = struct([]);
else
	for attnum = 0:natts-1
		Dataset.Attribute(attnum+1) = nc_get_attribute_struct ( ncid, varid, attnum );
	end
end


if getpref('SNCTOOLS','PRESERVE_FVD',false)
	Dataset.Dimension = fliplr(Dataset.Dimension);
	Dataset.Size = fliplr(Dataset.Size);
end





return











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset = get_varinfo_tmw ( ncid, varid )


[ndims,nvars,ngatts,record_dimension] = netcdf.inq(ncid);
[varname,datatype,dims,natts] = netcdf.inqVar(ncid, varid);
ndims = numel(dims);

Dataset.Name = varname;
Dataset.Nctype = datatype;

%
% Assume the current variable does not have an unlimited dimension until
% we know that it does.
Dataset.Unlimited = false;

if ndims == 0
	Dataset.Dimension = {};
	Dataset.Size = 1;
else

	for j = 1:ndims
	
		[dimname, dimlength] = netcdf.inqDim(ncid, dims(j));
	
		Dataset.Dimension{j} = dimname; 
		Dataset.Size(j) = dimlength;
	
		if dims(j) == record_dimension
			Dataset.Unlimited = true;
		end
	end
end

%
% get all the attributes
if natts == 0
	Dataset.Attribute = struct([]);
else
	for attnum = 0:natts-1
		Dataset.Attribute(attnum+1) = nc_get_attribute_struct_tmw ( ncid, varid, attnum );
	end
end


if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
	Dataset.Dimension = fliplr(Dataset.Dimension);
	Dataset.Size = fliplr(Dataset.Size);
end





return











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset = nc_getvarinfo_java ( ncfile, varname )
%
% This function handles the java case.

import ucar.nc2.dods.*     % import opendap reader classes
import ucar.nc2.*          % have to import this (NetcdfFile) as well for local reads
                           


if exist(ncfile,'file')
	jncid = NetcdfFile.open(ncfile);
else
	jncid = DODSNetcdfFile(ncfile);
end



jvarid = jncid.findVariable(varname);
if isempty(jvarid)
	close(jncid);
	msg = sprintf ('Could not locate variable %s', varname );
	error ( 'SNCTOOLS:NC_GETVARINFO:badVariableName', msg );
end


%
% All the details are hidden here because we need the exact same
% functionality in nc_info.
Dataset = snc_java_varid_info ( jvarid );


close ( jncid );

return

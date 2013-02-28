function values = nc_varget(ncfile, varname, varargin )
% NC_VARGET:  Retrieve data from a netCDF variable.
%
% DATA = NC_VARGET(NCFILE,VARNAME) retrieves all the data from the 
% variable VARNAME in the netCDF file NCFILE.
%
% DATA = NC_VARGET(NCFILE,VARNAME,START,COUNT) retrieves the contiguous
% portion of the variable specified by the index vectors START and 
% COUNT.  Remember that SNCTOOLS indexing is zero-based, not 
% one-based.  Specifying a -1 in COUNT means to retrieve everything 
% along that dimension from the START coordinate.
%
% DATA = NC_VARGET(NCFILE,VARNAME,START,COUNT,STRIDE) retrieves 
% a non-contiguous portion of the dataset.  The amount of
% skipping along each dimension is given through the STRIDE vector.
%
% NCFILE can also be an OPeNDAP URL if the proper java SNCTOOLS 
% backend is installed.  See the README for details.
% 
% NC_VARGET tries to be intelligent about retrieving the data.
% Since most general matlab operations are done in double precision,
% retrieved numeric data will be cast to double precision, while 
% character data remains just character data.  
%
% Singleton dimensions are removed from the output data.  
%
% A '_FillValue' attribute is honored by flagging those datums as NaN.
% A 'missing_value' attribute is honored by flagging those datums as 
% NaN.  The exception to this is for NC_CHAR variables, as mixing 
% character data and NaN doesn't really seem to work in matlab.
%
% If the named NetCDF variable has valid scale_factor and add_offset 
% attributes, then the data is scaled accordingly.  
%
% Setting the preference 'PRESERVE_FVD' to true will compel NC_VARGET 
% to preserve the fastest varying dimension.  This basically means
% that NC_VARGET will not transpose the data.  This basically flips
% the order of the dimension IDs from what one would see by using
% the ncdump C utility.  You get a performance boost from this, but
% caveat emptor applies.
% 
% EXAMPLE:
% #1.  In this case, the variable in question has rank 2, and has size 
%      500x700.  We want to retrieve starting at row 300, column 250.
%      We want 100 contiguous rows, 200 contiguous columns.
% 
%      vardata = nc_varget ( file, variable_name, [300 250], [100 200] );
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_varget.m 2587 2008-12-24 18:50:06Z johnevans007 $
% $LastChangedDate: 2008-12-24 13:50:06 -0500 (Wed, 24 Dec 2008) $
% $LastChangedRevision: 2587 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



nargchk(2,5,nargin);
nargoutchk(0,1,nargout);

nc_method = determine_retrieval_method(ncfile);

[start, count, stride] = parse_and_validate_args(ncfile,varname,varargin{:});

values = nc_method(ncfile,varname,start,count,stride);


return











%----------------------------------------------------------------------
function retrieval_method = determine_retrieval_method(ncfile)

retrieval_method = @nc_varget_mexnc;

switch ( version('-release') )
	case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		can_use_tmw = false;
	otherwise
		can_use_tmw = true;
end

file_is_nc3 = exist(ncfile,'file') && isnc3(ncfile);
file_is_nc4 = exist(ncfile,'file') && isnc4(ncfile);
file_is_url = ~isempty(regexp(ncfile,'\<http[s]*'));
java_available = (exist('NetcdfFile') == 8);

v = mexnc('inq_libvers');
mexnc_is_nc4_capable = (v(1) == '4');


% Need this in order to determine if we can use java.
import ucar.nc2.*

if file_is_nc3

    if mexnc_is_nc4_capable
        retrieval_method = @nc_varget_mexnc;
    elseif can_use_tmw
        retrieval_method = @nc_varget_tmw;
    elseif java_available
        retrieval_method = @nc_varget_java;
    end

elseif file_is_url

    if java_available
        retrieval_method = @nc_varget_java;
    end

elseif file_is_nc4

    if mexnc_is_nc4_capable
        retrieval_method = @nc_varget_mexnc;
    elseif java_available 
        retrieval_method = @nc_varget_java;
    end

end


%----------------------------------------------------------------------
function values = nc_varget_tmw(ncfile, varname, start, count, stride )

ncid=netcdf.open(ncfile,'NOWRITE');
varid=netcdf.inqVarid(ncid,varname);
[dud,var_type,dimids,dud]=netcdf.inqVar(ncid,varid);
nvdims = numel(dimids);

preserve_fvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
% R2008b expects to preserve the fastest varying dimension, so if the
% user didn't want that, we have to reverse the indices.
if ~preserve_fvd
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
end

%
% Check that the start, count, stride parameters have appropriate lengths.
% Otherwise we get confusing error messages later on.
validate_index_vectors(start,count,stride,nvdims);

the_var_size = determine_varsize_tmw ( ncid, dimids, nvdims );

%
% If the user had set non-positive numbers in "count", then we replace them
% with what we need to get the rest of the variable.
negs = find(count<0);
count(negs) = the_var_size(negs) - start(negs);



%
% At long last, retrieve the data.
if isempty(start)
    values = netcdf.getVar(ncid, varid );
elseif isempty(count)
    values = netcdf.getVar(ncid, varid,start );
elseif isempty(stride)
    values = netcdf.getVar(ncid, varid,start,count );
else
    values = netcdf.getVar(ncid, varid,start,count,stride);
end


%
% If it's a 1D vector, make it a column vector.  Otherwise permute the data
% to make up for the row-major-order-vs-column-major-order issue.
if length(the_var_size) == 1
    values = values(:);
else
    if ~preserve_fvd
        pv = fliplr ( 1:length(the_var_size) );
        values = permute(values,pv);
    end
end                                                                                   


values = handle_fill_value_tmw ( ncid, varid, var_type, values );
values = handle_tmw_missing_value ( ncid, varid, var_type, values );
values = handle_scaling_tmw ( ncid, varid, values );


%
% remove any singleton dimensions.
values = squeeze ( values );


netcdf.close(ncid);


return

















function values = nc_varget_mexnc(ncfile, varname, start, count, stride )



[ncid,status]=mexnc('open',ncfile,'NOWRITE');
if status ~= 0
    ncerr = mexnc('strerror', status);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:OPEN', ncerr );
end


[varid, status]=mexnc('inq_varid',ncid,varname);
if status ~= 0
    ncerr = mexnc('strerror', status);
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ncerr );
end

[dud,var_type,nvdims,dimids,dud,status]=mexnc('inq_var',ncid,varid);
if status ~= 0
    mexnc('close',ncid);
    error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_VAR', mexnc('strerror',status) );
end


% mexnc does not preserve the fastest varying dimension.  If we want this,
% then we flip the indices.
if getpref('SNCTOOLS','PRESERVE_FVD',false)
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
end


%
% Check that the start, count, stride parameters have appropriate lengths.
% Otherwise we get confusing error messages later on.
validate_index_vectors(start,count,stride,nvdims);

%
% What mexnc operation will we use?
[funcstr_family, funcstr] = determine_funcstr ( var_type, nvdims, start, count, stride );


the_var_size = determine_varsize_mex ( ncid, dimids, nvdims );

%
% If the user had set non-positive numbers in "count", then we replace them
% with what we need to get the rest of the variable.
negs = find(count<0);
count(negs) = the_var_size(negs) - start(negs);



%
% At long last, retrieve the data.
switch funcstr_family
case 'get_var'
    [values, status] = mexnc ( funcstr, ncid, varid );

case 'get_var1'
    [values, status] = mexnc ( funcstr, ncid, varid, 0 );

case 'get_vara'
    [values, status] = mexnc ( funcstr, ncid, varid, start, count );

case 'get_vars'
    [values, status] = mexnc ( funcstr, ncid, varid, start, count, stride );

otherwise
    msg = sprintf ('Unhandled function string type ''%s''\n', funcstr_family );
    error ( 'SNCTOOLS:NC_VARGET:unhandledType', msg );

end

if ( status ~= 0 )
    mexnc('close',ncid);
    ncerr = mexnc('strerror', status);
    eid = sprintf ( 'SNCTOOLS:nc_varget:%s', funcstr );
    error ( eid, ncerr );
end




%
% If it's a 1D vector, make it a column vector.  
% Otherwise permute the data
% to make up for the row-major-order-vs-column-major-order issue.
if length(the_var_size) == 1
    values = values(:);
else
    % Ok it's not a 1D vector.  If we are not preserving the fastest
    % varying dimension, we should permute the data.
    if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
        pv = fliplr ( 1:length(the_var_size) );
        values = permute(values,pv);
    end
end                                                                                   


values = handle_fill_value_mex ( ncid, varid, var_type, values );
values = handle_mex_missing_value ( ncid, varid, var_type, values );
values = handle_scaling_mex ( ncid, varid, values );


%
% remove any singleton dimensions.
values = squeeze ( values );


mexnc('close',ncid);


return

















function [start, count, stride] = parse_and_validate_args(ncfile,varname,varargin)

%
% Set up default outputs.
start = [];
count = [];
stride = [];


switch nargin
case 4
    start = varargin{1};
    count = varargin{2};

case 5
    start = varargin{1};
    count = varargin{2};
    stride = varargin{3};

end



%
% Error checking on the inputs.
if ~ischar(ncfile)
    error ( 'SNCTOOLS:NC_VARGET:badInput', 'the filename must be character.' );
end
if ~ischar(varname)
    error ( 'SNCTOOLS:NC_VARGET:badInput', 'the variable name must be character.' );
end

if ~isnumeric ( start )
    error ( 'SNCTOOLS:NC_VARGET:badInput', 'the ''start'' argument must be numeric.' );
end
if ~isnumeric ( count )
    error ( 'SNCTOOLS:NC_VARGET:badInput', 'the ''count'' argument must be numeric.' );
end
if ~isnumeric ( stride )
    error ( 'SNCTOOLS:NC_VARGET:badInput', 'the ''stride'' argument must be numeric.' );
end


return









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DETERMINE_FUNCSTR
%     Determines if we are to use, say, 'get_var1_text', or 'get_vars_double',
%     or whatever.
%  
function [prefix,funcstr] = determine_funcstr ( var_type, nvdims, start, count, stride )

%
% Determine if we are retriving a single value, the whole variable, a 
% contiguous portion, or a strided portion.
if nvdims == 0

    %
    % It is a singleton variable.
    prefix = 'get_var1';

elseif isempty(start)
    
    %
    % retrieving the entire variable.
    prefix = 'get_var';

elseif ~isempty(start) && ~isempty(count) && isempty(stride)
    
    %
    % retrieving a contiguous portion
    prefix = 'get_vara';

elseif ~isempty(start) && ~isempty(count) && ~isempty(stride)
    
    %
    % retrieving a contiguous portion
    prefix = 'get_vars';

else
    error ( 'SNCTOOLS:NC_VARGET:FUNCSTR', 'Could not determine funcstr prefix.' );
end



switch ( var_type )
    case nc_char
        funcstr = [prefix '_text'];

    case { nc_double, nc_float, nc_int, nc_short, nc_byte }
        funcstr = [prefix '_double'];

    otherwise
        msg = sprintf ('Unhandled datatype %d.', var_type );
        error ( 'SNCTOOLS:NC_VARGET:badDatatype', msg );

end
return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_TMW_FILL_VALUE
%     If there is a fill value, then replace such values with NaN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_fill_value_tmw ( ncid, varid, var_type, values )

%
% Handle the fill value, if any.  Change those values into NaN.
try
    dud = netcdf.inqAtt(ncid, varid, '_FillValue' );
catch myException
    return;
end

try
    switch ( var_type )
        case nc_char
        %
            % For now, do nothing.  Does a fill value even make sense with char data?
            % If it does, please tell me so.
        case { nc_double, nc_float, nc_int, nc_short, nc_byte }
                fill_value = netcdf.getAtt(ncid, varid, '_FillValue', 'double' );
                values(values==fill_value) = NaN;

        otherwise
                netcdf.close(ncid);
                msg = sprintf ( 'unhandled datatype %d\n', var_type );
                error ( msg );
    end


catch myException
    netcdf.close(ncid);
    rethrow(myException);
end

return






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_MEX_FILL_VALUE
%     If there is a fill value, then replace such values with NaN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_fill_value_mex ( ncid, varid, var_type, values )

%
% Handle the fill value, if any.  Change those values into NaN.
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, '_FillValue' );
if ( status == 0 )

    switch ( var_type )
    case nc_char
        %
        % For now, do nothing.  Does a fill value even make sense with char data?
        % If it does, please tell me so.

    case { nc_double, nc_float, nc_int, nc_short, nc_byte }
        [fill_value, status] = mexnc ( 'get_att_double', ncid, varid, '_FillValue' );
        values(values==fill_value) = NaN;

    otherwise
        mexnc('close',ncid);
        msg = sprintf ( 'unhandled datatype %d\n', var_type );
        error ( msg );
    end

    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_VARGET:MEXNC:GET_ATT', ncerr );
    end



end

return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_TMW_MISSING_VALUE
%     If there is a missing value, then replace such values with NaN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_tmw_missing_value ( ncid, varid, var_type, values )

%
% If there is a fill value attribute, then that had precedence.  Do nothing.
try
    dud = netcdf.inqAtt(ncid, varid, '_FillValue' );
    return;
catch myException
    ;
end


%
% Handle the missing value, if any.  Change those values into NaN.
try
    dud = netcdf.inqAtt(ncid, varid, 'missing_value' );
catch
    return;
end

try
    switch ( var_type )
        case nc_char
            %
            % For now, do nothing.  Does a fill value even make sense with char data?
            % If it does, please tell me so.
    
        case { nc_double, nc_float, nc_int, nc_short, nc_byte }
            fill_value  = netcdf.getAtt(ncid, varid, 'missing_value', 'double' );
            values(values==fill_value) = NaN;
    
        otherwise
            netcdf.close(ncid);
            msg = sprintf ( 'unhandled datatype %d\n', mfilename, var_type );
            error ( msg );
    end
    

catch myException
    netcdf.close(ncid);
    rethrow(myException);
end

return








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_MEX_MISSING_VALUE
%     If there is a missing value, then replace such values with NaN.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_mex_missing_value ( ncid, varid, var_type, values )

%
% If there is a fill value attribute, then that had precedence.  Do nothing.
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, '_FillValue' );
if status == 0
    return
end

%
% Handle the missing value, if any.  Change those values into NaN.
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, 'missing_value' );
if ( status == 0 )

    switch ( var_type )
    case nc_char
        %
        % For now, do nothing.  Does a fill value even make sense with char data?
        % If it does, please tell me so.

    case { nc_double, nc_float, nc_int, nc_short, nc_byte }
        [fill_value, status] = mexnc ( 'get_att_double', ncid, varid, 'missing_value' );
        values(values==fill_value) = NaN;

    otherwise
        mexnc('close',ncid);
        msg = sprintf ( 'unhandled datatype %d\n', mfilename, var_type );
        error ( msg );
    end

    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc ( 'strerror', status );
        error ( 'SNCTOOLS:NC_VARGET:MEXNC:GET_ATT', ncerr );
    end


end

return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_TMW_SCALING
%     If there is a scale factor and/or  add_offset attribute, convert the data
%     to double precision and apply the scaling.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_scaling_tmw ( ncid, varid, values )

have_scale = false;
have_addoffset = false;
try
    dud = netcdf.inqAtt(ncid, varid, 'scale_factor' );
    have_scale = true;
catch myException
    ;
end
try
    dud = netcdf.inqAtt(ncid, varid, 'add_offset' ); 
    have_addoffset = true;
catch
    ;
end

%
% Return early if we don't have either one.
if ~(have_scale || have_addoffset)
    return;
end

scale_factor = 1.0;
add_offset = 0.0;

if have_scale
    try 
        scale_factor = netcdf.getAtt(ncid,varid,'scale_factor','double');
    catch myException
        netcdf.close(ncid);
        rethrow(myException);
    end
end
if have_addoffset
    try 
        add_offset = netcdf.getAtt(ncid,varid,'add_offset','double');
    catch myException
        netcdf.close(ncid);
        rethrow(myException);
    end
end


values = values * scale_factor + add_offset;



return






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HANDLE_MEX_SCALING
%     If there is a scale factor and/or  add_offset attribute, convert the data
%     to double precision and apply the scaling.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = handle_scaling_mex ( ncid, varid, values )

have_scale = false;
have_addoffset = false;
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, 'scale_factor' );
if ( status == 0 )
    have_scale = true;
end
[dud, dud, status] = mexnc('INQ_ATT', ncid, varid, 'add_offset' );
if ( status == 0 )
    have_addoffset = true;
end

%
% Return early if we don't have either one.
if ~(have_scale || have_addoffset)
    return;
end

scale_factor = 1.0;
add_offset = 0.0;

if have_scale
    [scale_factor, status] = mexnc ( 'get_att_double', ncid, varid, 'scale_factor' );
    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc('strerror', status);
        error ( 'SNCTOOLS:NC_VARGET:MEXNC:GET_ATT_DOUBLE', ncerr );
    end
end

if have_addoffset
    [add_offset, status] = mexnc ( 'get_att_double', ncid, varid, 'add_offset' );
    if ( status ~= 0 )
        mexnc('close',ncid);
        ncerr = mexnc('strerror', status);
        error ( 'SNCTOOLS:NC_VARGET:MEXNC:GET_ATT_DOUBLE', ncerr );
    end
end

values = values * scale_factor + add_offset;

return








%-----------------------------------------------------------------------
function the_var_size = determine_varsize_mex ( ncid, dimids, nvdims )
% DETERMINE_VARSIZE_MEX: Need to figure out just how big the variable is.
%
% VAR_SIZE = DETERMINE_VARSIZE_MEX(NCID,DIMIDS,NVDIMS);

%
% If not a singleton, we need to figure out how big the variable is.
if nvdims == 0
    the_var_size = 1;
else
    the_var_size = zeros(1,nvdims);
    for j=1:nvdims,
        dimid = dimids(j);
        [dim_size,status]=mexnc('inq_dimlen', ncid, dimid);
        if ( status ~= 0 )
            ncerr = mexnc ( 'strerror', status );
            mexnc('close',ncid);
            error ( 'SNCTOOLS:NC_VARGET:MEXNC:INQ_DIM_LEN', ncerr );
        end
        the_var_size(j)=dim_size;
    end
end

return




%-----------------------------------------------------------------------
function the_var_size = determine_varsize_tmw ( ncid, dimids, nvdims )
% DETERMINE_VARSIZE_TMW: Need to figure out just how big the variable is.
%
% VAR_SIZE = DETERMINE_VARSIZE_TMW(NCID,DIMIDS,NVDIMS);

%
% If not a singleton, we need to figure out how big the variable is.
if nvdims == 0
    the_var_size = 1;
else
    the_var_size = zeros(1,nvdims);
    for j=1:nvdims,
        dimid = dimids(j);
        try
            [dim_name,dim_size]=netcdf.inqDim(ncid, dimid);
        catch myException
            netcdf.close(ncid);
            rethrow(myException);
        end
        the_var_size(j)=dim_size;
    end
end

if ~getpref('SNCTOOLS','PRESERVE_FVD',false)
    the_var_size = fliplr(the_var_size);
end

return






function new_data = nc_addnewrecs ( ncfile, input_buffer, record_variable )
% NC_ADDNEWRECS:  Tacks on new data from simple matlab structure to an unlimited-dimension netcdf file
% 
% The difference between this m-file and nc_add_recs is that this 
% routine assumes that the unlimited dimension has a monotonically
% increasing coordinate variable, e.g. time series.  This routine
% actually calls nc_add_recs with suitable arguments.
%
% If the length of the record variable data that is to be appended is
% just one, then a check is made for the rest of the incoming data to
% make sure that they also have the proper rank.  This addresses the
% issue of squeezed-out leading singleton dimensions.
%
% From this point foreward, assume we are talking about time series.
% It doesn't have to be that way (the record variable could be 
% monotonically increasing spatially instead ), but talking about it
% in terms of time series is just easier.  If a field is present in 
% the structure, but not in the netcdf file, then that field is 
% ignored.  Only data that is more recent than the last record 
% currently in the NetCDF file is written.   Older data is discarded.
%
% USAGE:  new_data = nc_addnewrecs ( ncfile, input_buffer, record_variable )
% 
% PARAMETERS:
%   Input:
%      ncfile:  
%          netcdf file that we write information to
%      input_buffer:  
%          structure of time series data.  
%      record_variable:
%          Coordinate variable that is monotonically increasing.  
%          In ROMS, it is "ocean_time".  For purposes of backwards
%          compatibility, if this is not provided, it is assumed
%          to be "time".
%   Output:
%      new_data:  
%          Matlab structure of data corresponding in structure to "input_buffer", but
%          consisting only of those records which were actually written to file.
%  
%   The dimensions of the data should match that of the target netcdf file.  For example, 
%   suppose an ncdump of the
%   NetCDF file looks something like
%
%       netcdf a_netcdf_file {
%       dimensions:
%           lat = 1 ;
%           lon = 2 ;
%           depth = 2 ; 
%           time = UNLIMITED ; // (500 currently)
%       variables:
%           double time(time) ;
%           float var1(time, depth) ;
%           float var2(time, depth, lat, lon) ;
%           float var3(time, depth, lat) ;
%       
%       // global attributes:
%       }
% 
%   The "input_input_buffer" should look something like the following:
%
%       >> input_input_buffer
%
%       input_input_buffer =
%
%           time: [3x1 double]
%           var1: [3x2 double]
%           var2: [4-D double]
%           var3: [3x2 double]
%
% The reason for the possible size discrepency here is that matlab will
% ignore trailing singleton dimensions (but not interior ones, such as
% that in var2.
%
% If a netcdf variable has no corresponding field in the input input_buffer,
% then the corresponding NetCDF variable will populate with the appropriate
% _FillValue for each new time step.
%          
% In case of an error, an exception is thrown.
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_addnewrecs.m 2178 2007-04-23 13:05:21Z johnevans007 $
% $LastChangedDate: 2007-04-23 09:05:21 -0400 (Mon, 23 Apr 2007) $
% $LastChangedRevision: 2178 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



new_data = [];

nargchk(2,3,nargin);
nargoutchk(0,1,nargout);

if nargin == 2
    record_variable = 'time';
end

if isempty ( input_buffer )
    return
end

%
% Check that the record variable is present in the input buffer.
if ~isfield ( input_buffer, record_variable )
    error ( 'SNCTOOLS:NC_ADDNEWRECS:missingRecordVariable', ...
            'input structure is missing the record variable ''%s''.\n', record_variable );
end


% Remove any fields that aren't actually in the file.
[input_buffer, vsize] = restrict_to_those_in_file(input_buffer,ncfile);


%
% If the length of the record variable data to be added is just one,
% then we may have a special corner case.  The leading dimension might
% have been squeezed out of the other variables.  MEXNC wants the rank
% of the incoming data to match that of the infile variable.  We address 
% this by forcing the leading dimension in these cases to be 1.
input_buffer = force_rank_match ( ncfile, input_buffer, record_variable );

%
% Retrieve the dimension id of the unlimited dimension upon which
% all depends.  
varinfo = nc_getvarinfo ( ncfile, record_variable );
if getpref('SNCTOOLS','USE_TMW',false)
    unlimited_dimension_name = varinfo.Dimension{end};
else
    unlimited_dimension_name = varinfo.Dimension{1};
end

%
% Get the last time value.   If the record variable is empty, then
% only take datums that are more recent than the latest old datum
input_buffer_time_values = input_buffer.(record_variable);
if varinfo.Size > 0
    last_time = nc_getlast ( ncfile, record_variable, 1 );
    recent_inds = find( input_buffer_time_values > last_time );
else
    recent_inds = 1:length(input_buffer_time_values);
end



%
% if no data is new enough, just return.  There's nothing to do.
if isempty(recent_inds)
    return
end



%
% Go thru each variable.  Restrict to what's new.
varnames = fieldnames ( input_buffer );
for j = 1:numel(varnames)
    data = input_buffer.(varnames{j});
    current_varsize = size(data);

    if getpref('SNCTOOLS','PRESERVE_FVD',false) 
        %&& (ndims(data) > 1) && (size(data,ndims(data)) > 1)
        if numel(vsize.(varnames{j})) == 1
            % netCDF variable is 1D
            restricted_data = data(recent_inds);
        elseif (numel(vsize.(varnames{j})) == 2) 
            % netCDF variable is 2D
            restricted_data = data(:,recent_inds);
        elseif (ndims(data) < numel(vsize.(varnames{j}))) && (numel(recent_inds) == 1)
            % netCDF variable is more than 2D, but we are given just one record.
            restricted_data = data;
        else
            cmdstring = repmat(':,',1,ndims(data)-1);
            cmdstring = sprintf ( 'restricted_data = data(%srecent_inds);', cmdstring );
            eval(cmdstring);
        end
    else
        if numel(vsize.(varnames{j})) == 1
            % netCDF variable is 1D
            restricted_data = data(recent_inds);
        elseif (numel(vsize.(varnames{j})) == 2) 
            % netCDF variable is 2D
            restricted_data = data(recent_inds,:);
        elseif (ndims(data) < numel(vsize.(varnames{j}))) && (numel(recent_inds) == 1)
            % netCDF variable is more than 2D, but we are given just one record.
            restricted_data = data;
        else
            cmdstring = repmat(',:',1,ndims(data)-1);
            cmdstring = sprintf ( 'restricted_data = data(recent_inds%s);', cmdstring );
            eval(cmdstring);
        end
    end


    input_buffer.(varnames{j}) = restricted_data;
end



%
% Write the records out to file.
nc_add_recs ( ncfile, input_buffer, unlimited_dimension_name );


new_data = input_buffer;




return;





%==============================================================================
function input_buffer = force_rank_match ( ncfile, input_buffer, record_variable )
% If the length of the record variable data to be added is just one,
% then we may have a special corner case.  The leading dimension might
% have been squeezed out of the other variables.  MEXNC wants the rank
% of the incoming data to match that of the infile variable.  We address 
% this by forcing the leading dimension in these cases to be 1.

varnames = fieldnames ( input_buffer );
num_vars = length(varnames);
if length(input_buffer.(record_variable)) == 1 
    for j = 1:num_vars

        %
        % Skip the record variable, it's irrelevant at this stage.
        if strcmp ( varnames{j}, record_variable )
            continue;
        end

        infile_vsize = nc_varsize(ncfile, varnames{j} );

        %
        % Disregard any trailing singleton dimensions.
        %effective_nc_rank = calculate_effective_nc_rank(infile_vsize);

        if (numel(infile_vsize) > 2) && (ndims(input_buffer.(varnames{j})) ~= numel(infile_vsize))
            %
            % Ok we have a mismatch.
            if getpref('SNCTOOLS','PRESERVE_FVD',true)
                rsz = [infile_vsize(1:end-1) numel(input_buffer.(record_variable))]; 
            else
                rsz = [numel(input_buffer.(record_variable)) infile_vsize(2:end) ]; 
            end
            input_buffer.(varnames{j}) = reshape( input_buffer.(varnames{j}), rsz );
        end


    end
end


%==============================================================================
function effective_nc_rank = calculate_effective_nc_rank(infile_vsize)

n = length(infile_vsize);

%
% Trim any trailing singleton dimensions.
% Do this by zeroing them out.
for k = n:-1:ceil(n/2)
    if (infile_vsize(k) ~= 1)
        break;
    end
    infile_vsize(k) = 0;
end

%
% Don't get fooled if there is no data in the file.
if ( infile_vsize(1) == 0 )
    infile_vsize(1) = -1;
end
effective_nc_rank = numel(find(infile_vsize));


%==============================================================================
function mlrank = calculate_mlrank ( input_buffer, varnames, j )

% If the rank of the file variable and the data is different,
% then we assume two conditions have to hold before we augment 
% the data with a leading singleton dimension.  The extent of 
% the incoming data must not be one, and the length of the size 
% of the incoming data must not match up with the length of the 
% size of the file variable.
if ndims(input_buffer.(varnames{j})) == 2
    sz = size(input_buffer.(varnames{j}));
    if (sz(1) == 1) && (sz(2) == 1)
        mlrank = 1;
    else
        mlrank = 2;
    end
else
    mlrank = length(size(input_buffer.(varnames{j})));
end


%------------------------------------------------------------------------
function [input_buffer, vsize] = restrict_to_those_in_file(input_buffer,ncfile)

%
% check to see that all fields are actually there.
nc = nc_info ( ncfile );
num_nc_vars = length(nc.Dataset);

vsize = [];

fnames = fieldnames ( input_buffer );
num_fields = length(fnames);
for j = 1:num_fields
    not_present = 1;
    for k = 1:num_nc_vars
        if strcmp(fnames{j}, nc.Dataset(k).Name)
            not_present = 0;

            % Store the dataset size.
            vsize.(fnames{j}) = nc.Dataset(k).Size;
        end
    end
    if not_present
        fprintf ( 1, '  %s not present in file %s.  Ignoring it...\n', fnames{j}, ncfile );
        input_buffer = rmfield ( input_buffer, fnames{j} );
    end
end



function tf = isnc3(ncfile)
% ISNC3:  determines if a netCDF file is netCDF-3 or not.

% Default value.
tf = false;  

% Read the first 4 bytes.  If bytes 1-3 are 'CDF', and byte 4 is 1, then
% we have a netcdf-3 file.  If we have 'CDF' and byte 4 is 2, then we also
% have a netcdf-3 file.
afid = fopen(ncfile,'r');
[signature,count] = fread(afid,4,'uchar');
if ( count ~= 4 )
	tf = false;
	fclose(afid);
end

if (strcmp(char(signature(1:3))', 'CDF') ...
    && ((signature(4) == 1) || signature(4) == 2) )
	tf = true;
end
fclose(afid);
return


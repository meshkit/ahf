function tf = isnc4(ncfile)
% ISNC4:  determines if a netCDF file is netCDF-4 or not.

% Default value.
tf = false;  

% Read the first 4 bytes.  If bytes 2-4 are 'HDF', then we will assume
% it is netcdf-4
afid = fopen(ncfile,'r');
[signature,count] = fread(afid,4,'uchar');
if ( count ~= 4 )
	tf = false;
	fclose(afid);
end
if strcmp(char(signature(2:4))', 'HDF')
	tf = true;
end
fclose(afid);
return

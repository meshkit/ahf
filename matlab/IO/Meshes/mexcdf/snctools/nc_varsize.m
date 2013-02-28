function varsize = nc_varsize(ncfile, varname)
% NC_VARSIZE:  return the size of the requested netncfile variable
%
% VARSIZE = NC_VARSIZE(NCFILE,NCVAR) returns the size of the netCDF variable 
% NCVAR in the netCDF file NCFILE.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_varsize.m 2528 2008-11-03 23:06:25Z johnevans007 $
% $LastChangedDate: 2008-11-03 18:06:25 -0500 (Mon, 03 Nov 2008) $
% $LastChangedRevision: 2528 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(2,2,nargin);
nargoutchk(1,1,nargout);

if ~ischar(ncfile)
	error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input filename must be a string.' );
end
if ~ischar(varname)
	error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input variable name must be a string.' );
end


v = nc_getvarinfo ( ncfile, varname );

varsize = v.Size;

return


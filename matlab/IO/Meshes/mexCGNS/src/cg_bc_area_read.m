function [io_RegionName, out_AreaType, out_SurfaceArea, ierr] = cg_bc_area_read(in_file_number, in_B, in_Z, in_BC, io_RegionName)
% Gateway function for C function cg_bc_area_read.
%
% [RegionName, AreaType, SurfaceArea, ierr] = cg_bc_area_read(file_number, B, Z, BC, RegionName)
%
% Input arguments (required; type is auto-casted):
%     file_number: 32-bit integer (int32), scalar
%               B: 32-bit integer (int32), scalar
%               Z: 32-bit integer (int32), scalar
%              BC: 32-bit integer (int32), scalar
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%      RegionName: character string with default length 32 
%
% Output arguments (optional):
%        AreaType: 32-bit integer (int32), scalar
%     SurfaceArea: single-precision (single), scalar
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_bc_area_read( int file_number, int B, int Z, int BC, AreaType_t * AreaType, float * SurfaceArea, char * RegionName);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/bc.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 4); 
    error('Incorrect number of input or output arguments.');
end
if nargin<5
    io_RegionName=char(zeros(1,32));
elseif length(io_RegionName)<32
    %% Enlarge the array if necessary;
    io_RegionName=char([io_RegionName zeros(1,32-length(io_RegionName))]);
elseif ~isa(io_RegionName,'char');
    io_RegionName=char(io_RegionName);
else
    % Write to it to avoid sharing memory with other variables
    t=io_RegionName(1); io_RegionName(1)=t;
end


% Invoke the actual MEX-function.
[out_AreaType, out_SurfaceArea, ierr, io_RegionName] =  cgnslib_mex(int32(143), in_file_number, in_B, in_Z, in_BC, io_RegionName);

function ierr = cg_simulation_type_write(in_file_number, in_B, in_type)
% Gateway function for C function cg_simulation_type_write.
%
% ierr = cg_simulation_type_write(file_number, B, type)
%
% Input arguments (required; type is auto-casted):
%     file_number: 32-bit integer (int32), scalar
%               B: 32-bit integer (int32), scalar
%            type: 32-bit integer (int32), scalar
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_simulation_type_write( int file_number, int B, SimulationType_t type);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/structural.html">online documentation</a>.
%
if (nargin < 3); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(130), in_file_number, in_B, in_type);

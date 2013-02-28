function [out_nsols, ierr] = cg_nsols(in_fn, in_B, in_Z)
% Gateway function for C function cg_nsols.
%
% [nsols, ierr] = cg_nsols(fn, B, Z)
%
% Input arguments (required; type is auto-casted):
%              fn: 32-bit integer (int32), scalar
%               B: 32-bit integer (int32), scalar
%               Z: 32-bit integer (int32), scalar
%
% Output arguments (optional):
%           nsols: 32-bit integer (int32), scalar
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_nsols( int fn, int B, int Z, int * nsols);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/solution.html">online documentation</a>.
%
if (nargin < 3); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
[out_nsols, ierr] =  cgnslib_mex(int32(80), in_fn, in_B, in_Z);

function [out_rootid, ierr] = cg_root_id(in_fn)
% Gateway function for C function cg_root_id.
%
% [rootid, ierr] = cg_root_id(fn)
%
% Input argument (required; type is auto-casted): 
%              fn: 32-bit integer (int32), scalar
%
% Output arguments (optional):
%          rootid: double-precision (double), scalar
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_root_id( int fn, double * rootid);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/fileops.html">online documentation</a>.
%
if (nargin < 1); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
[out_rootid, ierr] =  cgnslib_mex(int32(8), in_fn);

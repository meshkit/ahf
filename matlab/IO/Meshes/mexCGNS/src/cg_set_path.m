function ierr = cg_set_path(in_path)
% Gateway function for C function cg_set_path.
%
% ierr = cg_set_path(path)
%
% Input argument (required; type is auto-casted): 
%            path: character string
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_set_path( const char * path);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/fileops.html">online documentation</a>.
%
if (nargin < 1); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(12), in_path);

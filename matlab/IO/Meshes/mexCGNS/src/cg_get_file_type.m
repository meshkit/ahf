function [io_file_type, ierr] = cg_get_file_type(in_fn, io_file_type)
% Gateway function for C function cg_get_file_type.
%
% [file_type, ierr] = cg_get_file_type(fn, file_type)
%
% Input argument (required; type is auto-casted): 
%              fn: 32-bit integer (int32), scalar
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%       file_type: 32-bit integer (int32), array  (also required as input)
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_get_file_type( int fn, int * file_type);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/fileops.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 2); 
    error('Incorrect number of input or output arguments.');
end
if ~isa(io_file_type,'int32');
    io_file_type=int32(io_file_type);
elseif ~isempty(io_file_type);
    % Write to it to avoid sharing memory with other variables
    t=io_file_type(1); io_file_type(1)=t;
end


% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(7), in_fn, io_file_type);

function [io_exponents, ierr] = cg_exponents_read(io_exponents)
% Gateway function for C function cg_exponents_read.
%
% [exponents, ierr] = cg_exponents_read(exponents)
%
% Input argument (required; type is auto-casted): 
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%       exponents: dynamic type based on cg_exponents_info()  (also required as input)
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_exponents_read( void * exponents);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/physical.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 1); 
    error('Incorrect number of input or output arguments.');
end

% Perform dynamic type casting
datatype = cg_exponents_info();
switch (datatype)
    case 2 % Integer
        io_exponents = int32(io_exponents);
    case 3 % RealSingle
        io_exponents = single(io_exponents);
    case 4 % RealDouble
        io_exponents = double(io_exponents);
    case 5 % Character
        io_exponents = [int8(io_exponents), int8(zeros(1,1))];
    otherwise
        error('Unknown data type %d', cg_exponents_info());
end


% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(195), io_exponents);

% Perform dynamic type casting
if datatype==5 % Character
    io_exponents = char(io_exponents(1:end-1));
end

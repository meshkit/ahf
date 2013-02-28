function ierr = cg_descriptor_write(in_descr_name, in_descr_text)
% Gateway function for C function cg_descriptor_write.
%
% ierr = cg_descriptor_write(descr_name, descr_text)
%
% Input arguments (required; type is auto-casted):
%      descr_name: character string
%      descr_text: character string
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_descriptor_write( char const * descr_name, char const * descr_text);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/descriptor.html">online documentation</a>.
%
if (nargin < 2); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(187), in_descr_name, in_descr_text);

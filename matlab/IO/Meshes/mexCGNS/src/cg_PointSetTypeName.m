function name = cg_PointSetTypeName(in_type)
% Gateway function for C function cg_PointSetTypeName.
%
% name = cg_PointSetTypeName(type)
%
% Input argument (required; type is auto-casted): 
%            type: 32-bit integer (int32), scalar
%
% Output argument (optional): 
%            name: character string
%
% The original C function is:
% const char * cg_PointSetTypeName( PointSetType_t type);
%
% For detail, see the documentation of the original function.
if (nargin < 1); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
name =  cgnslib_mex(int32(26), in_type);

function [io_RindData, ierr] = cg_rind_read(io_RindData)
% Gateway function for C function cg_rind_read.
%
% [RindData, ierr] = cg_rind_read(RindData)
%
% Input argument (required; type is auto-casted): 
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%        RindData: 32-bit integer (int32), array  (also required as input)
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_rind_read( int * RindData);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/location.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 1); 
    error('Incorrect number of input or output arguments.');
end
if ~isa(io_RindData,'int32');
    io_RindData=int32(io_RindData);
elseif ~isempty(io_RindData);
    % Write to it to avoid sharing memory with other variables
    t=io_RindData(1); io_RindData(1)=t;
end


% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(183), io_RindData);

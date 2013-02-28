function [io_name, out_BCType, out_DirichletFlag, out_NeumannFlag, ierr] = cg_bcdataset_read(in_index, io_name)
% Gateway function for C function cg_bcdataset_read.
%
% [name, BCType, DirichletFlag, NeumannFlag, ierr] = cg_bcdataset_read(index, name)
%
% Input argument (required; type is auto-casted): 
%           index: 32-bit integer (int32), scalar
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%            name: character string with default length 32 
%
% Output arguments (optional):
%          BCType: 32-bit integer (int32), scalar
%    DirichletFlag: 32-bit integer (int32), scalar
%     NeumannFlag: 32-bit integer (int32), scalar
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_bcdataset_read( int index, char * name, BCType_t * BCType, int * DirichletFlag, int * NeumannFlag);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/bc.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 1); 
    error('Incorrect number of input or output arguments.');
end
if nargin<2
    io_name=char(zeros(1,32));
elseif length(io_name)<32
    %% Enlarge the array if necessary;
    io_name=char([io_name zeros(1,32-length(io_name))]);
elseif ~isa(io_name,'char');
    io_name=char(io_name);
else
    % Write to it to avoid sharing memory with other variables
    t=io_name(1); io_name(1)=t;
end


% Invoke the actual MEX-function.
[out_BCType, out_DirichletFlag, out_NeumannFlag, ierr, io_name] =  cgnslib_mex(int32(118), in_index, io_name);

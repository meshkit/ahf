function [io_bitername, out_nsteps, ierr] = cg_biter_read(in_file_number, in_B, io_bitername)
% Gateway function for C function cg_biter_read.
%
% [bitername, nsteps, ierr] = cg_biter_read(file_number, B, bitername)
%
% Input arguments (required; type is auto-casted):
%     file_number: 32-bit integer (int32), scalar
%               B: 32-bit integer (int32), scalar
%
% In&Out argument (required as output; also required as input if specified; type is auto-casted):
%       bitername: character string with default length 32 
%
% Output arguments (optional):
%          nsteps: 32-bit integer (int32), scalar
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_biter_read( int file_number, int B, char * bitername, int * nsteps);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/timedep.html">online documentation</a>.
%
if ( nargout < 1 || nargin < 2); 
    error('Incorrect number of input or output arguments.');
end
if nargin<3
    io_bitername=char(zeros(1,32));
elseif length(io_bitername)<32
    %% Enlarge the array if necessary;
    io_bitername=char([io_bitername zeros(1,32-length(io_bitername))]);
elseif ~isa(io_bitername,'char');
    io_bitername=char(io_bitername);
else
    % Write to it to avoid sharing memory with other variables
    t=io_bitername(1); io_bitername(1)=t;
end


% Invoke the actual MEX-function.
[out_nsteps, ierr, io_bitername] =  cgnslib_mex(int32(131), in_file_number, in_B, io_bitername);

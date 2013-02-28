function ierr = cg_bcdata_write(in_file_number, in_B, in_Z, in_BC, in_Dset, in_BCDataType)
% Gateway function for C function cg_bcdata_write.
%
% ierr = cg_bcdata_write(file_number, B, Z, BC, Dset, BCDataType)
%
% Input arguments (required; type is auto-casted):
%     file_number: 32-bit integer (int32), scalar
%               B: 32-bit integer (int32), scalar
%               Z: 32-bit integer (int32), scalar
%              BC: 32-bit integer (int32), scalar
%            Dset: 32-bit integer (int32), scalar
%      BCDataType: 32-bit integer (int32), scalar
%
% Output argument (optional): 
%            ierr: 32-bit integer (int32), scalar
%
% The original C function is:
% int cg_bcdata_write( int file_number, int B, int Z, int BC, int Dset, BCDataType_t BCDataType);
%
% For detail, see <a href="http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/midlevel/bc.html">online documentation</a>.
%
if (nargin < 6); 
    error('Incorrect number of input or output arguments.');
end

% Invoke the actual MEX-function.
ierr =  cgnslib_mex(int32(119), in_file_number, in_B, in_Z, in_BC, in_Dset, in_BCDataType);

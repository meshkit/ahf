function eid = hvid2eid( hvid) %#codegen 
% HVID2EID   Obtains edge ID from half-vertex ID.
coder.inline('always');
eid = int32(bitshift(uint32(hvid), -1));

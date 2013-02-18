function lvid = hvid2lvid( hvid) %#codegen 
% HVID2LVID   Obtains local vertex ID within an edge from half-vertex ID.
coder.inline('always');
lvid = int32(bitand(uint32(hvid),1))+1;

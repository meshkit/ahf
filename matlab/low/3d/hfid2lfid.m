function lfid = hfid2lfid( hfid)  %#codegen
% HFID2LFID   Obtains local face ID within a cell from half-face ID.
coder.inline('always');
lfid = int32(bitand(uint32(hfid),7))+1;

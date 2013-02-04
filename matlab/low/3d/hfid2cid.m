function cid = hfid2cid( hfid)  %#codegen
% HFID2CID   Obtains cell ID from half-face ID.
coder.inline('always');
cid = int32(bitshift(uint32(hfid), -3));

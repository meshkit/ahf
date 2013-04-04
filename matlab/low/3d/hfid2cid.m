function cid = hfid2cid( hfid)  %#codegen
% HFID2CID   Obtains cell ID from half-face ID.
coder.inline('always');

if isstruct( hfid)
    cid = hfid.cid;
else
    cid = int32(bitshift(uint32(hfid), -3));
end

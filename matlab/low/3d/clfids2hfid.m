function hfid = clfids2hfid(cid, lfid) %#codegen 
% Encode <cid,lfid> pair into a hfid.
% HFID = CLFIDS2HFID(CID, LFID)
% See also HFID2CID, HFID2LFID

hfid = cid*8+int32(lfid)-1;

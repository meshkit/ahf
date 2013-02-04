function heid = fleids2heid(fid, leid) %#codegen 
% Encode <fid,leid> pair into a heid.
% HEID = FLEIDS2HEID(FID, LEID)
% See also HEID2FID, HEID2LEID

heid = fid*4+leid-1;

function fid = heid2fid( heid) %#codegen
% HEID2FID   Obtains face ID from half-edge ID.
coder.inline('always');
fid = int32(bitshift(uint32(heid), -2));

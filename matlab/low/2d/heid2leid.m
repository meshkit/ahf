function leid = heid2leid( heid) %#codegen
% HEID2LEID   Obtains local edge ID within a face from half-edge ID.
coder.inline('always');
leid = int32(bitand(uint32(heid),3))+1;

function v = origin_vertex( elems, heid) %#codegen 
% ORIGIN_VERTEX  Obtains the ID of the origin vertex from a half-edge ID.
coder.inline('always');
v = elems( bitshift(uint32(heid),-2), mod(heid,4)+1);

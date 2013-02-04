function nxt = prev_heid_quad(heid) %#codegen 
coder.inline('always');

l = heid2leid(heid);
prev4 = int32([4 1 2 3]);
nxt = heid - l + prev4(l);

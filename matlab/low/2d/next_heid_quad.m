function nxt = next_heid_quad(heid) %#codegen 
coder.inline('always');

l = heid2leid(heid);
next4 = int32([2 3 4 1]);
nxt = heid - l + next4(l);

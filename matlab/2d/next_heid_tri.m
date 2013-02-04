function nxt = next_heid_tri(heid) %#codegen 

l = heid2leid(heid);
next3 = int32([2 3 1]);
nxt = heid - l + next3(l);

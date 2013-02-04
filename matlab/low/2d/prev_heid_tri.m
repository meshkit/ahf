function prv = prev_heid_tri(heid) %#codegen 

l = heid2leid(heid);
prev3 = int32([3 1 2]);
prv = heid - l + prev3(l);

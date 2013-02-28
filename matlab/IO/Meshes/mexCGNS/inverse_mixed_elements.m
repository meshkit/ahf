function elems = inverse_mixed_elements( elems)
% Convert from element_type in the connectivity table into the number of
% vertices per element.

%#codegen -args {coder.typeof( int32(0), [inf, 1], [1, 0])}

es = size(elems,1);

ii=int32(1);
nelems = int32(0);

while (ii<es)
    elems(ii) = get_elemtype_string( elems(ii));
    
    ii = ii + elems(ii) + 1;
    nelems = nelems + 1;
end
end

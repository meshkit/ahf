function ne = nnz_elements( elems)
%NNZ_ELEMENTS the number of nonzero elements.
% NNZ_ELEMENTS(ELEMS) returns the number of elements with nonzero entries.

%#codegen -args {coder.typeof(int32(0), [inf,27], [1,1])}

% Skip elements with zero entries.
if size(elems,1)==0 || elems(1,1)==0
    ne = int32(0);
elseif size(elems,2)==1
    % Count the number of elements.
    ne = int32(0); offset=int32(1);
    while offset < length(elems)
        if elems(offset)==0; break; end
        
        ne = ne + 1;
        offset = offset + elems(offset) + 1;
    end
else
    nume = int32(size(elems,1));

    for step=int32(size(elems,1)):-1:1
        if elems(step,1); break; end
        nume=nume-1;
    end
    ne=nume;
end

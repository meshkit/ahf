function elems_out = regularize_mixed_elems( elems)
% Regularize the connectivity table of mixed elements.
%
% ELEMS_OUT = REGULARIZE_MIXED_ELEMS( ELEMS)
%
% At input, ELEMS is a column vector.
% At output, ELEMS_OUT is a m-by-n matrix, where n is the maximum number
%    of nodes per element and m is the number of elements. ELEM_OUT may
%    contain zeros.
%
% See also LINEARIZE_MIXED_ELEMS, DETERMINE_OFFSETS_MIXED_ELEMS.

%#codegen -args {coder.typeof(int32(0),[inf,1],[1,1])}

% Determine the nelems and maxnv
offset=int32(1); nelems=int32(0); maxnv=int32(0);
while offset<size(elems,1)
    if elems(offset)>maxnv; maxnv=elems(offset); end
    nelems = nelems + 1;
    offset = offset+elems(offset)+1;
end

% Allocate and fill in elems_out
elems_out = nullcopy(zeros(nelems,maxnv,'int32'));

offset=int32(1); 
for i=1:nelems
    elems_out(i,1:elems(offset)) = elems(offset+1:offset+elems(offset));
    offset = offset+elems(offset)+1;
end

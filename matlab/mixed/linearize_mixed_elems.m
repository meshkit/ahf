function elems_out = linearize_mixed_elems( elems)
% Linearize the connectivity table of mixed elements.
%
% ELEMS_OUT = LINEARIZE_MIXED_ELEMS( ELEMS)
%
% At input, ELEMS is m-by-n, where n is the maximum number of nodes 
%    per element and m is the number of elements. ELEM may contain zeros.
% At output, ELEMS_OUT is a column vector.
%
% See also REGULARIZE_MIXED_ELEMS, DETERMINE_OFFSETS_MIXED_ELEMS.

%#codegen -args {coder.typeof(int32(0),[inf,27],[1,1])}

elems_out = nullcopy(zeros(sum(sum(elems~=0,1))+size(elems,1),1,'int32'));

index=int32(1);
for i=1:int32(size(elems,1))
    nv = sum(elems(i,:)~=0);
    elems_out(index) = nv;
    elems_out(index+1:index+nv) = elems(i,1:nv);
    
    index = index + nv + 1;
end

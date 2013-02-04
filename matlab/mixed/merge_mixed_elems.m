function [elems_hyb] = merge_mixed_elems( elems_buf, elems_type, elems_offsets)
% Merge the connectivity information of mixed elements into a single
% column vector.

%#codegen -args {coder.typeof(int32(0),[inf,1],[1,0]),
%# coder.typeof(int32(0),[inf,1],[1,0]), coder.typeof(int32(0),[inf,1],[1,0])}


nelements=int32(size(elems_type,1));
newlength=int32(size(elems_buf,1))+nelements;
elems_hyb=nullcopy(zeros(newlength,1,'int32'));

offset=int32(1);
for i=1:nelements
    elems_hyb(offset)=elems_type(i);
    elems_hyb((offset+1):offset+elems_type(i),1) = ...
        elems_buf(elems_offsets(i)+1:elems_offsets(i)+1+elems_type(i)-1);
    offset=offset+elems_type(i)+1;
end
%END FUNCTION

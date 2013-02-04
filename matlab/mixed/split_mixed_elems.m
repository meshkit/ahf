function [elems_buf, elems_type, elems_offsets] = split_mixed_elems( elems)
% Split the connectivity table of mixed elements into two parts.
%
% [elems_buf, elems_type, elems_offsets] = split_mixed_elems( elems)
%
% If the table has only one type of elements, then elems_type will
% be a single value. Otherwise, elems_type will contain an array.

%#codegen -args {coder.typeof(int32(0),[inf,1],[1,0])}

% Count the number of elements.
ne = int32(0); offset_in=int32(1); etype=elems(offset_in);
while offset_in < length(elems)
    ne = ne + 1;

    if etype~=elems(offset_in); etype=int32(0); end

    offset_in = elems(offset_in) + offset_in + 1;
end

% If there is only one type, make elems_buf a 2-d array.
if etype; 
    elems_type = zeros(0,1,'int32');
    elems_offsets = zeros(0,1,'int32');
    elems_buf = nullcopy(zeros(ne,etype,'int32'));
    
    offset = int32(1);
    for i=1:ne
        elems_buf(i,:) = elems(offset+1:offset+etype);
        offset = offset+etype+1;
    end
    return;
end
    
% Initialize memory space.
elems_buf = nullcopy(zeros(length(elems)-ne,1,'int32'));
elems_type = nullcopy(zeros(ne,1,'int32'));
if nargout>2;
    elems_offsets  = nullcopy(zeros(ne,1,'int32'));
end

% Assign elems_type and elems_buf.
ne = int32(0); offset_in=int32(1); offset_buf=int32(1);
while offset_in < length(elems)
    ne = ne + 1;
    
    elems_type(ne) = elems(offset_in);
    if nargout>2; elems_offsets(ne) = offset_buf-1; end
    
    elems_buf(offset_buf:offset_buf+elems(offset_in)-1) = ...
        elems(offset_in+1:offset_in+elems(offset_in));
    offset_buf = offset_buf + elems(offset_in);
    offset_in = offset_in + elems(offset_in) + 1;
end

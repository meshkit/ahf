function [new_elems, typestr]=check_mixed(elems,nelems,element_type,icelldim,typestr)%#codegen
assert(isa(elems,'int32') && size(elems,1)>=1 && size(elems,2)==1);
assert(isa(nelems,'int32'));
assert(isa(element_type,'int32'));
assert(isa(icelldim,'int32'));
assert(isa(typestr,'char') && size(typestr,2)>=1);

% Check that mesh is indeed MIXED
num_type = elems(1);
new_elems = elems;
for ii = 2:nelems
    if num_type~=elems(1+(num_type+1)*(ii-1))
        num_type = int32(0);
        break;
    end
end

% Convert MIXED2 and MIXED3 types to actual types, if they have been
% mislabeled.  Additionally change ELEMS so that it is the correct type of
% output matrix.

if num_type ~= 0
    new_elems = zeros(nelems,num_type,'int32');
    for ii = 1:nelems
        new_elems(ii,:) = elems((num_type+1)*(ii-1)+2:(num_type+1)*(ii-1)+(num_type+1));
    end
    [~,typestr] = get_elemtype_string( element_type, icelldim);
end
end

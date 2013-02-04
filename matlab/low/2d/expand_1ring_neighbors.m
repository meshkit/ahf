function be = expand_1ring_neighbors( ps, elems, be) %#codegen 
% Expand a set of elements to its 1-ring neighbor.
%   be = expand_1ring_neighbors( ps, elems, be)
% ps is mx3, containing vertex coordinates.
% elems contains element connectivity, and is nx3 (triangular), 
%     nx4 (quadrilateral), or nx1 (mixed).
% be is a bitmap for the elements.

bv = false( size(ps,1),1);

% Select vertices
for i=1:int32(size(elems,2))
    bv(elems(be,1)) = true;
end

% Select elements
for i=1:int32(size(elems,2))
    be = be | bv(elems(:,1));
end

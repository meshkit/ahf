function b = is_quadmesh(nv, elems) %#codegen
%IS_QUADMESH Determine mesh type.
% IS_QUADMESH(NV,ELEMS) Determines whether a given mesh is a quadrilateral 
% or mixed mesh versus a tetrahedral mesh. The following explains the
% input and output arguments.
%
% B = IS_QUADMESH(NV,ELEMS) checks whether given connectivity defines a
% valid quadrilateral mesh. Returns 0 if it is not quadrilateral mesh but 
% returns 1 otherwise.
%
% See also determine_opposite_halfface_tet

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1])}

if size(elems,2)~=4 || size(elems,2)==4 && ~all(elems(:,4))
    b = false;
else    
    opphfs = determine_opposite_halfface_tet( nv, elems);    
    b = ~any(any(opphfs,2));
end

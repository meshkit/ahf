function b = is_2dmesh(nv, elems) %#codegen
%IS_2DMESH Determine whether the input mesh connectivity is 2-D.
% IS_2DMESH(NV,ELEMS) Determines whether a given mesh is 2-D.
%
% B = IS_2DMESH(NV,ELEMS) checks whether the given connectivity defines a
% valid triangular or quadrilateral mesh. Returns true if it is and
% false otherwise.

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,27],[1,1])}

switch size(elems,2)
    case 1
        elems_out = regularize_mixed_elems(elems);
        if size(elems_out,2)>4
            b=false;
        elseif size(elems_out,2)<4 || any(elems_out(:,end)==0)
            b=true;
        else
            opphfs = determine_opposite_halfface_tet( nv, elems_out);
            b = ~any(any(opphfs,2));
        end
    case 3
        % Allow triangles to be non-oriented
        opphes = determine_nextpage_surf( nv, elems);
        b = any(any(opphes,2));
    case 4
        if any(elems(elems(:,1)~=0,4)==0)
            % If mesh contains triangles, then it cannot be tet mesh
            b = true;
        else
            opphfs = determine_opposite_halfface_tet( nv, elems);
            b = ~any(any(opphfs,2));
        end
    case 6
        opphfs = determine_opposite_halfface_prism( nv, elems);
        b = ~any(any(opphfs,2));
    case 8
        opphfs = determine_opposite_halfface_hex( nv, elems);
        b = ~any(any(opphfs,2));
    case 9
        b = true;
    otherwise
        b = false;
end

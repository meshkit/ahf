function [bitmap, err] = set_bitmap_edge(itet, iface, iedge, ...
    elems, elems_offsets, elems_type, inset, reg_opphfs, bitmap, b) %#codegen 
% Set a bitmap for all the copies of a given edge to b, assuming that
%     the edge is in the interior of the mesh.
% Input:
%     itet:  element ID of a tetrahedron
%     iface: local face ID within the tetrahedron
%     iedge: local edge ID within face <itet, iface>
%     elems: the element connectivity in 1-D array
%     elems_offsets: the offset for each element
%     elems_type: the type of each element
%     inset: specifies whether each element is inside
%     reg_opphfs: opposite half-faces in 2-D array
%     bitmap: a bitmap for each edge of each element.
%     b: 0 or 1
% Output:
%     bitmap: a bitmap for each edge of each element.
%     err: an error code

IS_BND=-1;
IS_NOT_TET=-2;

tetface_nodes = [1 3 2; 1 2 4; 2 3 4; 3 1 4];
tetface_adjlfid = [4 3 2; 1 3 4; 1 4 2; 1 2 3];
tetface_edges=[3 2 1; 1 5 4; 2 6 5; 3 4 6];

next = [2 3 1];

v1 = elems(elems_offsets(itet)+tetface_nodes(iface, next(iedge)));
v2 = elems(elems_offsets(itet)+tetface_nodes(iface, iedge));

% Loop through the tetrahedra around the edge
tet_start = itet;
err = 0;  ntets = 0;
while true
    %Determine the next tetrahedron across the shared edge
    opphf = reg_opphfs(itet, tetface_adjlfid(iface, iedge));
    
    bitmap(itet) = bitset( bitmap(itet), tetface_edges(iface, iedge), b);
    
    if opphf<=0 % We have reached at boundary
        err = IS_BND; break;
    end
    
    % Locate the next tet and its local face edge containing v1-v2
    itet = hfid2cid( opphf);
    if elems_type(itet) ~= 4 || inset(itet)<=0
        err = IS_NOT_TET; break;
    end
    
    if itet == tet_start
        break; % Finished the rotation around the edge.
    end
    
    % Locate the next local face ID.
    iface = hfid2lfid( opphf); found=false;
    for iedge = 1:3
        if elems(elems_offsets(itet) + tetface_nodes(iface,next(iedge))) == v1
            assert( elems(elems_offsets(itet)+tetface_nodes(iface,iedge)) == v2);
            found=true;
            break;
        end
    end
    assert(found);
    
    ntets = ntets+1;
    if ntets>=1000
        error( 'set_bitmap_edge seems to have run into an infinite loop');
    end
end

return
end

function opphes = determine_opposite_halfedge(nv, elems, opphes) %#codegen
%DETERMINE_OPPOSITE_HALFEDGE determines the opposite half-edge of 
% each halfedge for an oriented, manifold surface mesh with or
% without boundary. It works for both triangle and quadrilateral 
% meshes that are either linear and quadratic.
%
% OPPHES = DETERMINE_OPPOSITE_HALFEDGE(NV,ELEMS)
% OPPHES = DETERMINE_OPPOSITE_HALFEDGE(NV,ELEMS,OPPHES)
% computes mapping from each half-edge to its opposite half-edge. This 
% function supports triangular, quadrilateral, and mixed meshes.
%
% Convention: Each half-edge is indicated by <face_id,local_edge_id>.
%    We assign 2 bits to local_edge_id.
%
% See also DETERMINE_NEXTPAGE_SURF, DETERMINE_INCIDENT_HALFEDGES


if nargin<3
    switch size(elems,2)
        case {3,6} % tri
            opphes = determine_opposite_halfedge_tri(nv, elems);
        case {4,8,9} % quad
            opphes = determine_opposite_halfedge_quad(nv, elems);
%         case 1
%             assert(false);
%             % TODO: Implement support for mixed elements
%             % opphes = determine_opposite_halfedge_mixed(nv, elems);
        otherwise
            error('Unsupported element type.');
            opphes = zeros( 0, 3, 'int32'); %#ok<UNRCH>
    end
else
    switch size(elems,2)
        case {3,6} % tri
            opphes = determine_opposite_halfedge_tri(nv, elems, opphes);
        case {4,8,9} % quad
            opphes = determine_opposite_halfedge_quad(nv, elems, opphes);
%         case 1
%             assert(false);
%             % TODO: Implement support for mixed elements
%             % opphes = determine_opposite_halfedge_mixed(nv, elems, opphes);
%             opphes = zeros( 0, 3, 'int32');
        otherwise
            error('Unsupported element type.');
            opphes = zeros( 0, 3, 'int32'); %#ok<UNRCH>
    end    
end

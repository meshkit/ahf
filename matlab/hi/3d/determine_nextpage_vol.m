function nxtpgs = determine_nextpage_vol( nv, elems, nxtpgs) %#codegen
%DETERMINE_NEXTPAGE_VOL constructs an extended half-face data structure 
% for a non-oriented or non-manifold volume mesh. 
%
% NXTPGS = DETERMINE_NEXTPAGE_VOL(NV,ELEMS)
% NXTPGS = DETERMINE_NEXTPAGE_VOL(NV,ELEMS,NXTPGS)
% Computes mapping from each half-face to its opposite half-face.  
% If NXTPGS is not given at input, it is allocated by the
% function.
%
% See also DETERMINE_NEXTPAGE_VOL, DETERMINE_INCIDENT_HALFFACES.

% Convention: Three bits are used for local face ID within each element.

if nargin<3; nxtpgs = []; end

if size(elems,2)==4
    nxtpgs = determine_nextpage_tet(nv, elems, nxtpgs);
else
    error('Unsupported element type.');
end

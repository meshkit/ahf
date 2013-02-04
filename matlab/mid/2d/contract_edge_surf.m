function [nv, nf, tris, opphes, v2he] = contract_edge_surf...
    (heid, nv, nf, tris, opphes, v2he) %#codegen 
% CONTRACT_EDGE_SURF    Contract an edge.
%   [NV, NF, TRIS, OPPHES] = ...
%       CONTRACT_EDGE_SURF(HEID, NV, NF, TRIS, OPPHES)
%   [NV, NF, TRIS, OPPHES, V2HE] = ...
%       CONTRACT_EDGE_SURF(HEID, NV, NF, TRIS, OPPHES, V2HE)
%
%   The function contracts an edge with half-edge ID heid, deletes its
%   incident faces and origin vertex, and updates the connectivity
%   accordingly. 
%
%   This function assumes that the origin of the halfedge to be removed 
%   is the last vertex (with vertex id NV), and its incident triangles 
%   are at the end of the triangle list.
%   
%   See also SPLIT_EDGE_SURF.

% TODO:
% 1. Implement the checking of the link condition for edge contraction.
% 2. Implement swapping of vertex and triangles before calling this function.

assert( nargout==5 && nargin==6 || nargout==4 && nargin==5);

% For now, assume origin of the halfedge is the last vertex.
% Assume the triangles to be removed are at the end of the triangle list.
fid = heid2fid(heid); lid = heid2leid(heid);
assert( tris(fid,lid)==nv);

fid_opp = heid2fid(opphes(fid,lid));
lid_opp = heid2leid(opphes(fid,lid));
assert( fid_opp~=0 && fid>=nf-1 && fid_opp>=nf-1 || fid_opp==0 && fid==nf);

prev = [3 1 2];
next = [2 3 1];

if istetrahedron( fid, tris, opphes)
    % If only four faces or two faces left, then remove the whole
    % component. Note that there could be multiple connected components.
    assert(false);

    return;
else
    nv = nv - 1;
    if ~fid_opp
        % Is border face, then remove only one triangle
        nf = nf - 1;
    else
        nf = nf - 2;
    end
    
    org = tris( fid, lid); dst = tris( fid, next(lid));
    
    % Rotate around the origin vertex in counterclockwise order
    % and replace it by the destination vertex of heid
    if nargin<6
        h = update_incident_halfedge( heid, tris, opphes);
        fstart = heid2fid(h); lstart=heid2leid(h);
    else
        fstart = heid2fid(v2he(org)); lstart=heid2leid(v2he(org));
    end
    f=fstart; l=lstart;
    tris(f,l) = dst;
    
    while 1
        opp = opphes(f,prev(l));
        f = heid2fid(opp); l=heid2leid(opp);
        
        if f==fstart && l==lstart || f==0
            break;
        end
        
        assert( tris(f,l)==org);
        tris(f,l) = dst;
    end
    
    % Make opphes(fid, next(lid)) and opphes(fid, prev(lid)) point to each other
    hnext = opphes( fid, next(lid));
    hprev = opphes( fid, prev(lid));
    if hnext; opphes( heid2fid(hnext), heid2leid(hnext)) = hprev; end
    if hprev; opphes( heid2fid(hprev), heid2leid(hprev)) = hnext; end
    
    if fid_opp
        % Make opphes(fid_opp, next(lid_opp)) and opphes(fid_opp, prev(lid_opp))
        % point to each other
        hnext_opp = opphes( fid_opp, next(lid_opp));
        hprev_opp = opphes( fid_opp, prev(lid_opp));
        if hnext_opp; opphes( heid2fid(hnext_opp), heid2leid(hnext_opp)) = hprev_opp; end
        if hprev_opp; opphes( heid2fid(hprev_opp), heid2leid(hprev_opp)) = hnext_opp; end
    else
        hnext_opp = 0;
        hprev_opp = 0;
    end
    
    % Update incident half-edges (v2he)
    if nargin>=6   
        v = tris(fid,prev(lid));
        if heid2fid( v2he(v))==fid
            if hprev
                v2he(v) = update_incident_halfedge(next_heid_tri(hprev), tris, opphes);
            elseif hnext
                v2he(v) = update_incident_halfedge(hnext, tris, opphes);
            else
                v2he(v) = 0;
            end
        end
        
        v = tris(fid,next(lid));
        if hprev
            v2he(v) = update_incident_halfedge(hprev, tris, opphes);
        elseif hnext
            v2he(v) = update_incident_halfedge(next_heid_tri(hnext), tris, opphes);
        elseif hprev_opp
            v2he(v) = update_incident_halfedge(hprev_opp, tris, opphes);
        else
            v2he(v) = update_incident_halfedge(next_heid_tri(hnext_opp), tris, opphes);
        end
        
        if fid_opp
            v = tris(fid_opp,prev(lid_opp));
            if heid2fid( v2he(v))==fid_opp
                if hprev_opp
                    v2he(v) = update_incident_halfedge(next_heid_tri(hprev_opp), tris, opphes);
                elseif hnext_opp
                    v2he(v) = update_incident_halfedge(hnext_opp, tris, opphes);
                else
                    v2he(v) = 0;
                end
            end
        end
        v2he(nv+1)=0;
    end
    
    % Reset connectivity of removed vertices and faces to zero
    tris(nf+1,:)=0; opphes(nf+1,:)=0;
    if fid_opp; tris(nf+2,:)=0; opphes(nf+2,:)=0; end
end

function b = istetrahedron( fid, tris, opphes)
% ISTETRAHEDRON: Determine whether a given triangle and its incident
%   adjacent faces form a tetrahedron.

if opphes(fid,1)==0 || opphes(fid,2)==0 || opphes(fid,3)==0
    b=false; return;
end

prev = [3 1 2];
v = tris( heid2fid(opphes(fid,1)), prev(heid2leid(opphes(fid,1))));
b = v == tris( heid2fid(opphes(fid,2)), prev(heid2leid(opphes(fid,2)))) && ...
    v == tris( heid2fid(opphes(fid,3)), prev(heid2leid(opphes(fid,3))));

function test %#ok<DEFNU>
%!test
%! xs = [1,1,0;
%!     2,1,0;
%!     3,1,0;
%!     1,2,0;
%!     2,2,0;
%!     3,2,0;
%!     1,3,0;
%!     2,3,0;
%!     3,3,0;
%!     4,2,0];
%! 
%! tris = int32([5,4,1;
%!     1,2,5;
%!     5,2,3;
%!     3,6,5;
%!     8,7,4;
%!     4,5,8;
%!     8,5,6;
%!     6,9,8;
%!     10,6,3]);
%! 
%! nv = int32(size(xs,1)); nf=int32(size(tris,1));
%! opphes = determine_opposite_halfedge(nv, tris);
%! v2he = determine_incident_halfedges(tris, opphes);
%! assert(verify_incident_halfedges(tris, opphes, v2he, nf));
%! 
%! tris = [tris; zeros(2,3,'int32')];
%! opphes = [opphes; zeros(2,3,'int32')];
%! v2he = [v2he; 0];
%! 
%! for i = 1 : 3
%!     for j = 1 : nf
%!         heid = 4*j + i - 1;
%!         [nv2, nf2, tris2, opphes2, v2he2] = split_edge_surf(heid, nv, nf, ...
%!             tris, opphes, v2he);
%!         assert(verify_incident_halfedges(tris2, opphes2, v2he2));
%!         if ~isequal(opphes2(1:nf2,:),determine_opposite_halfedge(nv2,tris2(1:nf2,:)))
%!             error('Failed checking');
%!         end
%!         if ~isequal( v2he2, determine_incident_halfedges(tris2,opphes2))
%!             error('Failed checking');
%!         end
%!         
%!         % Test contract edge.
%!         heid = 4*(nf+1)+i-1;
%!         [nv3, nf3, tris3, opphes3, v2he3] = contract_edge_surf(heid, ...
%!             nv2, nf2, tris2, opphes2, v2he2);
%!         assert(verify_incident_halfedges(tris3, opphes3, v2he3, nf3));
%!         if ~isequal(tris,tris3) || ~isequal(opphes3,opphes) || ~isequal(v2he3,v2he)
%!             error('Failed checking');
%!         end
%!     end
%! end

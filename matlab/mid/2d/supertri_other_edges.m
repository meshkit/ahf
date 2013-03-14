function [h2, h3, flist, vlist] = supertri_other_edges( h1, tris, sibhes) %#codegen 
% SUPERTRI_OTHER_EDGES
% Given a halfedge, obtain the other two halfedges of its largest 
%       "super-triangle" incident on it.

% NOTE: This function needs to be rewritten. 
%       Reference to supertri_other_edges.m.bak
% The algorithm rotates around the origin of h1 to get another candidate 
%     edge, and calls supertri_3rd_edge to see whether they determine a
%     supertriangle. Stop the rotation when it is impossible to 
%     have a supertriangle containing the two given halfedges.
%     (Expand supertri_3rd_edge to return such a verdict.)

h2=int32(0); h3=int32(0); flist = zeros(0,1,'int32'); vlist = zeros(0,1,'int32');
if h1==0; return; end

[h2, h3, flist, vlist, ~, h2next, h3next] = ...
    supertri_other_edges_helper( h1, tris, sibhes);

% Check whether h2next and h1 bound a supertriangle
if h2next
    [h3, flist, vlist] = supertri_3rd_edge( h1, h2next, tris, sibhes);
end  

% Check whether h3tmp and h1 bound a supertriangle
if h3next
    [h3, flist, vlist] = supertri_3rd_edge( h1, h2, tris, sibhes);
end  

function [h2, h3, flist, vlist, h2next, h3next] = ...
    supertri_other_edges_helper( h1, tris, sibhes)
prev = int32([3 1 2]); next = int32([2 3 1]);

fid1 = heid2fid( h1);  leid1 = heid2leid(h1);
fid2 = fid1;  leid2 = next(leid1);
fid3 = fid1;  leid3 = next(leid2);

MAXN = 10;
flist = nullcopy(zeros(MAXN,1,'int32'));
vlist = nullcopy(zeros(MAXN,1,'int32'));
nf = int32(1); flist(1) = fid1;
nv = int32(0);

% Rotate around the origin of h1
while true
    opp = sibhes( fid2, leid2);
    if ~opp
        f2tmp = int32(0); l2tmp = int32(0); 
    else
        f2tmp = heid2fid(opp); l2tmp = next(heid2leid(opp));
    end
    
    opp = sibhes( fid3, leid3);
    if ~opp
        f3tmp = int32(0); l3tmp = int32(0);
    else
        f3tmp = heid2fid(opp); l3tmp = prev(heid2leid(opp));
    end

    if f2tmp && f3tmp && tris( f2tmp, next(l2tmp)) == tris( f3tmp, l3tmp)
        if nv>=MAXN; error('Buffer overflow.'); end
        nv = nv + 1; vlist(nv) = tris( fid3, leid3);

        fid2 = f2tmp; leid2 = l2tmp;        
        fid3 = f3tmp; leid3 = l3tmp;
        
        if nf+2>MAXN; error('Buffer overflow.'); end
        flist(nf+1) = fid2; flist(nf+2) = fid3; nf = nf + 2;
    else
        break;
    end
end

h2 = fleids2heid( fid2, leid2);  
if f2tmp; h2next = fleids2heid( f2tmp, l2tmp); else h2next = 0; end
h3 = fleids2heid( fid3, leid3);  
if f3tmp; h3next = fleids2heid( f3tmp, l3tmp); else h3next = 0; end

flist(nf+1:end) = [];
vlist(nv+1:end) = [];

function test %#ok<DEFNU>
%!test
%!
%! xs = [1,1,0;
%!     2,1,0;
%!     3,1,0;
%!     1,2,0;
%!     2,2,0;
%!     3,2,0;
%!     1,3,0;
%!     2,3,0;
%!     3,3,0;
%!     2.75,1.75,0];
%! 
%! tris = int32([5,4,1;
%!     1,2,5;
%!     5,2,3;
%!     3,6,10;
%!     6,5,10;
%!     5,3,10;
%!     8,7,4;
%!     4,5,8;
%!     8,5,6;
%!     6,9,8]);
%! 
%! nv = int32(size(xs,1)); nf=int32(size(tris,1));
%! sibhes = determine_opposite_halfedge(nv, tris);
%! v2he = determine_incident_halfedges(tris, sibhes);
%! assert(verify_incident_halfedges(tris, sibhes, v2he, nf));
%! flist = zeros(10,1,'int32'); vlist = zeros(10,1,'int32');
%! 
%! h1 = fleids2heid(3,1); 
%! [h2, h3, flist, vlist] = supertri_other_edges( h1, tris, sibhes);
%! assert( h2 == fleids2heid(3,2) && h3==fleids2heid(3,3) && ...
%!       length(flist)==1 && flist(1) == 3 && length(vlist)==0);
%! 
%! h1 = fleids2heid(4,1); 
%! [h2, h3, flist, vlist] = supertri_other_edges( h1, tris, sibhes);
%! assert( h2 == fleids2heid(5,1) && h3==fleids2heid(6,1) && ...
%!       length(flist)==3 && length(vlist)==1);

function [h3, flist, vlist] = supertri_3rd_edge( h1, h2, tris, sibhes) %#codegen 
% SUPERTRI_3RD_EDGE
% Given two halfedges, determine whether they bound a super-triangle.
% If so, return the halfedge of the third halfedge of the super-triangle.
%
%  [H3, FLIST, VLIST] = SUPERTRI_3RD_EDGE( H1, H2, TRIS, SIBHES)
%
% A "super-triangle" is a patch composed of the triangles that are bounded
% by three edges and three vertices and are also incident on at least one
% of these vertices.

coder.extrinsic('warning');

h3=int32(0);
if h1==h2 || h1==0 || h2==0;
    flist=zeros(0,1,'int32'); vlist=zeros(0,1,'int32'); return;
end

next = int32([2 3 1]);

fid1 = heid2fid( h1);     leid1 = heid2leid(h1);
fid2 = heid2fid( h2);     leid2 = heid2leid(h2);

if fid1 == fid2
    h3 = fleids2heid( fid1, 6-leid1-leid2);
    flist = fid1; vlist = zeros(0,1,'int32');
    return;
elseif tris(fid1,next(leid1))==tris(fid2,leid2)
    [h3, flist, vlist] = get_3rd_edge( fid1, leid1, fid2, leid2, tris, sibhes);
elseif tris(fid1,leid1)==tris(fid2,next(leid2))
    [h3, flist, vlist] = get_3rd_edge( fid2, leid2, fid1, leid1, tris, sibhes);
else
    h3 = int32(0); flist = zeros(0,1,'int32'); vlist = zeros(0,1,'int32');
    return;
end

function [h3, flist, vlist] = get_3rd_edge( fid1, leid1, fid2, leid2, tris, sibhes)

% Precondition: The tail of (fid1,leid1) is the same as the head of (fid2,leid2).
MAXNF=20; MAXNV=20;
flist = nullcopy(zeros(MAXNF,1,'int32')); 
vlist = nullcopy(zeros(MAXNV,1,'int32'));

prev = int32([3 1 2]);
next = int32([2 3 1]);

vstart = tris( fid2, leid2); vend = tris( fid2, next(leid2));
h3 = int32(0);
fid1_start = fid1; leid1_start = leid1;
h2 = fleids2heid(fid2,leid2);

assert( length(flist)>=2);
nf=int32(2); nv = int32(0);
flist(1) = fid1_start; flist(2) = fid2;

% Loop around the head of halfedge (fid1,leid).
while true
    if sibhes(fid1,leid1)==h2;
        h3=int32(0); break;
    end
    
    leid1_prev = prev(leid1);
    v = tris( fid1, leid1_prev);
    if v==vend
        % We have found the edge!
        h3 = fleids2heid(fid1, leid1_prev);
        break;
    elseif nv<length(vlist)
        nv = nv+1; vlist(nv) = v;
    else
        warning('Buffer overflow for vlist.');
    end
    
    h = sibhes( fid1, leid1_prev);
    
    fid1 = heid2fid( h); leid1 = heid2leid( h);
    if fid1<=0 || fid1==fid1_start
        break;
    end
    
    % check whether the opposite face is incident on either v or vend
    oppface = heid2fid( sibhes( fid1, next(leid1)));
    if oppface<=0 || all(tris(oppface,1:3)~=vstart) && all(tris(oppface,1:3)~=vend)
        break;
    end
    
    if nf>=length(flist)
        warning('Buffer overflow for flist.');
    else
        nf=nf+1; flist(nf) = fid1;
    end
end

if h3==0
    % If it did not find the edge, then reset flist and vlist.
    nf = int32(0); nv=int32(0); flist = zeros(0,1,'int32'); vlist = zeros(0,1,'int32');
elseif nv>0
    % Add other faces incident on the two vertices of h2 info flist.
    % This part is not optimized, since it is called very rarely.
    h = sibhes( fid1_start, next(leid1_start));
    f = heid2fid(h);
    
    if f~=fid2
        assert(false); % Yet to be debugged.
        while f ~= fid2
            if nf>=length(flist)
                warning('Buffer overflow for flist.');
            else
                nf=nf+1; flist(nf) = f;
            end
            
            leid=next( heid2leid(h));
            v = tris( f, next(leid));
            if ~any( vlist(1:nv)==v)
                if nv<length(vlist)
                    nv = nv+1; vlist(nv) = v;
                else
                    warning('Buffer overflow for vlist.');
                end
            end
            
            h = sibhes( f, leid);
            f = heid2fid(h);
        end
        
        h = sibhes( fid2, next(leid2));
        f = heid2fid(h);  fid3 = heid2fid( h3);
        while f ~= fid3
            if nf>=length(flist)
                warning('Buffer overflow for flist.');
            else
                nf=nf+1; flist(nf) = f;
            end
            
            leid=next( heid2leid(h));
            v = tris( f, next(leid));
            if ~any( vlist(1:nv)==v)
                if nv<length(vlist)
                    nv = nv+1; vlist(nv) = v;
                else
                    warning('Buffer overflow for vlist.');
                end
            end
            h = sibhes( f, leid);
            f = heid2fid(h);
        end
    end
end

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
%! sibhes = determine_sibling_halfedges(nv, tris);
%! v2he = determine_incident_halfedges(nv, tris, sibhes);
%! assert(verify_incident_halfedges(tris, sibhes, v2he, nf));
%! flist = zeros(10,1,'int32'); vlist = zeros(10,1,'int32');
%!
%! h1 = fleids2heid(4,1); h2 = fleids2heid(4,2);
%! [h3, flist, vlist] = supertri_3rd_edge( h1, h2, tris, sibhes);
%! assert( h3==fleids2heid(4,3) && length(flist)==1 && flist(1) == 4 && isempty(vlist));
%!
%! h1 = fleids2heid(4,1); h2 = fleids2heid(3,2);
%! [h3, flist, vlist] = supertri_3rd_edge( h1, h2, tris, sibhes);
%! assert( h3==0 && isempty(flist) && isempty(vlist));
%!
%! h1 = fleids2heid(4,1); h2 = fleids2heid(6,1);
%! [h3, flist, vlist] = supertri_3rd_edge( h1, h2, tris, sibhes);
%! assert( h3==fleids2heid(5,1) && length(flist)==3 && length(vlist)==1);
%!

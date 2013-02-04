function [nf, tris, opphes, v2he] = mv_tris_toend_surf...
    ( flist, nf, tris, opphes, v2he) %#codegen 
% MV_TRIS_TOEND_SURF    Swap faces to the end of connectivity table.
%
% [nf, tris, opphes, v2he] = mv_tris_toend_surf...
%    ( flist, nf, tris, opphes, v2he)
%
% See also MV_VERTS_TOEND_SURF, SEAL_HOLE

% Count the number of unique entries in flist.
for i=1:int32(length(flist))
    tris(flist(i),1) = -1;
end

nf_todelete = 0;
for i=1:int32(length(flist))
    if tris(flist(i),1) == -1
        tris(flist(i),:) = 0;
        opphes(flist(i),:) = 0;
        nf_todelete = nf_todelete + 1;
    end
end

toswap = nf;
nf = nf - nf_todelete;

% Move list of faces to the end of tris
for i=1:int32(length(flist))
    f = flist(i);

    % tris(f,1) should be zero, except when flist has duplicate entries.
    if tris(f,1)==0 && f <= nf
        % Find first face with nonzeros
        while tris(toswap,1)==0
            assert( toswap > nf);
            toswap = toswap - 1;
        end
        
        [tris, opphes, v2he] = swap_tris_surf(f, toswap, tris, opphes, v2he);
    end
end

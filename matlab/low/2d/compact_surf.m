function [nf, tris, opphes, v2he, evs] = compact_surf( nv, nf, tris, opphes, v2he, evs) %#codegen 
%COMPACT_CURV    Compact the connectivity table to remove zero entries.
%   [NF, TRIS, OPPHES, V2HE, EVS] = ...
%   COMPACT_CURV( NV, NF, TRIS, OPPHES, V2HE, EVS) compacts the 
%   connectivity table to remove zero entries connecitivity table.
%   It should be performed after performing a series of edge contractions.

%#codegen -args {int32(0), int32(0), coder.typeof(int32(0),[inf,3],[1,0])
%# coder.typeof(int32(0),[inf,3],[1,0]), coder.typeof(int32(0),[inf,1],[1,0])
%# coder.typeof(int32(0),[inf,3],[1,0])}

assert( isa(nv, 'int32') && isa(nf, 'int32') && isa(tris, 'int32'));
assert( isa(opphes, 'int32') && isa(v2he, 'int32') && isa(evs, 'int32'));

% Make sure last entries have no zeros.
while nf >0 && ~tris(nf,1); 
    nf = nf - 1;
end

ii=1;
while ii<=nf
    if ~tris(ii,1)
        [tris, opphes, v2he] = swap_tris_surf( ii, nf, tris, opphes, v2he);
        
        if nargin>5; evs(ii,:) = evs(nf,:); end
        
        nf = nf - 1;
        while ~tris(nf,1); nf = nf -1; end
    end
    ii = ii+1;
end

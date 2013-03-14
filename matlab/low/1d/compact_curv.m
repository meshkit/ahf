function [ne, edgs, sibhvs, v2hv, evs] = compact_curv( nv, ne, edgs, sibhvs, v2hv, evs) %#codegen 
%COMPACT_CURV    Compact the connectivity table to remove zero entries.
%   [NE, EDGS, SIBHVS, V2HV, EVS] = ...
%   COMPACT_CURV( NV, NE, EDGS, SIBHVS, V2HV, EVS) compacts the 
%   connectivity table to remove zero entries connecitivity table.
%   It should be performed after performing a series of edge
%   contractions.

%#codegen -args {int32(0), int32(0), coder.typeof(int32(0),[inf,2],[1,0])
%# coder.typeof(int32(0),[inf,2],[1,0]), coder.typeof(int32(0),[inf,1],[1,0])
%# coder.typeof(int32(0),[inf,2],[1,0])}

assert( isa(nv, 'int32') && isa(ne, 'int32') && isa(edge, 'int32'));
assert( isa(sibhvs, 'int32') && isa(v2hv, 'int32') && isa(evs, 'int32'));

% Make sure last entries have no zeros.
while ne >0 && ~edgs(ne,1); 
    ne = ne - 1;
end

ii=1;
while ii<=ne
    if ~edgs(ii,1)
        [edgs, sibhvs, v2hv] = swap_edges_curv( ii, ne, edgs, sibhvs, v2hv);
        
        if nargin>5; evs(ii,:) = evs(ne,:); end
        
        ne = ne - 1;
        while ~edgs(ne,1); ne = ne -1; end
    end
    ii = ii+1;
end

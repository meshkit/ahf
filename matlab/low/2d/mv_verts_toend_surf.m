function [nv, tris, sibhes, v2he, xs] = mv_verts_toend_surf...
    ( vlist, nv, tris, sibhes, v2he, xs) %#codegen 
%MV_VERTS_TOEND_SURF    Swap vertices to the end of xs.
%  [nv, tris, sibhes, v2he, xs] = mv_verts_toend_surf...
%        ( vlist, nv, tris, sibhes, v2he, xs)
%
% See also MV_TRIS_TOEND_SURF, SEAL_HOLE

% Count the number of unique entries in vlist
for i=1:int32(length(vlist)); 
    xs(vlist(i),1)=0; 
end

nv_todelete = 0;
for i=1:int32(length(vlist))
    if xs(vlist(i),1)==0
        nv_todelete = nv_todelete + 1; 
        xs(vlist(i),:) = nan;
    end
end

% Move list of vertices to the end of xs
toswap = nv;
nv = nv - nv_todelete;

for i=1:int32(length(vlist))
    v = vlist(i);
    
    if isnan(xs(v,1)) && v <= nv
        % Find first vertex that is not nan
        while isnan(xs(toswap,1))
            assert( toswap > nv);
            toswap = toswap - 1;
        end
        
        [tris, sibhes, v2he, xs] = swap_vertices_surf( v, toswap, tris, ...
            sibhes, v2he, xs);
    end
end

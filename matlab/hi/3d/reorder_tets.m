function [xs_vol, tets, new2old] = reorder_tets( xs_vol, tets) %#codegen 
% Reorganize vertices of tetrahedral mesh to list border vertices first.
% Usage: [xs_vol, tets] = REORDER_TETS( xs_vol, tets)

b2v = extract_border_surf_mex( size(xs_vol,1), tets);

if b2v(end)~=size(b2v)
    % Need to reorder
    new2old = 1:int32(size(xs_vol,1)); new2old(b2v) = [];
    new2old = [b2v; new2old'];
    
    xs_vol = xs_vol(new2old,:);

    old2new = nullcopy(zeros(size(xs_vol,1),1,'int32'));
    old2new(new2old) = 1:int32(size(xs_vol,1));
    for jj=1:4
        tets(:,jj) = old2new(tets(:,jj));
    end
else
    new2old = 1:int32(size(xs_vol,1));
end

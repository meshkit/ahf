function [tris, sibhes, v2he, us] = swap_vertices_surf( vid1, vid2, tris, sibhes, v2he, us) %#codegen 
%SWAP_VERTICES_SURF    Swap two vertices in a triangle mesh.
%   [TRIS, SIBHES, V2HE] = ...
%   SWAP_VERTICES_CURV( VID1, VID2, EDGS, SIBHVS, V2HV) swaps two vertices
%       in connecitivity table.

if vid1==vid2; return; end

if (nargin > 5 && nargout < 4)
    error('not enough input arguments for requested number of output arguments');
end

% Update tris and sibhes
prev = [3 1 2];

% set vid1 to be vid2
st_heid = v2he(vid1);
cur_heid = st_heid;
while 1
    cur_fid = heid2fid(cur_heid); cur_lid = heid2leid(cur_heid);
    if cur_fid~=0
        tris(cur_fid,cur_lid) = vid2;
        cur_heid = sibhes(cur_fid,prev(cur_lid));
        if (~cur_heid || cur_heid == st_heid)
            break;
        end
    else
        break;
    end
end
% set vid2 to be vid1
st_heid = v2he(vid2);
cur_heid = st_heid;
while 1
    cur_fid = heid2fid(cur_heid); cur_lid = heid2leid(cur_heid);
    if cur_fid~=0
        tris(cur_fid,cur_lid) = vid1;
        cur_heid = sibhes(cur_fid,prev(cur_lid));
        if (~cur_heid || cur_heid == st_heid)
            break;
        end
    else
        break;
    end
end

% Swap v2he
hv = v2he(vid1);
v2he(vid1) = v2he(vid2);
v2he(vid2) = hv;

if (nargout > 3)
    us_tmp = us(vid1,:);
    us(vid1,:) = us(vid2,:);
    us(vid2,:) = us_tmp;
end

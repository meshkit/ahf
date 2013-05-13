function [fid, lfid, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags) %#codegen
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,4]),coder.typeof(int32(0), [inf,4]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}
%%%#codegen determine_sibling_halffaces_usestruct -args
%%%#codegen {int32(0), coder.typeof(int32(0), [inf,inf]), false}



% For every face, obtain adjacent cells
vid1=faces(fid,1);
vid2=faces(fid,2);
vid3=faces(fid,3);
[found,fid,lvid1,lvid2,lvid3, etags] = examine_1ring_elems_tet_hf( vid1, vid2, vid3, tets, sibhfs, v2hf, etags);
hf=int32(0);

for i = 1 : size(etags,1)
    etags(i,1)=false;
end
if (found)
    [fid, lfid]=match_halfface(fid,lvid1,lvid2,lvid3);
else
    fid=int32(0);
    lfid=int32(0);
end


function [fid, lfid] = match_halfface(fid,lvid1,lvid2,lvid3)
%hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);

% it happens that we can uniquely match triplet [lvid1,lvid2,lvid3] to
% local face id using sum of local ids (for tet)

% sum = 6 -> lfid = 1
% sum = 7 -> lfid = 2
% sum = 8 -> lfid = 4
% sum = 9 -> lfid = 3
lfid_map=int32([1,2,4,3]);
lfid=lfid_map(lvid1+lvid2+lvid3-5);
hf=clfids2hfid(fid,lfid);



function [found,eid,lvid1,lvid2,lvid3, etags] = examine_1ring_elems_tet_hf(vid1, vid2, vid3, tets, sibhfs, v2hf, etags)
%OBTAIN_1RING_ELEMS_TET Collects 1-ring neighbor elements of tet mesh.
% [NGBES, NELEMS, ETAGS] = OBTAIN_1RING_ELEMS_TET( VID, ...
%         TETS, SIBHFS, V2HF, NGBES, ETAGS)
% Collects 1-ring neighbor elements of given vertex and saves them into
% NGBES. At input, ETAGS must be set to false. It is reset to false
% at output.
%hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);

coder.extrinsic('warning');

found = false;
eid=0;
% Obtain incident tetrahedron of vid.
eid = hfid2cid(v2hf(vid1));

lvid1 = int32(0); lvid2 = int32(0); lvid3 = int32(0);
if ~eid; return; end

sibhfs_tet = int32([1 2 4; 1 2 3; 1 3 4; 2 3 4]);

MAXTETS=50;
% Create a stack for storing tets and insert element itself into stack
stack = nullcopy(zeros(MAXTETS,1, 'int32'));
size_stack = int32(1); stack(1) = eid;

while size_stack>0
    % Pop the element from top of stack
    eid = stack(size_stack); size_stack = size_stack-1;
    etags(eid) = true;
    
    lvid1 = int32(0); % Stores which vertex vid is within the tetrahedron.
    lvid2 = int32(0);
    lvid3 = int32(0);
   
    for ii=int32(1):4
        v = tets(eid,ii);
        if v==vid1; lvid1 = ii; end
        if v==vid2; lvid2 = ii; end;
        if v==vid3; lvid3 = ii; end;
    end
    
    if (lvid1 && lvid2 && lvid3)
        if lvid1==lvid2 || lvid1==lvid3 || lvid2==lvid3
            %fprintf('?\n');
        end
        % found matching face
        found = true;
        etags(stack(1:size_stack,1),1) = false;
        return;
    end
    
    % Push unvisited neighbor tets onto stack
    for ii=1:3
        ngb = hfid2cid(sibhfs(eid,sibhfs_tet(lvid1,ii)));
        if ngb && ~etags(ngb);
            size_stack = size_stack + 1; stack(size_stack) = ngb;
        end
    end
end
etags(stack(1:size_stack,1),1);
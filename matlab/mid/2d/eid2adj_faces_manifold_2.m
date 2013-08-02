function [found, flist, nfaces, ftags]=eid2adj_faces_manifold_2(eid,edges,tris,v2he,sibhes,flist,ftags,varargin)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,1]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}

type_struct = isstruct(sibhes);
vid1=edges(eid,1);
vid2=edges(eid,2);
[found,fid,lvid1,lvid2,ftags] = examine_1ring_surf_he( vid1, vid2, tris, sibhes, v2he, ftags);

if (found)
    lid=match_halfedge(lvid1,lvid2);
    if type_struct
        sibhe.fid=sibhes.fid(fid,lid); sibhe.leid=sibhes.leid(fid,lid);
        if (sibhe.fid ==0)
            flist(1,1) = int32(fid);nfaces = int32(1);
        else            
            flist(1,1) = int32(fid);
            flist(2,1) = int32(sibhe.fid);
            nfaces = int32(2);
        end
    else
        sibhe=sibhes(fid,lid);
        sibhe_fid = heid2fid(sibhe);
        if (sibhe_fid ==0)
            flist(1,1) = int32(fid);nfaces = int32(1);
        else            
            flist(1,1) = int32(fid);
            flist(2,1) = int32(sibhe_fid);
            nfaces = int32(2);            
        end
    end
else
    found = true; nfaces = int32(0);
end




function [lfid] = match_halfedge(lvid1,lvid2)
%hf_tet    = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);

% it happens that we can uniquely match triplet [lvid1,lvid2,lvid3] to
% local face id using sum of local ids (for tet)

% sum = 6 -> lfid = 1
% sum = 7 -> lfid = 2
% sum = 8 -> lfid = 4
% sum = 9 -> lfid = 3
lfid_map=int32([1,3,2]);
lfid=lfid_map(lvid1+lvid2-2);


function [found,fid,lvid1,lvid2, ftags] = examine_1ring_surf_he(vid1, vid2, tris, sibhes, v2he, ftags)
coder.extrinsic('warning');
found = false;

% Obtain incident half-edge of vid.
if isstruct(v2he)
    fid = v2he.fid(vid1);
else
    fid = heid2fid(v2he(vid1));
end

lvid1 = int32(0); lvid2 = int32(0);
if ~fid; return; end

sibhes_tri = int32([1 3; 1 2; 2 3]);

MAXTRIS=50;
% Create a stack for storing tris and insert element itself into stack
stack = nullcopy(zeros(MAXTRIS,1, 'int32'));
queue = nullcopy(zeros(MAXTRIS,1, 'int32')); count = int32(0);
size_stack = int32(1); stack(1) = fid;

while size_stack>0
    % Pop the element from top of stack
    fid = stack(size_stack); size_stack = size_stack-1;
    ftags(fid) = true;
    count = count+1;
    queue(count)=fid;
    
    lvid1 = int32(0); % Stores which vertex vid is within the triangle.
    lvid2 = int32(0);
    
    for ii=int32(1):3
        v = tris(fid,ii);
        if v==vid1; lvid1 = ii; end
        if v==vid2; lvid2 = ii; end;
    end
    
    if (lvid1 && lvid2)
        %         if lvid1==lvid2 || lvid1==lvid3 || lvid2==lvid3
        %             %fprintf('?\n');
        %         end
        % found matching face
        found = true;
        for i=1:count
            ftags(queue(i)) = false;
        end
        %etags(stack(1:size_stack,1),1) = false;
        return;
    end
    
    % Push unvisited neighbor tets onto stack
    for ii=1:2
        if isstruct(sibhes)
            ngb = sibhes.fid(fid,sibhes_tri(lvid1,ii));
        else
            ngb = heid2fid(sibhes(fid,sibhes_tri(lvid1,ii)));
        end
        if ngb && ~ftags(ngb);
            size_stack = size_stack + 1; stack(size_stack) = ngb;
        end
    end
end
for i=1:count
    ftags(queue(i)) = false;
end
%etags(stack(1:size_stack,1),1);
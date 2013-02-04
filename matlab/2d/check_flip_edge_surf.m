function OK = check_flip_edge_surf(heid, tris, opphes) %#codegen
% Check whether it is OK topologically to flip a given halfedge.
%   ok = check_flip_edge_surf(heid, tris, opphes)

fid = heid2fid(heid);
lid = heid2leid(heid);

% Cannot flip a border edge.
if ~opphes(fid, lid); OK = false; return; end

fid_opp = heid2fid(opphes(fid,lid));
lid_opp = heid2leid(opphes(fid,lid));

prev = int32([3 1 2]);
next = int32([2 3 1]);

% First rotate around vertex in counterclockwise order
vid_opp = tris(fid_opp, prev(lid_opp));
fid_start = fid; lid = prev(lid);
count = int32(1);
while true
    fid_next = heid2fid( opphes( fid, lid));
    if fid_next == fid_start
        OK = true; return;
    end
    if fid_next ==0; break; end
    
    lid_next = next(heid2leid( opphes( fid, lid)));
    if tris( fid_next, next( lid_next)) == vid_opp
        OK = false; return;
    end
    
    fid = fid_next; lid = lid_next;
    count = count + 1; 
    if (count>100);
        error('check_flip_edge_surf seems to have run into infinite loop.'); 
    end
end

% Continue to rotate in clockwise order for border vertices
vid_opp = tris(fid_opp, prev(lid_opp));
fid = fid_start; lid = next(heid2leid(heid));

while true
    fid_next = heid2fid( opphes( fid, lid));
    if fid_next==0; break; end
    
    lid_next = prev(heid2leid( opphes( fid, lid)));
    if tris( fid_next, lid_next) == vid_opp
        OK = false; return;
    end
    
    fid = fid_next; lid = lid_next;
    
    count = count + 1; 
    if (count>100);
        error('check_flip_edge_surf seems to have run into infinite loop.'); 
    end
end

OK = true;

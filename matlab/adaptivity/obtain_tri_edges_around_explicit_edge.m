function [nTris, tris_1ring, leids_1ring] = obtain_tri_edges_around_explicit_edge(eid, edges, tris, v2he, sibhes)

%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,1]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}

% This function takes an explicit edge and returns the list of incident
% triangles and local id's of the edge wrt to the incident triangles

type_struct = isstruct(v2he);
ftags=false(size(tris,1),1);
MAXFACES=150;
tris_1ring=zeros(MAXFACES,1,'int32');
leids_1ring=zeros(MAXFACES,1,'int32');
nTris=int32(0);

[heid,ftags] = obtain_1ring_surf_he( edges(eid,1), edges(eid,2), tris, sibhes, v2he, ftags);

if ~type_struct
    if (heid==0);  tris_1ring=zeros(1,1,'int32'); leids_1ring=zeros(1,1,'int32'); return;   end;
else
    if (heid.fid==0);  tris_1ring=zeros(1,1,'int32'); leids_1ring=zeros(1,1,'int32'); return;   end;
end


if  ~type_struct
    tris_1ring(1,1) = int32(heid2fid(heid));
    leids_1ring(1,1) = int32(heid2leid(heid));
else    
    tris_1ring(1,1) = int32(heid.fid);
    leids_1ring(1,1) = int32(heid.lid);
end

nTris=int32(1);

if ~type_struct
    [helist,nhes,ftags]=loop_sbihes(heid,sibhes,zeros(MAXFACES,1),0,ftags);
else
    helist.fid=zeros(MAXFACES,1);   helist.leid=zeros(MAXFACES,1);
    [helist,nhes,ftags]=loop_sbihes(heid,sibhes,helist,0,ftags,true);
end

for i = 1 : nhes
    nTris=nTris+1;
    if ~type_struct
        tris_1ring(nTris,1) = int32(heid2fid(helist(i)));
        leids_1ring(nTris,1) = int32(heid2leid(helist(i)));        
    else
        tris_1ring(nTris,1) = int32(helist.fid(i));
        leids_1ring(nTris,1) = int32(helist.lid(i));
    end
end


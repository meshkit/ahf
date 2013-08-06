function test_eid2faces_top(mesh)
%#codegen -args { struct('xs', coder.typeof(0,[inf,3]),
%#codegen 'edges', coder.typeof(int32(0),[inf,2]),
%#codegen 'faces', coder.typeof(int32(0),[inf,inf]),
%#codegen 'tets', coder.typeof(int32(0),[inf,inf]), 
%#codegen 'v2hv', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2he', coder.typeof(int32(0),[inf,inf]),
%#codegen 'v2hf', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhvs', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhes', coder.typeof(int32(0),[inf,inf]),
%#codegen 'sibhfs', coder.typeof(int32(0),[inf,inf])) }

ftags=false(size(mesh.faces,1),1);

MAXFACES = 1000;
coder.varsize('flist',MAXFACES);
flist_1=zeros(MAXFACES,1,'int32');
t1 = wtime; 
for eid = int32(1) : size(mesh.edges,1)     
   % [flist_1, nfaces_1, ftags]=eid2adj_faces_top(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,flist_1,ftags);
     [flist_1, nfaces_1, ftags]=eid2adj_faces(eid,mesh.edges,mesh.faces,mesh.v2he,mesh.sibhes,flist_1,ftags);
    flist_1 = refv(flist_1); nfaces_1 = refv(nfaces_1);   
end
time_eid2adj_faces=(wtime-t1)/size(mesh.edges,1);
msg_printf('Average adjacent faces: Time = %g secs\n',time_eid2adj_faces);


end


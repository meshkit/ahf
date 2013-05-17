function passed=test_obtain_neighbor_faces()
%% Test function obtain_neighbor_faces on different non-manifold cases

%% two "disks" intersecting in the middle. Each disk consist of 8 faces. Edges [8,9] and [4,9] are shared between disks.
test_mesh=int32([1,2,5;
           2,4,5;
           2,3,4;
           5,4,7;
           5,4,6;
           ]);
       
tris=test_mesh;
[sibhes] = construct_halfedges( 7, test_mesh);

sibhes_struct = determine_sibling_halfedges( 7, test_mesh, true);
passed=true;
for i = 1 : size(sibhes,1)
   for j = 1 :  size(sibhes,2)
       
    passed=passed && (heid2fid(sibhes(i,j))==sibhes_struct.fid(i,j)) && (heid2fid(sibhes(i,j))==0 || (heid2leid(sibhes(i,j))==sibhes_struct.leid(i,j)));
   end
end




%% Test 1.
fid=int32(1);
ngbfaces = obtain_neighbor_faces(fid,tris,sibhes);
passed=passed && size(ngbfaces,1)==1;
passed=passed&&(ngbfaces==2);

ngbfaces = obtain_neighbor_faces(fid,tris,sibhes_struct,true);
passed=passed && size(ngbfaces,1)==1;
passed=passed&&(ngbfaces==2);

if ~passed; warning('MATLAB:test','test 1 failed'); end;


%% Test 2.
fid=int32(2);
ngbfaces = obtain_neighbor_faces(fid,tris,sibhes);
passed=passed && size(ngbfaces,1)==4;
passed=passed&&(sum(sort(ngbfaces,1)-[1;3;4;5],1)==0);

ngbfaces = obtain_neighbor_faces(fid,tris,sibhes_struct,true);
passed=size(ngbfaces,1)==4;
passed=passed&&(sum(sort(ngbfaces,1)-[1;3;4;5],1)==0);


if ~passed; warning('MATLAB:test','test 2 failed'); end;

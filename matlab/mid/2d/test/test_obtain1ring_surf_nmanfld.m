function passed=test_obtain1ring_surf_nmanfld()
%% Test function obtain_1ring_surf on different non-manifold meshes

%% two "disks" intersecting in the middle. Each disk consist of 8 faces. Edges [8,9] and [4,9] are shared between disks.
test_mesh=int32([1,2,9;
           2,3,9;
           3,4,9;
           4,5,9;
           5,6,9;
           6,7,9;
           7,8,9;
           8,1,9;
           
           9,8,10;
           9,10,11;
           9,11,12;
           9,12,4;
           9,4,13;
           9,13,14;
           9,14,15;
           9,15,8]);
       
ftags=false(size(test_mesh,1),1);
vtags=false(15,1);

[sibhes,v2he] = construct_halfedges( 15, test_mesh);

% 
% for i = 1 : size(v2hv,1)
%    passed=passed && (hvid2eid(v2hv(i))==v2hv_struct.eid(i)) && (hvid2lvid(v2hv(i))==v2hv_struct.lvid(i));
% end
% 
% for i = 1 : size(sibhvs,1)
%    for j = 1 :  size(sibhvs,2)
%        
%     passed=passed && (hvid2eid(sibhvs(i,j))==sibhvs_struct.eid(i,j)) && (hvid2eid(sibhvs(i,j))==0 || (hvid2lvid(sibhvs(i,j))==sibhvs_struct.lvid(i,j)));
%    end
% end




%% Test 1, border vertex.
%  manifold boundary vertex 1. 
%  Incident vertices are [2,8,9]
%  Incident faces are [1,8]
vid=int32(1);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==3;
passed=passed&&(nfaces==2);

ngbvs_should_be=int32([2;8;9]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32([1;8]);
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 1 failed'); end;

%% Test 2
%  non-manifold boundary vertex 4. 
vid=int32(4);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==5;
passed=passed&&(nfaces==4);

ngbvs_should_be=int32([3;5;9;12;13]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32([3;4;12;13]);
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 1 failed'); end;

%% Test 3
%  non-manifold interior vertex 9. 
vid=int32(9);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==14;
passed=passed&&(nfaces==16);

ngbvs_should_be=int32([1;2;3;4;5;6;7;8;10;11;12;13;14;15]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32(1:16)';
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 3: non-manifold interior vertex 9 failed'); end;

%% One of the disks misses a face along intersection. 
test_mesh=int32([1,2,9;
           2,3,9;
           3,4,9;
           4,5,9;
           5,6,9;
           6,7,9;
           7,8,9;
           8,1,9;
           
           9,8,10;
           9,10,11;
           9,11,12;
           9,12,4;
           9,4,13;
           9,13,14;
           9,14,15;
           %9,15,8
           ]);
       
ftags=false(size(test_mesh,1),1);
vtags=false(15,1);

[sibhes,v2he] = construct_halfedges( 15, test_mesh);


%% Test 4
%  non-manifold boundary vertex 9
vid=int32(9);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==14;
passed=passed&&(nfaces==15);

ngbvs_should_be=int32([1;2;3;4;5;6;7;8;10;11;12;13;14;15]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32(1:15)';
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 4:non-manifold boundary vertex 9 failed'); end;

%% Test 5
%  non-manifold corner vertex 8 
vid=int32(8);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==4;
passed=passed&&(nfaces==3);

ngbvs_should_be=int32([1;7;9;10]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32([7;8;9]);
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 5:non-manifold corner vertex failed'); end;

%% Test 6
%  one-element mesh
test_mesh=int32([1,2,9]);
       
ftags=false(size(test_mesh,1),1);
vtags=false(9,1);

[sibhes,v2he] = construct_halfedges( 9, test_mesh);

vid=int32(1);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==2;
passed=passed&&(nfaces==1);

ngbvs_should_be=int32([2;9]);
passed=passed&&(sum(ngbvs_should_be-sort(ngbvs(1:nverts,1),1))==0);

ngbfs_should_be=int32([1]);
passed=passed&&(sum(ngbfs_should_be-sort(ngbfs(1:nfaces,1),1))==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 6:one element mesh failed'); end;

%% Test 7
%  one-element mesh, vertex does not belong to any element
vid=int32(4);
[ngbvs, nverts, vtags, ftags, ngbfs, nfaces] = obtain_1ring_surf_nmanfld(vid, test_mesh, sibhes, v2he, vtags, ftags);
passed=nverts==0;
passed=passed&&(nfaces==0);

passed=passed&&(sum(ngbvs,1)==0);

passed=passed&&(sum(ngbfs,1)==0);

passed=passed&&(~any(vtags));
passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 7:one-element mesh, vertex does not belong to any element failed'); end;

%%TODO: one of the disks misses two connected faces, one on each side of
%%intersecion
%%  both disks miss two connected faces, one on each side of
%%intersecion

function passed = test_eid2adj_faces

%% Test function eid2adj_faces on different non-manifold meshes

%% two "disks" intersecting in the middle. Each disk consist of 8 faces. Edges [8,9] and [4,9] are shared between disks.
tris =    [1,2,9;   % 1
           2,3,9;   % 2
           3,4,9;   % 3
           4,5,9;   % 4
           5,6,9;   % 5
           6,7,9;   % 6
           7,8,9;   % 7
           8,1,9;   % 8
           
           9,8,10;  % 9
           9,10,11; % 10
           9,11,12; % 11
           9,12,4;  % 12
           9,4,13;  % 13
           9,13,14; % 14
           9,14,15; % 15
           9,15,8]; % 16
       
edges = [ 8,9;
          4,9;
          2,3;
          1,9;
        ];
       
ftags=false(size(tris,1),1);
vtags=false(15,1);

[sibhes,v2he] = construct_halfedges( 15, tris);


%% Test 1, interior manifold edge
%  Interior manifold edge [1,8] eid=4. 
%  Adjacent faces are [1,8]

eid=4;
[flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags);

passed=nfaces==2;

ngbfs_should_be=int32([1;8]);
passed=passed&&(sum(ngbfs_should_be-sort(flist(1:nfaces,1),1))==0);

passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 1 failed'); end;

%% Test 2
%  non-manifold interior edge [8,9] eid=1. 
eid=1;
[flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags);

passed=passed&&(nfaces==4);

ngbfs_should_be=int32([7;8;9;16]);
passed=passed&&(sum(ngbfs_should_be-sort(flist(1:nfaces,1),1))==0);

passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 1 failed'); end;

%% Test 3
%  manifold boundary edge [2,3] eid=3. 
eid=3;
[flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags);
passed=passed&&(nfaces==1);

ngbfs_should_be=int32(2)';
passed=passed&&(sum(ngbfs_should_be-sort(flist(1:nfaces,1),1))==0);

passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 3: non-manifold interior vertex 9 failed'); end;

%% One of the disks misses a face along intersection. 
test_mesh=[1,2,9;
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
           ];
       
ftags=false(size(test_mesh,1),1);
[sibhes,v2he] = construct_halfedges( 15, test_mesh);


%% Test 4
%  non-manifold boundary edge [8,9] eid=1
eid=1;
[flist, nfaces, ftags]=eid2adj_faces(eid,edges,tris,v2he,sibhes,ftags);

passed=passed&&(nfaces==3);

ngbfs_should_be=int32([7;8;9]);
passed=passed&&(sum(ngbfs_should_be-sort(flist(1:nfaces,1),1))==0);

passed=passed&&(~any(ftags));

if ~passed; warning('MATLAB:test','test 1 failed'); end;
function passed = test_f2hf

faces=int32([1,2,3;  % boundary face
       2,3,4;  % interior face
       5,1,4;  % face not embedded into the volume mesh
       6,3,11; % vertices not in the volume mesh
       ]);

% tetrahedral contains one interior face
tets = int32([1,2,3,4;
        2,3,4,5;
       ]);
   
[sibhfs,v2hf] = construct_halffaces( 11, tets);

sibhfs_struct = determine_sibling_halffaces_tet( 11, tets, true);



etags=false(size(tets,1),1);
% order of vertices in tetrahedra
% [1 3 2; 1 2 4; 2 3 4; 3 1 4]    

%% Test 1: boundary face
fid=int32(1);
[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=(cid==1) && (lfid==1);
passed = passed && ~any(etags);


[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs_struct, v2hf_struct, etags, true);
passed=passed && (cid==1) && (lfid==1);
passed = passed && ~any(etags);


%% Test 2: interior face
fid=int32(2);
[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && ((cid==2 && lfid==1) || (cid==1 && lfid==3));
passed = passed && ~any(etags);


[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs_struct, v2hf_struct, etags, true);
passed=passed && ((cid==2 && lfid==1) || (cid==1 && lfid==3));
passed = passed && ~any(etags);


%% Test 3: face not embedded into the volume mesh
fid=int32(3);
[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && cid==0;
passed = passed && ~any(etags);


[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs_struct, v2hf_struct, etags, true);
passed=passed && cid==0;
passed = passed && ~any(etags);

%% Test 4: vertices not in the volume mesh
fid=int32(4);
[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && cid==0;
passed = passed && ~any(etags);


[cid, lfid, etags] = f2hf(fid,faces,tets,sibhfs_struct, v2hf_struct, etags, true);
passed=passed && cid==0;
passed = passed && ~any(etags);



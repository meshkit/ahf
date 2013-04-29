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


etags=false(size(tets,1),1);
% order of vertices in tetrahedra
% [1 3 2; 1 2 4; 2 3 4; 3 1 4]    

%% Test 1: boundary face
fid=int32(1);
[hf, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=(hfid2cid(hf)==1) && (hfid2lfid(hf)==1);
passed = passed && ~any(etags);

%% Test 2: interior face
fid=int32(2);
[hf, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && ((hfid2cid(hf)==2 && hfid2lfid(hf)==1) || (hfid2cid(hf)==1 && hfid2lfid(hf)==3));
passed = passed && ~any(etags);

%% Test 3: face not embedded into the volume mesh
fid=int32(3);
[hf, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && hf==0;
passed = passed && ~any(etags);

%% Test 4: vertices not in the volume mesh
fid=int32(4);
[hf, etags] = f2hf(fid,faces,tets,sibhfs, v2hf, etags);
passed=passed && hf==0;
passed = passed && ~any(etags);





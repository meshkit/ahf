function passed=test_obtain1ring_curv_NM()


%% Expected argument types
%assert( isa(vid, 'int32') && isa( edges, 'int32') && ...
%    isa( sibhvs, 'int32') && isa( v2hv,'int32'));

%% test0case of non-manifold mesh
test_case=int32([ 2,1;
                3,4;
                2,3;
                2,5;
                2,6;
                5,6]);
[sibhvs,v2hv] = construct_halfverts( 6, test_case);

sibhvs_struct = determine_sibling_halfverts( 6, test_case, true);
v2hv_struct = determine_incident_halfverts( 6, test_case, true);

passed=true;

for i = 1 : size(v2hv,1)
   passed=passed && (hvid2eid(v2hv(i))==v2hv_struct.eid(i)) && (hvid2lvid(v2hv(i))==v2hv_struct.lvid(i));
end

for i = 1 : size(sibhvs,1)
   for j = 1 :  size(sibhvs,2)
       
    passed=passed && (hvid2eid(sibhvs(i,j))==sibhvs_struct.eid(i,j)) && (hvid2eid(sibhvs(i,j))==0 || (hvid2lvid(sibhvs(i,j))==sibhvs_struct.lvid(i,j)));
%     if ~passed
%         stop
%     end
   end
end


%% Run tests and check correctedness of results

%% test 1, non-manifold neighborhod
%  vertex 2 is connected to vertices 1,3,5,6
vid=int32(2);
compare_to=int32([1;3;5;6]);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs, v2hv);
passed = passed && (nverts==4) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs_struct, v2hv_struct, true);
passed = passed && (nverts==4) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);



%% test 2, manifold neighborhood
%  vertex 6 is connected to vertices 2,5 
vid=int32(6);
compare_to=int32([2;5]);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs, v2hv);
passed=passed && (nverts==2) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs_struct, v2hv_struct,true);
passed=passed && (nverts==2) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);

%% test 3, boundary vertex
%  vertex 1 is connected to vertex 2
vid=int32(1);
compare_to=int32(2);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs, v2hv);
passed=passed && (nverts==1) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);

[ngbvs, nverts] = obtain_1ring_curv_NM( vid, test_case, sibhvs_struct, v2hv_struct,true);
passed=passed && (nverts==1) && (sum(compare_to-sort(ngbvs(1:nverts,1),1))==0);
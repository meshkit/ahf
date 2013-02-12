
/*********Compilation steps************/

$ gcc -c util_functions.c basic_emxArray_fncs.c obtain_1ring_vol.c obtain_nring_quad.c determine_opposite_halfedge.c determine_border_vertices_surf.c call_all_functions.c determine_border_vertices_vol.c determine_incident_halfedges.c determine_incident_halffaces.c extract_border_surf_tet.c determine_opposite_halfedge_quad.c determine_opposite_halfface_tet.c obtain_nring_tri.c     

$ ar rc stuff.a util_functions.o basic_emxArray_fncs.o obtain_1ring_vol.o obtain_nring_quad.o determine_opposite_halfedge.o determine_border_vertices_surf.o call_all_functions.o determine_border_vertices_vol.o determine_incident_halfedges.o determine_incident_halffaces.o extract_border_surf_tet.o determine_opposite_halfedge_quad.o determine_opposite_halfface_tet.o obtain_nring_tri.o 

$ gcc -lm main.c stuff.a

/**************************************/

Files:

"all_headers.h" : Lists the main Matlab functions that are callable from the C code

"all_types.h" : Specifies the basic emxArray data structures (emxArray_in32_T ..... etc)

"basic_emxArray_fncs.c" : Specifies the Matlab-provided functions that can create and destroy emxArrays, wrappers, etc... 

"call_all_functions.c" : Specifies very basic interface functions that pass through data to the Matlab-generated C-source code functions ....
(I still have not implemented variable length argument lists and other features)

"rtwtypes.h" : Specifices the Matlab-defined element types in C such as int32_T, boolean_T ... etc

"util_functions.c" : Details some very simple utility functions to do things like populate emxArrays from data files, write out data to output files, count the number of rows in a file.... etc

[Finally, all the Matlab C-generated source code files for each Matlab function are also included except that the Matlab utility functions that create emxArrays. etc. has been moved to "basic_emxArray_fncs.c"]

"main.c" : The main function provides a simple test-case that starts with a quad mesh and then constructs the opposite_halfedges, incident_half_edges and then the n_rings with n = 2.5 for vertex id = 10. The output for each computation was compared with the Matlab output and they were the same.

/**************************************/

So far, the following functions are now supported:

/**************************************/

obtain_nring_tri
obtain_nring_quad
obtain_1ring_vol
determine_opposite_halfedge
determine_opposite_halfedge_quad
determine_opposite_halfedge_tri
determine_opposite_halfface_tet
determine_border_vertices_surf
determine_border_vertices_vol
determine_incident_halfedges
determine_incident_halffaces
extract_border_surf_tet




  
# This is my README
# This is my README

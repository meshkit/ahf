#include <stdio.h>
#include <stdlib.h>

#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

#include "util_functions.c"

#include "call_all_functions.c"
#include "obtain_nring_quad.c"
#include "obtain_1ring_vol.c"
#include "determine_opposite_halfedge.c"
#include "determine_border_vertices_surf.c"
#include "determine_border_vertices_vol.c"
#include "determine_incident_halfedges.c"
#include "determine_incident_halffaces.c"
#include "extract_border_surf_tet.c"
#include "determine_opposite_halfedge_quad.c"
#include "determine_opposite_halfface_tet.c"
#include "obtain_nring_tri.c"

int main()
{
	int i;

    char *ps_file = "ps.csv";
	char *elem_file = "quad.csv";
    char *out_opphes_file = "opphes.csv";
	char *out_v2hefile = "v2he.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;
	
	// Compute opposite halfedges

    emxArray_int32_T *elems;
    emxArray_int32_T *opphes;

    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphes = emxCreate_int32_T(elemrows, elemcols);

    opphes = call_determine_opposite_halfedge_quad(n, elems, opphes);
     
   // file_print_emxArry(opphes, out_opphes_file);

	// Compute incident halfedges

    emxArray_int32_T *v2he;
	v2he = emxCreate_int32_T(n, 1);

    v2he = call_determine_incident_halfedges(elems, opphes, v2he);

    file_print_emxArry(v2he, out_v2hefile);

	char *out_ngbfsfile = "ngbfs.csv";
    char *out_ngbvsfile = "ngbvs.csv";

    int vid = 10;
	double ring = 2.5;
	int minpnts = 5;

	// Compute n-ring-quad

	// Create ftags, vtags, vectors initialized to false

	emxArray_boolean_T *vtags;
	emxArray_boolean_T *ftags;

	vtags = emxCreate_boolean_T(n,1);
	ftags = emxCreate_boolean_T(elemrows,1);

       for (i=0; i<elemrows; i++)
   		{
			ftags->data[i] = (boolean_T) 0;

		}

       for (i=0; i<n; i++)
       {
		vtags->data[i] = (boolean_T) 0;

		}

	    emxArray_int32_T *ngbfs;
		emxArray_int32_T *ngbvs;

		ngbfs = emxCreate_int32_T(elemrows, 1);
		ngbvs = emxCreate_int32_T(n, 1);

		int32_T nverts = 0;
		int32_T nfaces = 0;

        call_obtain_nring_quad(vid, ring, minpnts, elems, opphes, v2he, vtags, ftags,  ngbfs, ngbvs, nverts, nfaces);

		
		file_print_emxArry(ngbfs, out_ngbfsfile);
		file_print_emxArry(ngbvs, out_ngbvsfile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphes);
        emxDestroyArray_int32_T(v2he);

		emxDestroyArray_boolean_T(vtags);
        emxDestroyArray_boolean_T(ftags);

        emxDestroyArray_int32_T(ngbfs);
        emxDestroyArray_int32_T(ngbvs);

    return 0;





	/*
	int i;

    char *ps_file = "ps.csv";
    char *elem_file = "tets.csv";
    char *opphfs_file = "opphfs.csv";
    char *v2hf_file = "v2hf.csv";

    char *out_ngbesfile = "ngbes.csv";
    char *out_ngbvsfile = "ngbvs.csv";

    int n = get_nrows(ps_file);

    int vid = 10;

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

    int maxngb = 1024;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphfs;
     emxArray_int32_T *v2hf;
    
        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphfs = read_emxArray(opphfs, elemrows, elemcols, opphfs_file);
        v2hf = read_emxArray(v2hf, n, 1, v2hf_file);

	emxArray_boolean_T *vtags = emxCreate_boolean_T(n,1);
        emxArray_boolean_T *etags = emxCreate_boolean_T(elemrows,1);

       for (i=0; i<elemrows; i++)
   		{
			etags->data[i] = (boolean_T) 0;

		}

       for (i=0; i<n; i++)
       {
		vtags->data[i] = (boolean_T) 0;

		}

	    emxArray_int32_T *ngbes = emxCreate_int32_T(maxngb, 1);
		emxArray_int32_T *ngbvs = emxCreate_int32_T(maxngb, 1);

		int32_T nverts = 0;
		int32_T nelems = 0;

        call_obtain_1ring_vol(vid, maxngb, elems, opphfs, v2hf, vtags, etags,  ngbes, ngbvs, nverts, nelems);
		
		file_print_emxArry(ngbes, out_ngbesfile);
		file_print_emxArry(ngbvs, out_ngbvsfile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphfs);
        emxDestroyArray_int32_T(v2hf);

		emxDestroyArray_boolean_T(vtags);
        emxDestroyArray_boolean_T(etags);

        emxDestroyArray_int32_T(ngbes);
        emxDestroyArray_int32_T(ngbvs);
return 0;
}

*/

	/*
	
	int i, j;

    char *ps_file = "ps.csv";
    char *elem_file = "quads.csv";
    char *opphes_file = "opphes.csv";
    char *v2he_file = "v2he.csv";

    char *out_ngbfsfile = "ngbfs.csv";
    char *out_ngbvsfile = "ngbvs.csv";

    int n = get_nrows(ps_file);

    int vid = 10;
	double ring = 2.5;
	int minpnts = 5;

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphes;
     emxArray_int32_T *v2he;
    
        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphes = read_emxArray(opphes, elemrows, elemcols, opphes_file);
        v2he = read_emxArray(v2he, n, 1, v2he_file);

		emxArray_boolean_T *vtags;
		emxArray_boolean_T *ftags;

		vtags = emxCreate_boolean_T(n,1);
		ftags = emxCreate_boolean_T(elemrows,1);

       for (i=0; i<elemrows; i++)
   		{
			ftags->data[i] = (boolean_T) 0;

		}

       for (i=0; i<n; i++)
       {
		vtags->data[i] = (boolean_T) 0;

		}

	    emxArray_int32_T *ngbfs;
		emxArray_int32_T *ngbvs;

		ngbfs = emxCreate_int32_T(elemrows, 1);
		ngbvs = emxCreate_int32_T(n, 1);

		int32_T nverts = 0;
		int32_T nfaces = 0;

		for (i=0; i<elemrows; i++)
		{
		for (j=0; j<1; j++)
		{
			printf("%d ", v2he->data[i + v2he->size[0] *j]);
		}

        printf("\n");
		}

        call_obtain_nring_quad(vid, ring, minpnts, elems, opphes, v2he, vtags, ftags,  ngbfs, ngbvs, nverts, nfaces);

		
		file_print_emxArry(ngbfs, out_ngbfsfile);
		file_print_emxArry(ngbvs, out_ngbvsfile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphes);
        emxDestroyArray_int32_T(v2he);

		emxDestroyArray_boolean_T(vtags);
        emxDestroyArray_boolean_T(ftags);

        emxDestroyArray_int32_T(ngbfs);
        emxDestroyArray_int32_T(ngbvs);

    return 0;

	*/

 /*
	 char *elem_file = "tris.csv";
    char *ps_file = "ps3.csv";
    char *out_opphes_file = "opphes.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 3;

    emxArray_int32_T *elems;
    emxArray_int32_T *opphes;

    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphes = emxCreate_int32_T(elemrows, elemcols);

    opphes = call_determine_opposite_halfedge(n, elems, opphes);
     
    file_print_emxArry(opphes, out_opphes_file);

    emxDestroyArray_int32_T(elems);
    emxDestroyArray_int32_T(opphes);

    return 0;
	*/

/*

	 char *ps_file = "ps.csv";	
    char *elem_file = "elems.csv";
    char *opphes_file = "opphes.csv";

    char *isborder_out = "isborder.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 3;

    emxArray_int32_T *elems;
    emxArray_int32_T *opphes;
    emxArray_boolean_T *isborder;
    
    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphes = read_emxArray(opphes, elemrows, elemcols, opphes_file);
    isborder = emxCreate_boolean_T(n, 1);

    isborder = call_determine_border_vertices_surf(n, elems, opphes, isborder);

    file_print_emxArry_bool(isborder, isborder_out);

    emxDestroyArray_int32_T(elems);
    emxDestroyArray_int32_T(opphes);
    emxDestroyArray_boolean_T(isborder);
   
    return 0;

	*/
/*

	 char *ps_file = "ps.csv";	
    char *elem_file = "tets.csv";
    char *opphfs_file = "opphfs.csv";

    char *isborder_out = "isborder.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;
    
    emxArray_int32_T *elems;
    emxArray_int32_T *opphfs;
    emxArray_boolean_T *isborder;

    boolean_T quadratic = false;

    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphfs = read_emxArray(opphfs, elemrows, elemcols, opphfs_file);
    isborder = emxCreate_boolean_T(n, 1);

    isborder = call_determine_border_vertices_vol(n, elems, opphfs, isborder, quadratic);

    file_print_emxArry_bool(isborder, isborder_out);

    emxDestroyArray_int32_T(elems);
    emxDestroyArray_int32_T(opphfs);
    emxDestroyArray_boolean_T(isborder);
   
    return 0;

	*/

/*
	char *ps_file = "ps3.csv";
    	char *elem_file = "tris.csv";
    	char *opphes_file = "opphes.csv";

	char *out_v2hefile = "v2he.csv";

	int n = get_nrows(ps_file);

	int elemrows = get_nrows(elem_file);
	int elemcols = 3;

        emxArray_int32_T *elems;
        emxArray_int32_T *opphes;
	emxArray_int32_T *v2he;

        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphes = read_emxArray(opphes, elemrows, elemcols, opphes_file);
	v2he = emxCreate_int32_T(n, 1);

        v2he = call_determine_incident_halfedges(elems, opphes, v2he);

        file_print_emxArry(v2he, out_v2hefile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphes);
        emxDestroyArray_int32_T(v2he);

		return 0;
		*/

/*

		char *ps_file = "ps.csv";
    char *elem_file = "tris.csv";
    char *opphfs_file = "opphfs.csv";

    char *out_v2hffile = "v2hf.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphfs;
     emxArray_int32_T *v2hf;

        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphfs = read_emxArray(opphfs, elemrows, elemcols, opphfs_file);
	v2hf = emxCreate_int32_T(n, 1);

        v2hf = call_determine_incident_halffaces(elems, opphfs, v2hf);

        file_print_emxArry(v2hf, out_v2hffile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphfs);
        emxDestroyArray_int32_T(v2hf);
   
    return 0;

	*/

/*
	int i;

    char *ps_file = "ps.csv";
    char *elem_file = "tets.csv";
    char *opphfs_file = "opphfs.csv";

    char *b2v_out = "b2v.csv";
    char *bdtets_out = "bdtets.csv";
    char *facmap_out = "facmap.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphfs;
    
        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphfs = read_emxArray(opphfs, elemrows, elemcols, opphfs_file);

		emxArray_int32_T *labels = emxCreate_int32_T(elemrows,1);

		boolean_T inwards = false;

		int n_output = estimate_num_neighbor_tets(elems, opphfs, labels);

	    emxArray_int32_T *b2v = emxCreate_int32_T(n_output,1);
		emxArray_int32_T *bdtets = emxCreate_int32_T(n_output,elemcols - 1);
		emxArray_int32_T *facmap = emxCreate_int32_T(n_output,1);
		
        call_extract_border_surf_tet(n, elems, labels, opphfs, inwards, b2v, bdtets, facmap);
		
		file_print_emxArry(b2v, b2v_out);
		file_print_emxArry(bdtets, bdtets_out);
		file_print_emxArry(facmap, facmap_out);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphfs);
		emxDestroyArray_int32_T(labels);
		emxDestroyArray_int32_T(b2v);
		emxDestroyArray_int32_T(bdtets);
		emxDestroyArray_int32_T(facmap);

    return 0;
	*/
	
/*
    char *elem_file = "quad.csv";
    char *ps_file = "ps.csv";
    char *out_opphes_file = "opphes.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

    emxArray_int32_T *elems;
    emxArray_int32_T *opphes;

    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphes = emxCreate_int32_T(elemrows, elemcols);

    opphes = call_determine_opposite_halfedge_quad(n, elems, opphes);
     
    file_print_emxArry(opphes, out_opphes_file);

    emxDestroyArray_int32_T(elems);
    emxDestroyArray_int32_T(opphes);

    return 0;
	
	*/

/*
	 char *elem_file = "tris.csv";
    char *ps_file = "ps.csv";
    char *out_opphes_file = "opphes.csv";

    int n = get_nrows(ps_file);
    
    int elemrows = get_nrows(elem_file);
    int elemcols = 3;

    emxArray_int32_T *elems;
    emxArray_int32_T *opphes;

    elems = read_emxArray(elems, elemrows, elemcols, elem_file);
    opphes = emxCreate_int32_T(elemrows, elemcols);

    opphes = call_determine_opposite_halfedge_tri(n, elems, opphes);
     
    file_print_emxArry(opphes, out_opphes_file);

    emxDestroyArray_int32_T(elems);
    emxDestroyArray_int32_T(opphes);

    return 0;
	*/

/*
	  char *ps_file = "ps.csv";
    char *elem_file = "tris.csv";

    char *out_opphfsfile = "opphfs.csv";

    int n = get_nrows(ps_file);

    int elemrows = get_nrows(elem_file);
    int elemcols = 4;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphfs;

      elems = read_emxArray(elems, elemrows, elemcols, elem_file);
	opphfs = emxCreate_int32_T(elemrows, elemcols);

        opphfs = call_determine_opposite_halfface_tet(n, elems, opphfs);

        file_print_emxArry(opphfs, out_opphfsfile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphfs);;

   
    return 0;
	*/

/*
		int i;

    char *ps_file = "ps.csv";
    char *elem_file = "tris.csv";
    char *opphes_file = "opphes.csv";
    char *v2he_file = "v2he.csv";

    char *out_ngbfsfile = "ngbfs.csv";
    char *out_ngbvsfile = "ngbvs.csv";

    int n = get_nrows(ps_file);

    int vid = 10;
	double ring = 2.5;
	int minpnts = 5;

    int elemrows = get_nrows(elem_file);
    int elemcols = 3;

     emxArray_int32_T *elems;
     emxArray_int32_T *opphes;
     emxArray_int32_T *v2he;
    
        elems = read_emxArray(elems, elemrows, elemcols, elem_file);
        opphes = read_emxArray(opphes, elemrows, elemcols, opphes_file);
        v2he = read_emxArray(v2he, n, 1, v2he_file);

		emxArray_boolean_T *vtags;
		emxArray_boolean_T *ftags;

		vtags = emxCreate_boolean_T(n,1);
		ftags = emxCreate_boolean_T(elemrows,1);

       for (i=0; i<elemrows; i++)
   		{
			ftags->data[i] = (boolean_T) 0;

		}

       for (i=0; i<n; i++)
       {
		vtags->data[i] = (boolean_T) 0;

		}

	    emxArray_int32_T *ngbfs;
		emxArray_int32_T *ngbvs;

		ngbfs = emxCreate_int32_T(elemrows, 1);
		ngbvs = emxCreate_int32_T(n, 1);

		int32_T nverts = 0;
		int32_T nfaces = 0;

        call_obtain_nring_tri(vid, ring, minpnts, elems, opphes, v2he, vtags, ftags,  ngbfs, ngbvs, nverts, nfaces);
		
		file_print_emxArry(ngbfs, out_ngbfsfile);
		file_print_emxArry(ngbvs, out_ngbvsfile);

        emxDestroyArray_int32_T(elems);
        emxDestroyArray_int32_T(opphes);
        emxDestroyArray_int32_T(v2he);

		emxDestroyArray_boolean_T(vtags);
        emxDestroyArray_boolean_T(ftags);

        emxDestroyArray_int32_T(ngbfs);
        emxDestroyArray_int32_T(ngbvs);

    return 0;
	*/
}




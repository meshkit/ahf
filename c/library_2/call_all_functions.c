#include <stdio.h>
#include <stdlib.h>

#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif


void call_obtain_1ring_vol(int vid, int maxngb, emxArray_int32_T *elems, emxArray_int32_T *opphfs, emxArray_int32_T *v2hf, emxArray_boolean_T *vtags, emxArray_boolean_T *etags, emxArray_int32_T *ngbes, emxArray_int32_T *ngbvs, int32_T nverts, int32_T nelems)
{

       obtain_1ring_vol(vid, elems, opphfs, v2hf, ngbvs, vtags, etags, ngbes, &nverts, &nelems);
}

void call_obtain_nring_quad(int vid, double ring, int minpnts, emxArray_int32_T *elems, emxArray_int32_T *opphes, emxArray_int32_T *v2he, emxArray_boolean_T *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbfs, emxArray_int32_T *ngbvs, int32_T nverts, int32_T nfaces)
{

       obtain_nring_quad(vid, ring, minpnts, elems, opphes, v2he, ngbvs, vtags, ftags, ngbfs, &nverts, &nfaces);
}

emxArray_int32_T* call_determine_opposite_halfedge(int n, emxArray_int32_T *elems, emxArray_int32_T *opphes)
{

       int nv = n;

       determine_opposite_halfedge(nv, elems, opphes);

       return opphes;

}

emxArray_boolean_T* call_determine_border_vertices_surf(int n, emxArray_int32_T *elems, emxArray_int32_T *opphes, emxArray_boolean_T *isborder)
{

       int nv = n;

       determine_border_vertices_surf(nv, elems, opphes, isborder);

       return isborder;

}

emxArray_boolean_T* call_determine_border_vertices_vol(int n, emxArray_int32_T *elems, emxArray_int32_T *opphfs, emxArray_boolean_T *isborder, boolean_T quadratic)
{

       int nv = n;

       determine_border_vertices_vol(nv, elems, opphfs, isborder, quadratic);

       return isborder;

}

emxArray_int32_T* call_determine_incident_halfedges(emxArray_int32_T *elems, emxArray_int32_T *opphes, emxArray_int32_T *v2he)
{

       determine_incident_halfedges(elems, opphes, v2he);

       return v2he;

}

emxArray_int32_T* call_determine_incident_halffaces(emxArray_int32_T *elems, emxArray_int32_T *opphfs, emxArray_int32_T *v2hf)
{

       determine_incident_halffaces(elems, opphfs, v2hf);

       return v2hf;

}

void call_extract_border_surf_tet(int nv, emxArray_int32_T *elems, emxArray_int32_T *labels,  emxArray_int32_T *opphfs, boolean_T inwards,  emxArray_int32_T *b2v, emxArray_int32_T *bdtets, emxArray_int32_T *facmap)
{

       extract_border_surf_tet(nv, elems, labels, opphfs, inwards, b2v, bdtets, facmap);
}

emxArray_int32_T* call_determine_opposite_halfedge_quad(int n, emxArray_int32_T *elems, emxArray_int32_T *opphes)
{

       int nv = n;

       determine_opposite_halfedge_quad(nv, elems, opphes);

       return opphes;

}

emxArray_int32_T* call_determine_opposite_halfedge_tri(int n, emxArray_int32_T *elems, emxArray_int32_T *opphes)
{

       int nv = n;

       determine_opposite_halfedge(nv, elems, opphes);

       return opphes;

}

emxArray_int32_T* call_determine_opposite_halfface_tet(int nv, emxArray_int32_T *elems, emxArray_int32_T *opphfs)
{

       determine_opposite_halfface_tet(nv, elems, opphfs);

       return opphfs;

}

void call_obtain_nring_tri(int vid, double ring, int minpnts, emxArray_int32_T *elems, emxArray_int32_T *opphes, emxArray_int32_T *v2he, emxArray_boolean_T *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbfs, emxArray_int32_T *ngbvs, int32_T nverts, int32_T nfaces)
{

        obtain_nring_tri(vid, ring, minpnts, elems, opphes, v2he, ngbvs, vtags, ftags, ngbfs, &nverts, &nfaces);
}



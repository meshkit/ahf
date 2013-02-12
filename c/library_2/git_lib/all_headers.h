
#ifndef __ALL_TYPES__
#define __ALL_TYPES__

/* Include files */

#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "all_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern emxArray_boolean_T *emxCreateND_boolean_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapperND_boolean_T(boolean_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapper_boolean_T(boolean_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_boolean_T *emxCreate_boolean_T(int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_boolean_T(emxArray_boolean_T *emxArray);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void obtain_1ring_vol(int32_T vid, const emxArray_int32_T *tets, const emxArray_int32_T *opphfs, const emxArray_int32_T *v2hf, emxArray_int32_T *ngbvs, emxArray_boolean_T *vtags, emxArray_boolean_T *etags, emxArray_int32_T *ngbes, int32_T *nverts, int32_T *nelems);
extern void obtain_1ring_vol_initialize(void);
extern void obtain_1ring_vol_terminate(void);
extern void obtain_nring_quad(int32_T vid, real_T ring, int32_T minpnts, const emxArray_int32_T *elems, const emxArray_int32_T *opphes, const emxArray_int32_T *v2he, emxArray_int32_T *ngbvs, emxArray_boolean_T *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbfs, int32_T *nverts, int32_T *nfaces);
extern void obtain_nring_quad_initialize(void);
extern void obtain_nring_quad_terminate(void);
extern void determine_opposite_halfedge(int32_T nv, const emxArray_int32_T *elems, emxArray_int32_T *opphes);
extern void determine_opposite_halfedge_initialize(void);
extern void determine_opposite_halfedge_terminate(void);
extern void determine_opposite_halfedge_quad(int32_T nv, const emxArray_int32_T *quads, emxArray_int32_T *opphes);
extern void determine_opposite_halfedge_quad_initialize(void);
extern void determine_opposite_halfedge_quad_terminate(void);
extern void determine_border_vertices_surf(int32_T nv, const emxArray_int32_T *elems, const emxArray_int32_T *opphes, emxArray_boolean_T *isborder);
extern void determine_border_vertices_surf_initialize(void);
extern void determine_border_vertices_surf_terminate(void);
extern void determine_border_vertices_vol(int32_T nv, const emxArray_int32_T *elems, const emxArray_int32_T *opphfs, emxArray_boolean_T *isborder, boolean_T quadratic);
extern void determine_border_vertices_vol_initialize(void);
extern void determine_border_vertices_vol_terminate(void);
extern void determine_incident_halfedges(const emxArray_int32_T *elems, const emxArray_int32_T *opphes, emxArray_int32_T *v2he);
extern void determine_incident_halfedges_initialize(void);
extern void determine_incident_halfedges_terminate(void);
extern void determine_incident_halffaces(const emxArray_int32_T *elems, const emxArray_int32_T *opphfs, emxArray_int32_T *v2hf);
extern void determine_incident_halffaces_initialize(void);
extern void determine_incident_halffaces_terminate(void);
extern void extract_border_surf_tet(int32_T nv, const emxArray_int32_T *tets, const emxArray_int32_T *elabel, const emxArray_int32_T *opphfs, boolean_T inwards, emxArray_int32_T *b2v, emxArray_int32_T *bdtris, emxArray_int32_T *facmap);
extern void extract_border_surf_tet_initialize(void);
extern void extract_border_surf_tet_terminate(void);
extern void determine_opposite_halfface_tet(int32_T nv, const emxArray_int32_T *elems, emxArray_int32_T *opphfs);
extern void determine_opposite_halfface_tet_initialize(void);
extern void determine_opposite_halfface_tet_terminate(void);
extern void obtain_nring_tri(int32_T vid, real_T ring, int32_T minpnts, const emxArray_int32_T *tris, const emxArray_int32_T *opphes, const emxArray_int32_T *v2he, emxArray_int32_T *ngbvs, emxArray_boolean_T *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbfs, int32_T *nverts, int32_T *nfaces);
extern void obtain_nring_tri_initialize(void);
extern void obtain_nring_tri_terminate(void);

#endif



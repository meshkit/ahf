#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_INCIDENT_HALFEDGES Determine an incident halfedges.
 *  DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE) Determines incident
 *  halfedges of each vertex for a triangular, quadrilateral, or mixed mesh.
 *  It gives higher priorities to border edges. The following explains inputs
 *  and outputs.
 *
 *  V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES)
 *  V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE)
 *  V2HE = DETERMINE_INCIDENT_HALFEDGES(ELEMS,OPPHES,V2HE)
 *      ELEMS is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
 *      OPPHES is mx3 (for triangle mesh) or mx4 (for quadrilateral mesh).
 *      V2HE is an array of size equal to number of vertices.
 *           It is passed by reference.
 *
 *  See also DETERMINE_INCIDENT_HALFFACES, DETERMINE_INCIDENT_HALFVERTS
 */
void determine_incident_halfedges(const emxArray_int32_T *elems, const
  emxArray_int32_T *opphes, emxArray_int32_T *v2he)
{
  emxArray_int32_T *b_v2he;
  int32_T kk;
  int32_T loop_ub;
  boolean_T guard1 = FALSE;
  uint32_T a;
  emxInit_int32_T(&b_v2he, 1);
  kk = v2he->size[0];
  v2he->size[0] = v2he->size[0];
  emxEnsureCapacity((emxArray__common *)v2he, kk, (int32_T)sizeof(int32_T));
  loop_ub = v2he->size[0] - 1;
  for (kk = 0; kk <= loop_ub; kk++) {
    v2he->data[kk] = 0;
  }

  kk = 0;
  while ((kk + 1 <= elems->size[0]) && (!(elems->data[kk] == 0))) {
    for (loop_ub = 0; loop_ub + 1 <= elems->size[1]; loop_ub++) {
      if (elems->data[kk + elems->size[0] * loop_ub] > 0) {
        guard1 = FALSE;
        if ((v2he->data[elems->data[kk + elems->size[0] * loop_ub] - 1] == 0) ||
            (opphes->data[kk + opphes->size[0] * loop_ub] == 0)) {
          guard1 = TRUE;
        } else {
          a = (uint32_T)v2he->data[elems->data[kk + elems->size[0] * loop_ub] -
            1];
          if ((opphes->data[((int32_T)(a >> 2U) + opphes->size[0] * (v2he->
                 data[elems->data[kk + elems->size[0] * loop_ub] - 1] -
                 ((v2he->data[elems->data[kk + elems->size[0] * loop_ub] - 1] >>
                   2) << 2))) - 1] != 0) && (opphes->data[kk + opphes->size[0] *
               loop_ub] < 0)) {
            guard1 = TRUE;
          }
        }

        if (guard1 == TRUE) {
          v2he->data[elems->data[kk + elems->size[0] * loop_ub] - 1] = ((kk + 1)
            << 2) + loop_ub;
        }
      }
    }

    kk++;
  }

  emxFree_int32_T(&b_v2he);
}

void determine_incident_halfedges_initialize(void)
{
}

void determine_incident_halfedges_terminate(void)
{
  /* (no terminate code required) */
}

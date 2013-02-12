
#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_INCIDENT_HALFFACES Determine an incident half-faces.
 *  DETERMINE_INCIDENT_HALFFACES(ELEMS,OPPHFS,V2HF) Determines an
 *  incident half-faces of each vertex. Give higher priorities to border
 *  faces. The following explains the inputs and outputs.
 *
 *  Input:  ELEMS:  matrix of size mx4 storing element connectivity
 *          OPPHFS: matrix of size mx4 storing opposite half-faces
 *
 *  Output: V2HF:   array of size equal to number of vertices.
 *
 *  See also DETERMINE_INCIDENT_HALFEDGES, DETERMINE_INCIDENT_HALFVERTS
 */
void determine_incident_halffaces(const emxArray_int32_T *elems, const
  emxArray_int32_T *opphfs, emxArray_int32_T *v2hf)
{
  emxArray_int32_T *b_v2hf;
  int32_T nv;
  int32_T jj;
  int32_T loop_ub;
  emxArray_boolean_T *isborder;
  static const int8_T hf[24] = { 1, 1, 2, 3, 3, 2, 3, 1, 2, 4, 4, 4, 7, 5, 6, 7,
    5, 9, 10, 8, 6, 8, 9, 10 };

  static const int8_T v2f[12] = { 2, 1, 3, 4, 4, 3, 1, 2, 1, 2, 4, 3 };

  emxInit_int32_T(&b_v2hf, 1);

  /*  Table for local IDs of incident faces of each vertex. */
  /*  We use three bits for local-face ID. */
  /*  Construct a vertex to halfedge mapping. */
  nv = v2hf->size[0];
  jj = v2hf->size[0];
  v2hf->size[0] = v2hf->size[0];
  emxEnsureCapacity((emxArray__common *)v2hf, jj, (int32_T)sizeof(int32_T));
  loop_ub = v2hf->size[0] - 1;
  for (jj = 0; jj <= loop_ub; jj++) {
    v2hf->data[jj] = 0;
  }

  emxInit_boolean_T(&isborder, 1);

  /*  Table for local IDs of incident faces of each vertex. */
  /*  DETERMINE_BORDER_VERTICES_VOL Determine border vertices of a volume mesh. */
  /*  */
  /*  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER) */
  /*  Determines border vertices of a volume mesh.  It supports both linear */
  /*     and quadratic elements. It returns bitmap of border vertices. For */
  /*     quadratic elements, vertices on edge and face centers are set to false, */
  /*     unless QUADRATIC is set to true at input. */
  /*  */
  /*  Example */
  /*  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS) */
  /*  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS) */
  /*  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER) */
  /*  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER,LINEAR) */
  /*  */
  /*  See also DETERMINE_BORDER_VERTICES_CURV, DETERMINE_BORDER_VERTICES_SURF */
  jj = isborder->size[0];
  isborder->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)isborder, jj, (int32_T)sizeof(boolean_T));
  loop_ub = nv - 1;
  for (jj = 0; jj <= loop_ub; jj++) {
    isborder->data[jj] = FALSE;
  }

  /*  List vertices in counter-clockwise order, so that faces are outwards. */
  /*  Table for local IDs of incident faces of each vertex. */
  nv = 0;
  while ((nv + 1 <= elems->size[0]) && (!(elems->data[nv] == 0))) {
    for (jj = 0; jj < 4; jj++) {
      if (opphfs->data[nv + opphfs->size[0] * jj] == 0) {
        for (loop_ub = 0; loop_ub < 3; loop_ub++) {
          isborder->data[elems->data[nv + elems->size[0] * (hf[jj + (loop_ub <<
            2)] - 1)] - 1] = TRUE;
        }
      }
    }

    nv++;
  }

  /*  Construct a vertex-to-halfface mapping. */
  nv = 0;
  while ((nv + 1 <= elems->size[0]) && (!(elems->data[nv] == 0))) {
    jj = 0;
    while ((jj + 1 < 5) && (!(elems->data[nv + elems->size[0] * jj] == 0))) {
      if (v2hf->data[elems->data[nv + elems->size[0] * jj] - 1] == 0) {
        for (loop_ub = 0; loop_ub < 3; loop_ub++) {
          if ((!isborder->data[elems->data[nv + elems->size[0] * jj] - 1]) ||
              (opphfs->data[nv + opphfs->size[0] * (v2f[jj + (loop_ub << 2)] - 1)]
               == 0)) {
            v2hf->data[elems->data[nv + elems->size[0] * jj] - 1] = (((nv + 1) <<
              3) + v2f[jj + (loop_ub << 2)]) - 1;
          }
        }
      }

      jj++;
    }

    nv++;
  }

  emxFree_boolean_T(&isborder);
  emxFree_int32_T(&b_v2hf);
}

void determine_incident_halffaces_initialize(void)
{
}

void determine_incident_halffaces_terminate(void)
{
  /* (no terminate code required) */
}


#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_OPPOSITE_HALFEDGE_QUAD Determine the opposite half-edge.
 *  DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,OPPHES) Determines
 *  the opposite half-edge for a quadrilateral or mixed (quad-dominant) mesh.
 *  The following explains the input and output arguments.
 *
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS)
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,OPPHES)
 *  Computes mapping from each half-edge to its opposite half-edge.
 *
 *  Convention: Each half-edge is indicated by <face_id,local_edge_id>.
 *  We assign 2 bits to local_edge_id (starts from 0).
 *
 *  See also DETERMINE_OPPOSITE_HALFEDGE
 */
void determine_opposite_halfedge_quad(int32_T nv, const emxArray_int32_T *quads,
  emxArray_int32_T *opphes)
{
  emxArray_int32_T *is_index;
  int32_T nquads;
  int32_T i0;
  int32_T ii;
  boolean_T exitg1;
  int32_T b_is_index[3];
  int32_T c_is_index[4];
  emxArray_int32_T *v2nv;
  emxArray_int32_T *v2he;
  int32_T ne;
  static const int8_T iv0[3] = { 1, 2, 0 };

  static const int8_T iv1[4] = { 1, 2, 3, 0 };

  int32_T quads_idx_0;
  int32_T i1;
  static const int8_T iv2[4] = { 2, 3, 4, 1 };

  static const int8_T iv3[3] = { 2, 3, 1 };

  emxInit_int32_T(&is_index, 1);

  /*  Number of edges per element */
  nquads = quads->size[0];

  /* % First, build is_index to store starting position for each vertex. */
  i0 = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, i0, (int32_T)sizeof(int32_T));
  for (i0 = 0; i0 <= nv; i0++) {
    is_index->data[i0] = 0;
  }

  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= nquads)) {
    if (quads->data[ii] == 0) {
      nquads = ii;
      exitg1 = TRUE;
    } else {
      if (quads->data[ii + quads->size[0] * 3] == 0) {
        for (i0 = 0; i0 < 3; i0++) {
          b_is_index[i0] = is_index->data[quads->data[ii + quads->size[0] * i0]]
            + 1;
        }

        for (i0 = 0; i0 < 3; i0++) {
          is_index->data[quads->data[ii + quads->size[0] * i0]] = b_is_index[i0];
        }
      } else {
        for (i0 = 0; i0 < 4; i0++) {
          c_is_index[i0] = is_index->data[quads->data[ii + quads->size[0] * i0]]
            + 1;
        }

        for (i0 = 0; i0 < 4; i0++) {
          is_index->data[quads->data[ii + quads->size[0] * i0]] = c_is_index[i0];
        }
      }

      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2nv, 1);
  emxInit_int32_T(&v2he, 1);
  ne = nquads << 2;
  i0 = v2nv->size[0];
  v2nv->size[0] = ne;
  emxEnsureCapacity((emxArray__common *)v2nv, i0, (int32_T)sizeof(int32_T));

  /*  Vertex to next vertex in each halfedge. */
  i0 = v2he->size[0];
  v2he->size[0] = ne;
  emxEnsureCapacity((emxArray__common *)v2he, i0, (int32_T)sizeof(int32_T));

  /*  Vertex to half-edge. */
  for (ii = 0; ii + 1 <= nquads; ii++) {
    if (quads->data[ii + quads->size[0] * 3] == 0) {
      for (i0 = 0; i0 < 3; i0++) {
        v2nv->data[is_index->data[quads->data[ii + quads->size[0] * i0] - 1] - 1]
          = quads->data[ii + quads->size[0] * iv0[i0]];
      }

      ne = (ii + 1) << 2;
      for (i0 = 0; i0 < 3; i0++) {
        v2he->data[is_index->data[quads->data[ii + quads->size[0] * i0] - 1] - 1]
          = i0 + ne;
      }

      for (i0 = 0; i0 < 3; i0++) {
        b_is_index[i0] = is_index->data[quads->data[ii + quads->size[0] * i0] -
          1] + 1;
      }

      for (i0 = 0; i0 < 3; i0++) {
        is_index->data[quads->data[ii + quads->size[0] * i0] - 1] =
          b_is_index[i0];
      }
    } else {
      for (i0 = 0; i0 < 4; i0++) {
        v2nv->data[is_index->data[quads->data[ii + quads->size[0] * i0] - 1] - 1]
          = quads->data[ii + quads->size[0] * iv1[i0]];
      }

      ne = (ii + 1) << 2;
      for (i0 = 0; i0 < 4; i0++) {
        v2he->data[is_index->data[quads->data[ii + quads->size[0] * i0] - 1] - 1]
          = i0 + ne;
      }

      for (i0 = 0; i0 < 4; i0++) {
        c_is_index[i0] = is_index->data[quads->data[ii + quads->size[0] * i0] -
          1] + 1;
      }

      for (i0 = 0; i0 < 4; i0++) {
        is_index->data[quads->data[ii + quads->size[0] * i0] - 1] =
          c_is_index[i0];
      }
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;

  /* % Set opphes */
  if (opphes->size[0] == 0) {
    quads_idx_0 = quads->size[0];
    i0 = opphes->size[0] * opphes->size[1];
    opphes->size[0] = quads_idx_0;
    opphes->size[1] = 4;
    emxEnsureCapacity((emxArray__common *)opphes, i0, (int32_T)sizeof(int32_T));
    for (i0 = 0; i0 < 4; i0++) {
      ne = quads_idx_0 - 1;
      for (i1 = 0; i1 <= ne; i1++) {
        opphes->data[i1 + opphes->size[0] * i0] = 0;
      }
    }
  } else {
    i0 = opphes->size[0] * opphes->size[1];
    opphes->size[0] = opphes->size[0];
    opphes->size[1] = 4;
    emxEnsureCapacity((emxArray__common *)opphes, i0, (int32_T)sizeof(int32_T));
    for (i0 = 0; i0 < 4; i0++) {
      ne = opphes->size[0] - 1;
      for (i1 = 0; i1 <= ne; i1++) {
        opphes->data[i1 + opphes->size[0] * i0] = 0;
      }
    }
  }

  for (ii = 0; ii + 1 <= nquads; ii++) {
    i0 = (quads->data[ii + quads->size[0] * 3] != 0) + 3;
    for (quads_idx_0 = 0; quads_idx_0 + 1 <= i0; quads_idx_0++) {
      if (opphes->data[ii + opphes->size[0] * quads_idx_0] != 0) {
      } else {
        if (quads->data[ii + quads->size[0] * 3] != 0) {
          ne = quads->data[ii + quads->size[0] * (iv2[quads_idx_0] - 1)];
        } else {
          ne = quads->data[ii + quads->size[0] * (iv3[quads_idx_0] - 1)];
        }

        /*  LOCATE: Locate index col in v2nv(first:last) */
        i1 = is_index->data[ne] - 1;
        for (ne = is_index->data[ne - 1] - 1; ne + 1 <= i1; ne++) {
          if (v2nv->data[ne] == quads->data[ii + quads->size[0] * quads_idx_0])
          {
            opphes->data[ii + opphes->size[0] * quads_idx_0] = v2he->data[ne];

            /*  opphes(heid2fid(opp),heid2leid(opp)) = ii*4+jj-1; */
            opphes->data[((int32_T)((uint32_T)v2he->data[ne] >> 2U) +
                          opphes->size[0] * (v2he->data[ne] - ((v2he->data[ne] >>
              2) << 2))) - 1] = ((ii + 1) << 2) + quads_idx_0;
          }
        }

        /*  Check for consistency */
      }
    }
  }

  emxFree_int32_T(&v2he);
  emxFree_int32_T(&v2nv);
  emxFree_int32_T(&is_index);
}

void determine_opposite_halfedge_quad_initialize(void)
{
}

void determine_opposite_halfedge_quad_terminate(void)
{
  /* (no terminate code required) */
}


#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_OPPOSITE_HALFEDGE_TRI Determine opposite half-edges for triangle
 * mesh.
 *  DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS,OPPHES) Determines
 *  opposite half-edges for triangle mesh. The following explains the input
 *  and output arguments.
 *
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS)
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_TRI(NV,TRIS,OPPHES)
 *  Computes mapping from each half-edge to its opposite half-edge for
 *  triangle mesh.
 *
 *  Convention: Each half-edge is indicated by <face_id,local_edge_id>.
 *  We assign 2 bits to local_edge_id (starts from 0).
 *
 *  See also DETERMINE_OPPOSITE_HALFEDGE
 */
static void determine_opposite_halfedge_tri(int32_T nv, const emxArray_int32_T
  *tris, emxArray_int32_T *opphes)
{
  emxArray_int32_T *is_index;
  int32_T ntris;
  int32_T i2;
  int32_T ii;
  boolean_T exitg1;
  int32_T b_is_index[3];
  emxArray_int32_T *v2nv;
  emxArray_int32_T *v2he;
  int32_T ne;
  static const int8_T next[3] = { 2, 3, 1 };

  int32_T loop_ub;
  static const int8_T iv2[3] = { 2, 3, 1 };

  emxInit_int32_T(&is_index, 1);

  /*  Number of edges per element */
  ntris = tris->size[0];

  /* % First, build is_index to store starting position for each vertex. */
  i2 = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, i2, (int32_T)sizeof(int32_T));
  for (i2 = 0; i2 <= nv; i2++) {
    is_index->data[i2] = 0;
  }

  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= ntris)) {
    if (tris->data[ii] == 0) {
      ntris = ii;
      exitg1 = TRUE;
    } else {
      for (i2 = 0; i2 < 3; i2++) {
        b_is_index[i2] = is_index->data[tris->data[ii + tris->size[0] * i2]] + 1;
      }

      for (i2 = 0; i2 < 3; i2++) {
        is_index->data[tris->data[ii + tris->size[0] * i2]] = b_is_index[i2];
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
  ne = ntris * 3;
  i2 = v2nv->size[0];
  v2nv->size[0] = ne;
  emxEnsureCapacity((emxArray__common *)v2nv, i2, (int32_T)sizeof(int32_T));

  /*  Vertex to next vertex in each halfedge. */
  i2 = v2he->size[0];
  v2he->size[0] = ne;
  emxEnsureCapacity((emxArray__common *)v2he, i2, (int32_T)sizeof(int32_T));

  /*  Vertex to half-edge. */
  for (ii = 0; ii + 1 <= ntris; ii++) {
    for (i2 = 0; i2 < 3; i2++) {
      v2nv->data[is_index->data[tris->data[ii + tris->size[0] * i2] - 1] - 1] =
        tris->data[ii + tris->size[0] * (next[i2] - 1)];
    }

    ne = (ii + 1) << 2;
    for (i2 = 0; i2 < 3; i2++) {
      v2he->data[is_index->data[tris->data[ii + tris->size[0] * i2] - 1] - 1] =
        i2 + ne;
    }

    for (i2 = 0; i2 < 3; i2++) {
      b_is_index[i2] = is_index->data[tris->data[ii + tris->size[0] * i2] - 1] +
        1;
    }

    for (i2 = 0; i2 < 3; i2++) {
      is_index->data[tris->data[ii + tris->size[0] * i2] - 1] = b_is_index[i2];
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;

  /* % Set opphes */
  if ((opphes->size[0] == 0) || (opphes->size[1] == 0)) {
    ne = tris->size[0];
    i2 = opphes->size[0] * opphes->size[1];
    opphes->size[0] = ne;
    opphes->size[1] = 3;
    emxEnsureCapacity((emxArray__common *)opphes, i2, (int32_T)sizeof(int32_T));
    for (i2 = 0; i2 < 3; i2++) {
      loop_ub = ne - 1;
      for (ii = 0; ii <= loop_ub; ii++) {
        opphes->data[ii + opphes->size[0] * i2] = 0;
      }
    }
  } else {
    i2 = opphes->size[0] * opphes->size[1];
    opphes->size[0] = opphes->size[0];
    opphes->size[1] = opphes->size[1];
    emxEnsureCapacity((emxArray__common *)opphes, i2, (int32_T)sizeof(int32_T));
    loop_ub = opphes->size[1] - 1;
    for (i2 = 0; i2 <= loop_ub; i2++) {
      ne = opphes->size[0] - 1;
      for (ii = 0; ii <= ne; ii++) {
        opphes->data[ii + opphes->size[0] * i2] = 0;
      }
    }
  }

  for (ii = 0; ii + 1 <= ntris; ii++) {
    for (ne = 0; ne < 3; ne++) {
      if (opphes->data[ii + opphes->size[0] * ne] != 0) {
      } else {
        /*  LOCATE: Locate index col in v2nv(first:last) */
        i2 = is_index->data[tris->data[ii + tris->size[0] * (iv2[ne] - 1)]] - 1;
        for (loop_ub = is_index->data[tris->data[ii + tris->size[0] * (iv2[ne] -
              1)] - 1] - 1; loop_ub + 1 <= i2; loop_ub++) {
          if (v2nv->data[loop_ub] == tris->data[ii + tris->size[0] * ne]) {
            opphes->data[ii + opphes->size[0] * ne] = v2he->data[loop_ub];

            /* opphes(heid2fid(opp),heid2leid(opp)) = ii*4+jj-1; */
            opphes->data[((int32_T)((uint32_T)v2he->data[loop_ub] >> 2U) +
                          opphes->size[0] * (v2he->data[loop_ub] - ((v2he->
              data[loop_ub] >> 2) << 2))) - 1] = ((ii + 1) << 2) + ne;
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



/*
 * DETERMINE_OPPOSITE_HALFEDGE determines the opposite half-edge of
 *  each halfedge for an oriented, manifold surface mesh with or
 *  without boundary. It works for both triangle and quadrilateral
 *  meshes that are either linear and quadratic.
 *
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE(NV,ELEMS)
 *  OPPHES = DETERMINE_OPPOSITE_HALFEDGE(NV,ELEMS,OPPHES)
 *  computes mapping from each half-edge to its opposite half-edge. This
 *  function supports triangular, quadrilateral, and mixed meshes.
 *
 *  Convention: Each half-edge is indicated by <face_id,local_edge_id>.
 *     We assign 2 bits to local_edge_id.
 *
 *  See also DETERMINE_NEXTPAGE_SURF, DETERMINE_INCIDENT_HALFEDGES
 */
void determine_opposite_halfedge(int32_T nv, const emxArray_int32_T *elems,
  emxArray_int32_T *opphes)
{
  boolean_T guard1 = FALSE;
  boolean_T guard2 = FALSE;
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
  static const int8_T next3[3] = { 2, 3, 1 };

  static const int8_T next4[4] = { 2, 3, 4, 1 };

  int32_T loop_ub;
  int32_T i1;
  static const int8_T iv0[4] = { 2, 3, 4, 1 };

  static const int8_T iv1[3] = { 2, 3, 1 };

  guard1 = FALSE;
  guard2 = FALSE;
  switch (elems->size[1]) {
   case 3:
    guard1 = TRUE;
    break;

   case 6:
    guard1 = TRUE;
    break;

   case 4:
    guard2 = TRUE;
    break;

   case 8:
    guard2 = TRUE;
    break;

   case 9:
    guard2 = TRUE;
    break;

   default:
    i0 = opphes->size[0] * opphes->size[1];
    opphes->size[0] = 0;
    opphes->size[1] = 3;
    emxEnsureCapacity((emxArray__common *)opphes, i0, (int32_T)sizeof(int32_T));
    break;
  }

  if (guard2 == TRUE) {
    emxInit_int32_T(&is_index, 1);

    /*  quad */
    /* DETERMINE_OPPOSITE_HALFEDGE_QUAD Determine the opposite half-edge. */
    /*  DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,OPPHES) Determines */
    /*  the opposite half-edge for a quadrilateral or mixed (quad-dominant) mesh. */
    /*  The following explains the input and output arguments. */
    /*  */
    /*  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS) */
    /*  OPPHES = DETERMINE_OPPOSITE_HALFEDGE_QUAD(NV,QUADS,OPPHES) */
    /*  Computes mapping from each half-edge to its opposite half-edge. */
    /*  */
    /*  Convention: Each half-edge is indicated by <face_id,local_edge_id>. */
    /*  We assign 2 bits to local_edge_id (starts from 0). */
    /*  */
    /*  See also DETERMINE_OPPOSITE_HALFEDGE */
    /*  Number of edges per element */
    nquads = elems->size[0];

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
      if (elems->data[ii] == 0) {
        nquads = ii;
        exitg1 = TRUE;
      } else {
        if (elems->data[ii + elems->size[0] * 3] == 0) {
          for (i0 = 0; i0 < 3; i0++) {
            b_is_index[i0] = is_index->data[elems->data[ii + elems->size[0] * i0]]
              + 1;
          }

          for (i0 = 0; i0 < 3; i0++) {
            is_index->data[elems->data[ii + elems->size[0] * i0]] =
              b_is_index[i0];
          }
        } else {
          for (i0 = 0; i0 < 4; i0++) {
            c_is_index[i0] = is_index->data[elems->data[ii + elems->size[0] * i0]]
              + 1;
          }

          for (i0 = 0; i0 < 4; i0++) {
            is_index->data[elems->data[ii + elems->size[0] * i0]] =
              c_is_index[i0];
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
      if (elems->data[ii + elems->size[0] * 3] == 0) {
        for (i0 = 0; i0 < 3; i0++) {
          v2nv->data[is_index->data[elems->data[ii + elems->size[0] * i0] - 1] -
            1] = elems->data[ii + elems->size[0] * (next3[i0] - 1)];
        }

        ne = (ii + 1) << 2;
        for (i0 = 0; i0 < 3; i0++) {
          v2he->data[is_index->data[elems->data[ii + elems->size[0] * i0] - 1] -
            1] = i0 + ne;
        }

        for (i0 = 0; i0 < 3; i0++) {
          b_is_index[i0] = is_index->data[elems->data[ii + elems->size[0] * i0]
            - 1] + 1;
        }

        for (i0 = 0; i0 < 3; i0++) {
          is_index->data[elems->data[ii + elems->size[0] * i0] - 1] =
            b_is_index[i0];
        }
      } else {
        for (i0 = 0; i0 < 4; i0++) {
          v2nv->data[is_index->data[elems->data[ii + elems->size[0] * i0] - 1] -
            1] = elems->data[ii + elems->size[0] * (next4[i0] - 1)];
        }

        ne = (ii + 1) << 2;
        for (i0 = 0; i0 < 4; i0++) {
          v2he->data[is_index->data[elems->data[ii + elems->size[0] * i0] - 1] -
            1] = i0 + ne;
        }

        for (i0 = 0; i0 < 4; i0++) {
          c_is_index[i0] = is_index->data[elems->data[ii + elems->size[0] * i0]
            - 1] + 1;
        }

        for (i0 = 0; i0 < 4; i0++) {
          is_index->data[elems->data[ii + elems->size[0] * i0] - 1] =
            c_is_index[i0];
        }
      }
    }

    for (ii = nv - 1; ii > 0; ii--) {
      is_index->data[ii] = is_index->data[ii - 1];
    }

    is_index->data[0] = 1;

    /* % Set opphes */
    if ((opphes->size[0] == 0) || (opphes->size[1] == 0)) {
      ne = elems->size[0];
      i0 = opphes->size[0] * opphes->size[1];
      opphes->size[0] = ne;
      opphes->size[1] = 4;
      emxEnsureCapacity((emxArray__common *)opphes, i0, (int32_T)sizeof(int32_T));
      for (i0 = 0; i0 < 4; i0++) {
        loop_ub = ne - 1;
        for (i1 = 0; i1 <= loop_ub; i1++) {
          opphes->data[i1 + opphes->size[0] * i0] = 0;
        }
      }
    } else {
      i0 = opphes->size[0] * opphes->size[1];
      opphes->size[0] = opphes->size[0];
      opphes->size[1] = opphes->size[1];
      emxEnsureCapacity((emxArray__common *)opphes, i0, (int32_T)sizeof(int32_T));
      loop_ub = opphes->size[1] - 1;
      for (i0 = 0; i0 <= loop_ub; i0++) {
        ne = opphes->size[0] - 1;
        for (i1 = 0; i1 <= ne; i1++) {
          opphes->data[i1 + opphes->size[0] * i0] = 0;
        }
      }
    }

    for (ii = 0; ii + 1 <= nquads; ii++) {
      i0 = (elems->data[ii + elems->size[0] * 3] != 0) + 3;
      for (loop_ub = 0; loop_ub + 1 <= i0; loop_ub++) {
        if (opphes->data[ii + opphes->size[0] * loop_ub] != 0) {
        } else {
          if (elems->data[ii + elems->size[0] * 3] != 0) {
            ne = elems->data[ii + elems->size[0] * (iv0[loop_ub] - 1)];
          } else {
            ne = elems->data[ii + elems->size[0] * (iv1[loop_ub] - 1)];
          }

          /*  LOCATE: Locate index col in v2nv(first:last) */
          i1 = is_index->data[ne] - 1;
          for (ne = is_index->data[ne - 1] - 1; ne + 1 <= i1; ne++) {
            if (v2nv->data[ne] == elems->data[ii + elems->size[0] * loop_ub]) {
              opphes->data[ii + opphes->size[0] * loop_ub] = v2he->data[ne];

              /*  opphes(heid2fid(opp),heid2leid(opp)) = ii*4+jj-1; */
              opphes->data[((int32_T)((uint32_T)v2he->data[ne] >> 2U) +
                            opphes->size[0] * (v2he->data[ne] - ((v2he->data[ne]
                >> 2) << 2))) - 1] = ((ii + 1) << 2) + loop_ub;
            }
          }

          /*  Check for consistency */
        }
      }
    }

    emxFree_int32_T(&v2he);
    emxFree_int32_T(&v2nv);
    emxFree_int32_T(&is_index);

    /*          case 1 */
    /*              assert(false); */
    /*              % TODO: Implement support for mixed elements */
    /*              % opphes = determine_opposite_halfedge_mixed(nv, elems, opphes); */
    /*              opphes = zeros( 0, 3, 'int32'); */
  }

  if (guard1 == TRUE) {
    /*  tri */
    determine_opposite_halfedge_tri(nv, elems, opphes);
  }
}

void determine_opposite_halfedge_initialize(void)
{
}

void determine_opposite_halfedge_terminate(void)
{
  /* (no terminate code required) */
}

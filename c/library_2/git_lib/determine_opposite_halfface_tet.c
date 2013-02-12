
#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_OPPOSITE_HALFFACE_TET Determine the opposite half-face.
 *  DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS,OPPHFS) Determines the
 *  opposite half-face.
 *
 *  OPPHFS = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS)
 *  OPPHFS = DETERMINE_OPPOSITE_HALFFACE_TET(NV,ELEMS,OPPHFS)
 *  computes mapping from each half-face to its opposite half-face.
 *
 *  We assign three bits to local_face_id.
 */
void determine_opposite_halfface_tet(int32_T nv, const emxArray_int32_T *elems,
  emxArray_int32_T *opphfs)
{
  emxArray_int32_T *is_index;
  int32_T i0;
  int32_T nelems;
  int32_T ii;
  boolean_T exitg2;
  int32_T jj;
  static const int8_T hf_tet[12] = { 1, 1, 2, 3, 3, 2, 3, 1, 2, 4, 4, 4 };

  int32_T mtmp;
  int32_T ix;
  emxArray_int32_T *v2hf;
  emxArray_int32_T *v2oe_v1;
  emxArray_int32_T *v2oe_v2;
  int32_T itmp;
  static const int8_T iv0[3] = { 2, 3, 1 };

  static const int8_T iv1[3] = { 3, 1, 2 };

  int32_T b_index;
  boolean_T exitg1;
  emxInit_int32_T(&is_index, 1);

  /*  Note: See http://www.grc.nasa.gov/WWW/cgns/CGNS_docs_current/sids/conv.html for numbering */
  /*        convention of faces. */
  /*  Table for vertices of each face. */
  /* % First, build is_index to store starting position for each vertex. */
  i0 = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, i0, (int32_T)sizeof(int32_T));
  for (i0 = 0; i0 <= nv; i0++) {
    is_index->data[i0] = 0;
  }

  nelems = elems->size[0];
  ii = 0;
  exitg2 = FALSE;
  while ((exitg2 == 0U) && (ii + 1 <= nelems)) {
    if (elems->data[ii] == 0) {
      nelems = ii;
      exitg2 = TRUE;
    } else {
      for (jj = 0; jj < 4; jj++) {
        mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj] - 1)];
        for (ix = 0; ix < 2; ix++) {
          if (elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)] -
               1)] > mtmp) {
            mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)]
              - 1)];
          }
        }

        is_index->data[mtmp]++;
      }

      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2hf, 1);
  emxInit_int32_T(&v2oe_v1, 1);
  emxInit_int32_T(&v2oe_v2, 1);

  /*  v2hf stores mapping from each vertex to half-face ID. */
  /*  v2oe stores mapping from each vertex to the encoding of the opposite */
  /*      edge of each half-face.. */
  i0 = v2hf->size[0];
  v2hf->size[0] = is_index->data[nv];
  emxEnsureCapacity((emxArray__common *)v2hf, i0, (int32_T)sizeof(int32_T));
  i0 = v2oe_v1->size[0];
  v2oe_v1->size[0] = is_index->data[nv];
  emxEnsureCapacity((emxArray__common *)v2oe_v1, i0, (int32_T)sizeof(int32_T));
  i0 = v2oe_v2->size[0];
  v2oe_v2->size[0] = is_index->data[nv];
  emxEnsureCapacity((emxArray__common *)v2oe_v2, i0, (int32_T)sizeof(int32_T));
  for (ii = 0; ii + 1 <= nelems; ii++) {
    for (jj = 0; jj < 4; jj++) {
      mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj] - 1)] - 1;
      itmp = 0;
      for (ix = 0; ix < 2; ix++) {
        if (elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)] - 1)]
            > mtmp + 1) {
          mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)]
            - 1)] - 1;
          itmp = ix + 1;
        }
      }

      v2oe_v1->data[is_index->data[mtmp] - 1] = elems->data[ii + elems->size[0] *
        (hf_tet[jj + ((iv0[itmp] - 1) << 2)] - 1)];
      v2oe_v2->data[is_index->data[mtmp] - 1] = elems->data[ii + elems->size[0] *
        (hf_tet[jj + ((iv1[itmp] - 1) << 2)] - 1)];
      v2hf->data[is_index->data[mtmp] - 1] = ((ii + 1) << 3) + jj;
      is_index->data[mtmp]++;
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;

  /*  Fill in opphfs for each half-face. */
  if (opphfs->size[0] == 0) {
    mtmp = elems->size[0];
    i0 = opphfs->size[0] * opphfs->size[1];
    opphfs->size[0] = mtmp;
    opphfs->size[1] = 4;
    emxEnsureCapacity((emxArray__common *)opphfs, i0, (int32_T)sizeof(int32_T));
    for (i0 = 0; i0 < 4; i0++) {
      ix = mtmp - 1;
      for (b_index = 0; b_index <= ix; b_index++) {
        opphfs->data[b_index + opphfs->size[0] * i0] = 0;
      }
    }
  } else {
    i0 = opphfs->size[0] * opphfs->size[1];
    opphfs->size[0] = opphfs->size[0];
    opphfs->size[1] = 4;
    emxEnsureCapacity((emxArray__common *)opphfs, i0, (int32_T)sizeof(int32_T));
    for (i0 = 0; i0 < 4; i0++) {
      ix = opphfs->size[0] - 1;
      for (b_index = 0; b_index <= ix; b_index++) {
        opphfs->data[b_index + opphfs->size[0] * i0] = 0;
      }
    }
  }

  for (ii = 0; ii + 1 <= nelems; ii++) {
    for (jj = 0; jj < 4; jj++) {
      /*  local face ID */
      if (opphfs->data[ii + opphfs->size[0] * jj] != 0) {
      } else {
        /*  list of vertices of face */
        mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj] - 1)];
        itmp = 0;
        for (ix = 0; ix < 2; ix++) {
          if (elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)] -
               1)] > mtmp) {
            mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj + ((ix + 1) << 2)]
              - 1)];
            itmp = ix + 1;
          }
        }

        /*  Search for opposite half-face. */
        i0 = is_index->data[mtmp] - 1;
        b_index = is_index->data[mtmp - 1] - 1;
        exitg1 = FALSE;
        while ((exitg1 == 0U) && (b_index + 1 <= i0)) {
          if ((v2oe_v1->data[b_index] == elems->data[ii + elems->size[0] *
               (hf_tet[jj + ((iv1[itmp] - 1) << 2)] - 1)]) && (v2oe_v2->
               data[b_index] == elems->data[ii + elems->size[0] * (hf_tet[jj +
                ((iv0[itmp] - 1) << 2)] - 1)])) {
            opphfs->data[ii + opphfs->size[0] * jj] = v2hf->data[b_index];

            /*  opphfs(hfid2cid(opp),hfid2lfid(opp)) = ii*8+jj-1; */
            opphfs->data[((int32_T)((uint32_T)v2hf->data[b_index] >> 3U) +
                          opphfs->size[0] * (v2hf->data[b_index] - ((v2hf->
              data[b_index] >> 3) << 3))) - 1] = ((ii + 1) << 3) + jj;
            exitg1 = TRUE;
          } else {
            b_index++;
          }
        }
      }
    }
  }

  emxFree_int32_T(&v2oe_v2);
  emxFree_int32_T(&v2oe_v1);
  emxFree_int32_T(&v2hf);
  emxFree_int32_T(&is_index);
}

void determine_opposite_halfface_tet_initialize(void)
{
}

void determine_opposite_halfface_tet_terminate(void)
{
  /* (no terminate code required) */
}

#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 *  DETERMINE_BORDER_VERTICES_VOL Determine border vertices of a volume mesh.
 *
 *  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER)
 *  Determines border vertices of a volume mesh.  It supports both linear
 *     and quadratic elements. It returns bitmap of border vertices. For
 *     quadratic elements, vertices on edge and face centers are set to false,
 *     unless QUADRATIC is set to true at input.
 *
 *  Example
 *  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS)
 *  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS)
 *  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER)
 *  ISBORDER = DETERMINE_BORDER_VERTICES_VOL(NV,ELEMS,OPPHFS,ISBORDER,LINEAR)
 *
 *  See also DETERMINE_BORDER_VERTICES_CURV, DETERMINE_BORDER_VERTICES_SURF
 */
void determine_border_vertices_vol(int32_T nv, const emxArray_int32_T *elems,
  const emxArray_int32_T *opphfs, emxArray_boolean_T *isborder, boolean_T
  quadratic)
{
  emxArray_boolean_T *b_isborder;
  int32_T nfpE;
  int32_T ii;
  boolean_T guard5 = FALSE;
  boolean_T guard6 = FALSE;
  boolean_T guard7 = FALSE;
  boolean_T guard8 = FALSE;
  boolean_T b0;
  int32_T nvpf;
  int32_T jj;
  int32_T kk;
  static const int8_T hf_hex[54] = { 1, 1, 2, 3, 4, 5, 4, 2, 3, 4, 1, 6, 3, 6, 7,
    8, 5, 7, 2, 5, 6, 7, 8, 8, 12, 9, 10, 11, 13, 17, 11, 14, 15, 16, 20, 18, 10,
    17, 18, 19, 16, 19, 9, 13, 14, 15, 12, 20, 21, 22, 23, 24, 25, 26 };

  boolean_T b1;
  static const int8_T hf_pri[45] = { 1, 2, 3, 1, 4, 2, 3, 1, 3, 5, 5, 6, 4, 2, 6,
    4, 5, 6, 9, 13, 7, 8, 9, 8, 14, 11, 12, 10, 7, 15, 13, 14, 15, 0, 0, 10, 11,
    12, 0, 0, 16, 17, 18, 0, 0 };

  static const int8_T hf_pyr[45] = { 1, 1, 2, 3, 4, 4, 2, 3, 4, 1, 3, 5, 5, 5, 5,
    2, 6, 7, 8, 9, 9, 11, 12, 13, 10, 8, 10, 11, 12, 13, 7, 0, 0, 0, 0, 6, 0, 0,
    0, 0, 14, 0, 0, 0, 0 };

  static const int8_T hf_tet[24] = { 1, 1, 2, 3, 3, 2, 3, 1, 2, 4, 4, 4, 7, 5, 6,
    7, 5, 9, 10, 8, 6, 8, 9, 10 };

  emxArray_int32_T *hf;
  boolean_T guard1 = FALSE;
  boolean_T guard2 = FALSE;
  boolean_T guard3 = FALSE;
  boolean_T guard4 = FALSE;
  static const int8_T iv0[45] = { 1, 2, 3, 1, 4, 2, 3, 1, 3, 5, 5, 6, 4, 2, 6, 4,
    5, 6, 2, 6, 7, 8, 9, 9, 13, 11, 12, 10, 8, 14, 13, 14, 15, 7, 15, 10, 11, 12,
    7, 15, 16, 17, 18, 7, 15 };

  static const int8_T b_hf_pyr[45] = { 1, 1, 2, 3, 4, 4, 2, 3, 4, 1, 3, 5, 5, 5,
    5, 2, 5, 5, 5, 5, 9, 6, 7, 8, 9, 8, 11, 12, 13, 10, 7, 10, 11, 12, 13, 6, 10,
    11, 12, 13, 14, 10, 11, 12, 13 };

  emxInit_boolean_T(&b_isborder, 1);
  if (isborder->size[0] == 0) {
    nfpE = isborder->size[0];
    isborder->size[0] = nv;
    emxEnsureCapacity((emxArray__common *)isborder, nfpE, (int32_T)sizeof
                      (boolean_T));
    ii = nv - 1;
    for (nfpE = 0; nfpE <= ii; nfpE++) {
      isborder->data[nfpE] = FALSE;
    }
  }

  /*  List vertices in counter-clockwise order, so that faces are outwards. */
  if (elems->size[1] == 1) {
    /*  Mixed elements */
    nfpE = 0;
    ii = 1;
    while (nfpE + 1 < elems->size[0]) {
      guard5 = FALSE;
      guard6 = FALSE;
      guard7 = FALSE;
      guard8 = FALSE;
      switch (elems->data[nfpE]) {
       case 4:
        guard5 = TRUE;
        break;

       case 10:
        guard5 = TRUE;
        break;

       case 5:
        guard6 = TRUE;
        break;

       case 14:
        guard6 = TRUE;
        break;

       case 6:
        guard7 = TRUE;
        break;

       case 15:
        guard7 = TRUE;
        break;

       case 18:
        guard7 = TRUE;
        break;

       case 8:
        guard8 = TRUE;
        break;

       case 20:
        guard8 = TRUE;
        break;

       case 27:
        guard8 = TRUE;
        break;
      }

      if (guard8 == TRUE) {
        /*  Hexahedral */
        if (quadratic && (elems->data[nfpE] > 8)) {
          b0 = TRUE;
        } else {
          b0 = FALSE;
        }

        nvpf = ((1 + (int32_T)b0) << 2) + (elems->data[nfpE] == 27);
        for (jj = 0; jj < 6; jj++) {
          if (opphfs->data[(int32_T)rt_roundd((real_T)ii + (1.0 + (real_T)jj)) -
              1] == 0) {
            for (kk = 1; kk <= nvpf; kk++) {
              isborder->data[elems->data[nfpE + hf_hex[jj + 6 * (kk - 1)]] - 1] =
                TRUE;
            }
          }
        }
      }

      if (guard7 == TRUE) {
        /*  Prism */
        if (quadratic && (elems->data[nfpE] > 6)) {
          b0 = TRUE;
        } else {
          b0 = FALSE;
        }

        for (jj = 0; jj < 5; jj++) {
          if (opphfs->data[(int32_T)rt_roundd((real_T)ii + (1.0 + (real_T)jj)) -
              1] == 0) {
            if ((elems->data[nfpE] == 18) && (1 + jj < 4)) {
              b1 = TRUE;
            } else {
              b1 = FALSE;
            }

            nvpf = (3 + (1 + jj < 4)) * ((int32_T)b0 + 1) + (int32_T)b1;
            for (kk = 1; kk <= nvpf; kk++) {
              isborder->data[elems->data[nfpE + hf_pri[jj + 5 * (kk - 1)]] - 1] =
                TRUE;
            }
          }
        }
      }

      if (guard6 == TRUE) {
        /*  Pyramid */
        if (quadratic && (elems->data[nfpE] > 5)) {
          b0 = TRUE;
        } else {
          b0 = FALSE;
        }

        for (jj = 0; jj < 5; jj++) {
          if (opphfs->data[(int32_T)rt_roundd((real_T)ii + (1.0 + (real_T)jj)) -
              1] == 0) {
            if (b0 && (1 + jj == 1)) {
              b1 = TRUE;
            } else {
              b1 = FALSE;
            }

            nvpf = (3 + (1 + jj == 1)) * (1 + (int32_T)b0) + (int32_T)b1;
            for (kk = 1; kk <= nvpf; kk++) {
              isborder->data[elems->data[nfpE + hf_pyr[jj + 5 * (kk - 1)]] - 1] =
                TRUE;
            }
          }
        }
      }

      if (guard5 == TRUE) {
        /*  Tetrahedral */
        if (quadratic && (elems->data[nfpE] > 4)) {
          b0 = TRUE;
        } else {
          b0 = FALSE;
        }

        nvpf = 3 * (1 + (int32_T)b0);
        for (jj = 0; jj < 4; jj++) {
          if (opphfs->data[(int32_T)rt_roundd((real_T)ii + (1.0 + (real_T)jj)) -
              1] == 0) {
            for (kk = 1; kk <= nvpf; kk++) {
              isborder->data[elems->data[nfpE + hf_tet[jj + ((kk - 1) << 2)]] -
                1] = TRUE;
            }
          }
        }
      }

      nfpE = (nfpE + elems->data[nfpE]) + 1;
      ii = (ii + opphfs->data[ii - 1]) + 1;
    }
  } else {
    /*  Table for local IDs of incident faces of each vertex. */
    emxInit_int32_T(&hf, 2);
    guard1 = FALSE;
    guard2 = FALSE;
    guard3 = FALSE;
    guard4 = FALSE;
    switch (elems->size[1]) {
     case 4:
      guard1 = TRUE;
      break;

     case 10:
      guard1 = TRUE;
      break;

     case 5:
      guard2 = TRUE;
      break;

     case 14:
      guard2 = TRUE;
      break;

     case 6:
      guard3 = TRUE;
      break;

     case 15:
      guard3 = TRUE;
      break;

     case 18:
      guard3 = TRUE;
      break;

     case 8:
      guard4 = TRUE;
      break;

     case 20:
      guard4 = TRUE;
      break;

     case 27:
      guard4 = TRUE;
      break;
    }

    if (guard4 == TRUE) {
      nfpE = hf->size[0] * hf->size[1];
      hf->size[0] = 6;
      hf->size[1] = 9;
      emxEnsureCapacity((emxArray__common *)hf, nfpE, (int32_T)sizeof(int32_T));
      for (nfpE = 0; nfpE < 54; nfpE++) {
        hf->data[nfpE] = hf_hex[nfpE];
      }

      if (quadratic && (elems->size[1] > 8)) {
        b0 = TRUE;
      } else {
        b0 = FALSE;
      }

      nvpf = ((1 + (int32_T)b0) << 2) + (elems->size[1] == 27);
    }

    if (guard3 == TRUE) {
      nfpE = hf->size[0] * hf->size[1];
      hf->size[0] = 5;
      hf->size[1] = 9;
      emxEnsureCapacity((emxArray__common *)hf, nfpE, (int32_T)sizeof(int32_T));
      for (nfpE = 0; nfpE < 45; nfpE++) {
        hf->data[nfpE] = iv0[nfpE];
      }

      if (quadratic && (elems->size[1] > 6)) {
        b0 = TRUE;
      } else {
        b0 = FALSE;
      }

      nvpf = ((1 + (int32_T)b0) << 2) + (elems->size[1] == 18);
    }

    if (guard2 == TRUE) {
      nfpE = hf->size[0] * hf->size[1];
      hf->size[0] = 5;
      hf->size[1] = 9;
      emxEnsureCapacity((emxArray__common *)hf, nfpE, (int32_T)sizeof(int32_T));
      for (nfpE = 0; nfpE < 45; nfpE++) {
        hf->data[nfpE] = b_hf_pyr[nfpE];
      }

      if (quadratic && (elems->size[1] > 5)) {
        b0 = TRUE;
      } else {
        b0 = FALSE;
      }

      nvpf = ((1 + (int32_T)b0) << 2) + 1;
    }

    if (guard1 == TRUE) {
      nfpE = hf->size[0] * hf->size[1];
      hf->size[0] = 4;
      hf->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)hf, nfpE, (int32_T)sizeof(int32_T));
      for (nfpE = 0; nfpE < 24; nfpE++) {
        hf->data[nfpE] = hf_tet[nfpE];
      }

      if (quadratic && (elems->size[1] > 4)) {
        b0 = TRUE;
      } else {
        b0 = FALSE;
      }

      nvpf = 3 * (1 + (int32_T)b0);
    }

    nfpE = hf->size[0];
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      for (jj = 0; jj + 1 <= nfpE; jj++) {
        if (opphfs->data[ii + opphfs->size[0] * jj] == 0) {
          for (kk = 1; kk <= nvpf; kk++) {
            isborder->data[elems->data[ii + elems->size[0] * (hf->data[jj +
              hf->size[0] * (kk - 1)] - 1)] - 1] = TRUE;
          }
        }
      }

      ii++;
    }

    emxFree_int32_T(&hf);
  }

  emxFree_boolean_T(&b_isborder);
}

void determine_border_vertices_vol_initialize(void)
{
}

void determine_border_vertices_vol_terminate(void)
{
  /* (no terminate code required) */
}


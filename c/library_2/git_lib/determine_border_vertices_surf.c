
#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif

/*
 * DETERMINE_BORDER_VERTICES Determine border vertices of a surface mesh.
 *  DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,OPPHES,ISBORDER) Determines
 *  border vertices of a surface mesh.  Returns bitmap of border vertices.
 *
 *  Example
 *  ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS)
 *  ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,OPPHES)
 *  ISBORDER = DETERMINE_BORDER_VERTICES_SURF(NV,ELEMS,OPPHES,ISBORDER)
 *
 *  See also DETERMINE_BORDER_VERTICES_CURV, DETERMINE_BORDER_VERTICES_VOL
 */
void determine_border_vertices_surf(int32_T nv, const emxArray_int32_T *elems,
  const emxArray_int32_T *opphes, emxArray_boolean_T *isborder)
{
  emxArray_boolean_T *b_isborder;
  int32_T ii;
  int32_T jj;
  int32_T b_elems[2];
  int32_T i0;
  static const int8_T he_tri3[6] = { 1, 2, 3, 2, 3, 1 };

  int32_T c_elems[3];
  static const int8_T he_tri6[9] = { 1, 2, 3, 4, 5, 6, 2, 3, 1 };

  int32_T d_elems[4];
  static const int8_T he_tri10[12] = { 1, 2, 3, 4, 6, 8, 5, 7, 9, 2, 3, 1 };

  static const int8_T he_quad4[8] = { 1, 2, 3, 4, 2, 3, 4, 1 };

  static const int8_T he_quad9[12] = { 1, 2, 3, 4, 5, 6, 7, 8, 2, 3, 4, 1 };

  static const int8_T he_quad16[16] = { 1, 2, 3, 4, 5, 7, 9, 11, 6, 8, 10, 12, 2,
    3, 4, 1 };

  emxInit_boolean_T(&b_isborder, 1);
  switch (elems->size[1]) {
   case 3:
    /*  TRI-3 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      for (jj = 0; jj < 3; jj++) {
        if (opphes->data[ii + opphes->size[0] * jj] == 0) {
          for (i0 = 0; i0 < 2; i0++) {
            b_elems[i0] = elems->data[ii + elems->size[0] * (he_tri3[jj + 3 * i0]
              - 1)] - 1;
          }

          for (i0 = 0; i0 < 2; i0++) {
            isborder->data[b_elems[i0]] = TRUE;
          }
        }
      }

      ii++;
    }
    break;

   case 6:
    /*  TRI-6 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      for (jj = 0; jj < 3; jj++) {
        if (opphes->data[ii + opphes->size[0] * jj] == 0) {
          for (i0 = 0; i0 < 3; i0++) {
            c_elems[i0] = elems->data[ii + elems->size[0] * (he_tri6[jj + 3 * i0]
              - 1)] - 1;
          }

          for (i0 = 0; i0 < 3; i0++) {
            isborder->data[c_elems[i0]] = TRUE;
          }
        }
      }

      ii++;
    }
    break;

   case 10:
    /*  TRI-10 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      for (jj = 0; jj < 3; jj++) {
        if (opphes->data[ii + opphes->size[0] * jj] == 0) {
          for (i0 = 0; i0 < 4; i0++) {
            d_elems[i0] = elems->data[ii + elems->size[0] * (he_tri10[jj + 3 *
              i0] - 1)] - 1;
          }

          for (i0 = 0; i0 < 4; i0++) {
            isborder->data[d_elems[i0]] = TRUE;
          }
        }
      }

      ii++;
    }
    break;

   case 4:
    /*  QUAD-4 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      if (elems->data[ii + elems->size[0] * 3] == 0) {
        for (jj = 0; jj < 3; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 2; i0++) {
              b_elems[i0] = elems->data[ii + elems->size[0] * (he_tri3[jj + 3 *
                i0] - 1)] - 1;
            }

            for (i0 = 0; i0 < 2; i0++) {
              isborder->data[b_elems[i0]] = TRUE;
            }
          }
        }
      } else {
        for (jj = 0; jj < 4; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 2; i0++) {
              b_elems[i0] = elems->data[ii + elems->size[0] * (he_quad4[jj + (i0
                << 2)] - 1)] - 1;
            }

            for (i0 = 0; i0 < 2; i0++) {
              isborder->data[b_elems[i0]] = TRUE;
            }
          }
        }
      }

      ii++;
    }
    break;

   case 9:
    /*  QUAD-9 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      if (elems->data[ii + elems->size[0] * 6] == 0) {
        for (jj = 0; jj < 3; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 3; i0++) {
              c_elems[i0] = elems->data[ii + elems->size[0] * (he_tri6[jj + 3 *
                i0] - 1)] - 1;
            }

            for (i0 = 0; i0 < 3; i0++) {
              isborder->data[c_elems[i0]] = TRUE;
            }
          }
        }
      } else {
        for (jj = 0; jj < 4; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 3; i0++) {
              c_elems[i0] = elems->data[ii + elems->size[0] * (he_quad9[jj + (i0
                << 2)] - 1)] - 1;
            }

            for (i0 = 0; i0 < 3; i0++) {
              isborder->data[c_elems[i0]] = TRUE;
            }
          }
        }
      }

      ii++;
    }
    break;

   case 16:
    /*  QUAD-16 */
    ii = 0;
    while ((ii + 1 <= elems->size[0]) && (!(elems->data[ii] == 0))) {
      if (elems->data[ii + elems->size[0] * 10] == 0) {
        for (jj = 0; jj < 3; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 4; i0++) {
              d_elems[i0] = elems->data[ii + elems->size[0] * (he_tri10[jj + 3 *
                i0] - 1)] - 1;
            }

            for (i0 = 0; i0 < 4; i0++) {
              isborder->data[d_elems[i0]] = TRUE;
            }
          }
        }
      } else {
        for (jj = 0; jj < 4; jj++) {
          if (opphes->data[ii + opphes->size[0] * jj] == 0) {
            for (i0 = 0; i0 < 4; i0++) {
              d_elems[i0] = elems->data[ii + elems->size[0] * (he_quad16[jj +
                (i0 << 2)] - 1)] - 1;
            }

            for (i0 = 0; i0 < 4; i0++) {
              isborder->data[d_elems[i0]] = TRUE;
            }
          }
        }
      }

      ii++;
    }
    break;
  }

  emxFree_boolean_T(&b_isborder);
}

void determine_border_vertices_surf_initialize(void)
{
}

void determine_border_vertices_surf_terminate(void)
{
  /* (no terminate code required) */
}

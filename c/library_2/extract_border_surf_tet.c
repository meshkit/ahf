
#ifndef _INCLUDE_BASIC_
#define _INCLUDE_BASIC_

#include "basic_emxArray_fncs.c"

#endif


/*
 * EXTRACT_BORDER_SURF_TET Extract border vertices and edges.
 *  [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS,INWARDS)
 *  Extracts border vertices and edges of tetrahedral mesh. Return list of
 *  border vertex IDs and list of border faces.  The following explains the
 *  input and output arguments.
 *
 *  [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS)
 *  [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL)
 *  [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS)
 *  [B2V,BDTRIS,FACEMAP] = EXTRACT_BORDER_SURF_TET(NV,TETS,ELABEL,OPPHFS,INWARDS)
 *  NV: specifies the number of vertices.
 *  TETS: contains the connectivity.
 *  ELABEL: contains a label for each element.
 *  OPPHFS: contains the opposite half-faces.
 *  INWARDS: specifies whether the face normals should be inwards (false by default)
 *  B2V: is a mapping from border-vertex ID to vertex ID.
 *  BDTRIS: is connectivity of border faces.
 *  FACMAP: stores mapping to halfface ID
 *
 *  See also EXTRACT_BORDER_SURF
 */
void extract_border_surf_tet(int32_T nv, const emxArray_int32_T *tets, const
  emxArray_int32_T *elabel, const emxArray_int32_T *opphfs, boolean_T inwards,
  emxArray_int32_T *b2v, emxArray_int32_T *bdtris, emxArray_int32_T *facmap)
{
  int8_T hf_tet[12];
  int32_T i0;
  static const int8_T iv0[12] = { 1, 1, 2, 3, 2, 4, 4, 4, 3, 2, 3, 1 };

  static const int8_T iv1[12] = { 1, 1, 2, 3, 3, 2, 3, 1, 2, 4, 4, 4 };

  emxArray_boolean_T *isborder;
  int32_T vlen;
  int32_T ngbtris;
  int32_T ii;
  int32_T jj;
  boolean_T guard2 = FALSE;
  uint32_T a;
  emxArray_int32_T *v2b;
  real_T y;
  boolean_T guard1 = FALSE;
  if (inwards) {
    /*  List vertices in counterclockwise order, so that faces are inwards. */
    for (i0 = 0; i0 < 12; i0++) {
      hf_tet[i0] = iv0[i0];
    }
  } else {
    /*  List vertices in counter-clockwise order, so that faces are outwards. */
    for (i0 = 0; i0 < 12; i0++) {
      hf_tet[i0] = iv1[i0];
    }
  }

  emxInit_boolean_T(&isborder, 1);
  i0 = isborder->size[0];
  isborder->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)isborder, i0, (int32_T)sizeof(boolean_T));
  vlen = nv - 1;
  for (i0 = 0; i0 <= vlen; i0++) {
    isborder->data[i0] = FALSE;
  }

  ngbtris = 0;
  ii = 0;
  while ((ii + 1 <= tets->size[0]) && (!(tets->data[ii] == 0))) {
    for (jj = 0; jj < 4; jj++) {
      guard2 = FALSE;
      if (opphfs->data[ii + opphfs->size[0] * jj] == 0) {
        guard2 = TRUE;
      } else {
        if (elabel->size[0] > 1) {
          a = (uint32_T)opphfs->data[ii + opphfs->size[0] * jj];
          if (elabel->data[ii] != elabel->data[(int32_T)(a >> 3U) - 1]) {
            guard2 = TRUE;
          }
        }
      }

      if (guard2 == TRUE) {
        /*  elabel(ii)~=elabel(hfid2cid(opphfs(ii,jj))) */
        for (i0 = 0; i0 < 3; i0++) {
          isborder->data[tets->data[ii + tets->size[0] * (hf_tet[jj + (i0 << 2)]
            - 1)] - 1] = TRUE;
        }

        ngbtris++;
      }
    }

    ii++;
  }

  emxInit_int32_T(&v2b, 1);

  /* % Determine border faces */
  /*  Define new numbering for border nodes */
  i0 = v2b->size[0];
  v2b->size[0] = nv;
  emxEnsureCapacity((emxArray__common *)v2b, i0, (int32_T)sizeof(int32_T));
  vlen = nv - 1;
  for (i0 = 0; i0 <= vlen; i0++) {
    v2b->data[i0] = 0;
  }

  if (isborder->size[0] == 0) {
    y = 0.0;
  } else {
    vlen = isborder->size[0];
    y = (real_T)isborder->data[0];
    for (jj = 2; jj <= vlen; jj++) {
      y += (real_T)isborder->data[jj - 1];
    }
  }

  i0 = b2v->size[0];
  b2v->size[0] = (int32_T)y;
  emxEnsureCapacity((emxArray__common *)b2v, i0, (int32_T)sizeof(int32_T));
  jj = 1;
  for (ii = 1; ii <= nv; ii++) {
    if (isborder->data[ii - 1]) {
      b2v->data[jj - 1] = ii;
      v2b->data[ii - 1] = jj;
      jj++;
    }
  }

  emxFree_boolean_T(&isborder);
  i0 = bdtris->size[0] * bdtris->size[1];
  bdtris->size[0] = ngbtris;
  bdtris->size[1] = 3;
  emxEnsureCapacity((emxArray__common *)bdtris, i0, (int32_T)sizeof(int32_T));
  i0 = facmap->size[0];
  facmap->size[0] = ngbtris;
  emxEnsureCapacity((emxArray__common *)facmap, i0, (int32_T)sizeof(int32_T));
  vlen = 0;
  ii = 0;
  while ((ii + 1 <= tets->size[0]) && (!(tets->data[ii] == 0))) {
    for (jj = 0; jj < 4; jj++) {
      guard1 = FALSE;
      if (opphfs->data[ii + opphfs->size[0] * jj] == 0) {
        guard1 = TRUE;
      } else {
        if (elabel->size[0] > 1) {
          a = (uint32_T)opphfs->data[ii + opphfs->size[0] * jj];
          if (elabel->data[ii] != elabel->data[(int32_T)(a >> 3U) - 1]) {
            guard1 = TRUE;
          }
        }
      }

      if (guard1 == TRUE) {
        /*  elabel(ii)~=elabel(hfid2cid(opphfs(ii,jj))) */
        for (i0 = 0; i0 < 3; i0++) {
          bdtris->data[vlen + bdtris->size[0] * i0] = v2b->data[tets->data[ii +
            tets->size[0] * (hf_tet[jj + (i0 << 2)] - 1)] - 1];
        }

        facmap->data[vlen] = ((ii + 1) << 3) + jj;
        vlen++;
      }
    }

    ii++;
  }

  emxFree_int32_T(&v2b);
}

void extract_border_surf_tet_initialize(void)
{
}

void extract_border_surf_tet_terminate(void)
{
  /* (no terminate code required) */
}

/* End of code generation (extract_border_surf_tet.c) */

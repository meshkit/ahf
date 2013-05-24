#include "rt_nonfinite.h"
#include "f2hf.h"
#include "m2c.h"
#ifndef struct_emxArray__common
#define struct_emxArray__common

typedef struct emxArray__common
{
  void *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray__common;

#endif

static define_emxInit(b_emxInit_boolean_T, boolean_T)
static define_emxInit(b_emxInit_int32_T, int32_T)

int32_T f2hf(int32_T *fid, const emxArray_int32_T *faces, const emxArray_int32_T
             *tets, const emxArray_int32_T *sibhfs, const emxArray_int32_T *v2hf,
             emxArray_boolean_T *etags)
{
  int32_T lfid;
  emxArray_boolean_T *b_etags;
  int32_T ngb;
  int32_T loop_ub;
  boolean_T found;
  int32_T b_fid;
  int32_T lvid1;
  int32_T lvid2;
  int32_T lvid3;
  int32_T stack[50];
  int32_T size_stack;
  emxArray_int32_T *r0;
  boolean_T exitg1;
  static const int8_T sibhfs_tet[12] = { 1, 1, 1, 2, 2, 2, 3, 3, 4, 3, 4, 4 };

  static const int8_T iv0[4] = { 1, 2, 4, 3 };

  emxInit_boolean_T(&b_etags, 1);
  ngb = b_etags->size[0];
  b_etags->size[0] = etags->size[0];
  emxEnsureCapacity((emxArray__common *)b_etags, ngb, (int32_T)sizeof(boolean_T));
  loop_ub = etags->size[0] - 1;
  for (ngb = 0; ngb <= loop_ub; ngb++) {
    b_etags->data[ngb] = etags->data[ngb];
  }

  found = FALSE;
  b_fid = (int32_T)((uint32_T)v2hf->data[faces->data[*fid - 1] - 1] >> 3U);
  lvid1 = -1;
  lvid2 = -5;
  lvid3 = 0;
  if (!(b_fid != 0)) {
  } else {
    size_stack = 1;
    stack[0] = b_fid;
    emxInit_int32_T(&r0, 1);
    exitg1 = FALSE;
    while ((exitg1 == 0U) && (size_stack > 0)) {
      b_fid = stack[size_stack - 1];
      size_stack--;
      b_etags->data[b_fid - 1] = TRUE;
      lvid1 = -1;
      lvid2 = -5;
      lvid3 = 0;
      for (loop_ub = 0; loop_ub < 4; loop_ub++) {
        if (tets->data[(b_fid + tets->size[0] * loop_ub) - 1] == faces->data
            [*fid - 1]) {
          lvid1 = loop_ub;
        }

        if (tets->data[(b_fid + tets->size[0] * loop_ub) - 1] == faces->data
            [(*fid + faces->size[0]) - 1]) {
          lvid2 = loop_ub - 4;
        }

        if (tets->data[(b_fid + tets->size[0] * loop_ub) - 1] == faces->data
            [(*fid + (faces->size[0] << 1)) - 1]) {
          lvid3 = loop_ub + 1;
        }
      }

      if ((lvid1 + 1 != 0) && (lvid2 + 5 != 0) && (lvid3 != 0)) {
        found = TRUE;
        if (1 > size_stack) {
          size_stack = 0;
        }

        ngb = r0->size[0];
        r0->size[0] = size_stack;
        emxEnsureCapacity((emxArray__common *)r0, ngb, (int32_T)sizeof(int32_T));
        loop_ub = size_stack - 1;
        for (ngb = 0; ngb <= loop_ub; ngb++) {
          r0->data[ngb] = 1 + ngb;
        }

        loop_ub = r0->size[0];
        loop_ub--;
        for (ngb = 0; ngb <= loop_ub; ngb++) {
          b_etags->data[stack[ngb] - 1] = FALSE;
        }

        exitg1 = TRUE;
      } else {
        for (loop_ub = 0; loop_ub < 3; loop_ub++) {
          ngb = (int32_T)((uint32_T)sibhfs->data[(b_fid + sibhfs->size[0] *
            (sibhfs_tet[lvid1 + (loop_ub << 2)] - 1)) - 1] >> 3U);
          if ((ngb != 0) && (!b_etags->data[ngb - 1])) {
            size_stack++;
            stack[size_stack - 1] = ngb;
          }
        }
      }
    }

    emxFree_int32_T(&r0);
  }

  ngb = etags->size[0];
  etags->size[0] = b_etags->size[0];
  emxEnsureCapacity((emxArray__common *)etags, ngb, (int32_T)sizeof(boolean_T));
  loop_ub = b_etags->size[0] - 1;
  for (ngb = 0; ngb <= loop_ub; ngb++) {
    etags->data[ngb] = b_etags->data[ngb];
  }

  for (loop_ub = 0; loop_ub <= b_etags->size[0] - 1; loop_ub++) {
    etags->data[(int32_T)(1.0 + (real_T)loop_ub) - 1] = FALSE;
  }

  emxFree_boolean_T(&b_etags);
  if (found) {
    *fid = b_fid;
    lfid = iv0[(lvid1 + lvid2) + lvid3];
  } else {
    *fid = 0;
    lfid = 0;
  }

  return lfid;
}

void f2hf_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void f2hf_terminate(void)
{
}

int32_T f2hf_usestruct(int32_T *fid, const emxArray_int32_T *faces, const
  emxArray_int32_T *tets, const struct_T sibhfs, const struct_T v2hf,
  emxArray_boolean_T *etags, boolean_T usestruct)
{
  int32_T lfid;
  boolean_T found;
  int32_T b_fid;
  int32_T lvid1;
  int32_T lvid2;
  int32_T lvid3;
  int32_T stack[50];
  int32_T size_stack;
  emxArray_int32_T *b_stack;
  emxArray_int32_T *r1;
  boolean_T exitg1;
  int32_T ii;
  int32_T loop_ub;
  static const int8_T sibhfs_tet[12] = { 1, 1, 1, 2, 2, 2, 3, 3, 4, 3, 4, 4 };

  emxArray_boolean_T *b_etags;
  static const int8_T iv1[4] = { 1, 2, 4, 3 };

  found = FALSE;
  b_fid = v2hf.cid->data[faces->data[*fid - 1] - 1] - 1;
  lvid1 = -1;
  lvid2 = 0;
  lvid3 = -5;
  if (!(v2hf.cid->data[faces->data[*fid - 1] - 1] != 0)) {
  } else {
    size_stack = 1;
    stack[0] = v2hf.cid->data[faces->data[*fid - 1] - 1];
    emxInit_int32_T(&b_stack, 1);
    emxInit_int32_T(&r1, 1);
    exitg1 = FALSE;
    while ((exitg1 == 0U) && (size_stack > 0)) {
      b_fid = stack[size_stack - 1] - 1;
      size_stack--;
      etags->data[b_fid] = TRUE;
      lvid1 = -1;
      lvid2 = 0;
      lvid3 = -5;
      for (ii = 0; ii < 4; ii++) {
        if (tets->data[b_fid + tets->size[0] * ii] == faces->data[*fid - 1]) {
          lvid1 = ii;
        }

        if (tets->data[b_fid + tets->size[0] * ii] == faces->data[(*fid +
             faces->size[0]) - 1]) {
          lvid2 = ii + 1;
        }

        if (tets->data[b_fid + tets->size[0] * ii] == faces->data[(*fid +
             (faces->size[0] << 1)) - 1]) {
          lvid3 = ii - 4;
        }
      }

      if ((lvid1 + 1 != 0) && (lvid2 != 0) && (lvid3 + 5 != 0)) {
        found = TRUE;
        if (1 > size_stack) {
          size_stack = 0;
        }

        ii = b_stack->size[0];
        b_stack->size[0] = size_stack;
        emxEnsureCapacity((emxArray__common *)b_stack, ii, (int32_T)sizeof
                          (int32_T));
        loop_ub = size_stack - 1;
        for (ii = 0; ii <= loop_ub; ii++) {
          b_stack->data[ii] = stack[ii] - 1;
        }

        ii = r1->size[0];
        r1->size[0] = size_stack;
        emxEnsureCapacity((emxArray__common *)r1, ii, (int32_T)sizeof(int32_T));
        loop_ub = size_stack - 1;
        for (ii = 0; ii <= loop_ub; ii++) {
          r1->data[ii] = 1 + ii;
        }

        ii = r1->size[0];
        loop_ub = ii - 1;
        for (ii = 0; ii <= loop_ub; ii++) {
          etags->data[b_stack->data[ii]] = FALSE;
        }

        exitg1 = TRUE;
      } else {
        for (ii = 0; ii < 3; ii++) {
          if ((sibhfs.cid->data[b_fid + sibhfs.cid->size[0] * (sibhfs_tet[lvid1
                + (ii << 2)] - 1)] != 0) && (!etags->data[sibhfs.cid->data[b_fid
               + sibhfs.cid->size[0] * (sibhfs_tet[lvid1 + (ii << 2)] - 1)] - 1]))
          {
            size_stack++;
            stack[size_stack - 1] = sibhfs.cid->data[b_fid + sibhfs.cid->size[0]
              * (sibhfs_tet[lvid1 + (ii << 2)] - 1)];
          }
        }
      }
    }

    emxFree_int32_T(&r1);
    emxFree_int32_T(&b_stack);
  }

  emxInit_boolean_T(&b_etags, 1);
  ii = b_etags->size[0];
  b_etags->size[0] = etags->size[0];
  emxEnsureCapacity((emxArray__common *)b_etags, ii, (int32_T)sizeof(boolean_T));
  loop_ub = etags->size[0] - 1;
  for (ii = 0; ii <= loop_ub; ii++) {
    b_etags->data[ii] = etags->data[ii];
  }

  for (ii = 0; ii <= etags->size[0] - 1; ii++) {
    b_etags->data[(int32_T)(1.0 + (real_T)ii) - 1] = FALSE;
  }

  if (found) {
    lfid = iv1[(lvid1 + lvid2) + lvid3];
  } else {
    b_fid = -1;
    lfid = 0;
  }

  *fid = b_fid + 1;
  ii = etags->size[0];
  etags->size[0] = b_etags->size[0];
  emxEnsureCapacity((emxArray__common *)etags, ii, (int32_T)sizeof(boolean_T));
  loop_ub = b_etags->size[0] - 1;
  for (ii = 0; ii <= loop_ub; ii++) {
    etags->data[ii] = b_etags->data[ii];
  }

  emxFree_boolean_T(&b_etags);
  return lfid;
}

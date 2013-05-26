#include "rt_nonfinite.h"
#include "obtain_neighbor_tets.h"
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

#ifndef struct_emxArray_boolean_T
#define struct_emxArray_boolean_T

typedef struct emxArray_boolean_T
{
  boolean_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray_boolean_T;

#endif

static define_emxInit(b_emxInit_real_T, real_T)
static define_emxInit(c_emxInit_real_T, real_T)
static void eml_null_assignment(emxArray_real_T *x, const emxArray_real_T *idx);
static define_emxFree(emxFree_boolean_T, boolean_T)
static define_emxInit(emxInit_boolean_T, boolean_T)
static real_T rt_roundd_snf(real_T u);

static void eml_null_assignment(emxArray_real_T *x, const emxArray_real_T *idx)
{
  int32_T nxin;
  int32_T nxout;
  int32_T k;
  emxArray_real_T *b_x;
  int32_T k0;
  int32_T nb;
  emxArray_boolean_T *b;
  nxin = x->size[0];
  if (idx->size[1] == 1) {
    nxout = nxin - 1;
    for (k = (int32_T)rt_roundd_snf(idx->data[0]); k <= nxout; k++) {
      x->data[k - 1] = x->data[k];
    }

    if (x->size[0] != 1) {
      if (1 > nxout) {
        nxout = 0;
      }

      emxInit_real_T(&b_x, 1);
      k0 = b_x->size[0];
      b_x->size[0] = nxout;
      emxEnsureCapacity((emxArray__common *)b_x, k0, (int32_T)sizeof(real_T));
      nb = nxout - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        b_x->data[k0] = x->data[k0];
      }

      k0 = x->size[0];
      x->size[0] = b_x->size[0];
      emxEnsureCapacity((emxArray__common *)x, k0, (int32_T)sizeof(real_T));
      nb = b_x->size[0] - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        x->data[k0] = b_x->data[k0];
      }

      emxFree_real_T(&b_x);
    } else {
      if (1 > nxout) {
        nxout = 0;
      }

      emxInit_real_T(&b_x, 1);
      k0 = b_x->size[0];
      b_x->size[0] = nxout;
      emxEnsureCapacity((emxArray__common *)b_x, k0, (int32_T)sizeof(real_T));
      nb = nxout - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        b_x->data[k0] = x->data[k0];
      }

      k0 = x->size[0];
      x->size[0] = b_x->size[0];
      emxEnsureCapacity((emxArray__common *)x, k0, (int32_T)sizeof(real_T));
      nb = b_x->size[0] - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        x->data[k0] = b_x->data[k0];
      }

      emxFree_real_T(&b_x);
    }
  } else {
    emxInit_boolean_T(&b, 2);
    k0 = b->size[0] * b->size[1];
    b->size[0] = 1;
    b->size[1] = nxin;
    emxEnsureCapacity((emxArray__common *)b, k0, (int32_T)sizeof(boolean_T));
    nb = nxin - 1;
    for (k0 = 0; k0 <= nb; k0++) {
      b->data[k0] = FALSE;
    }

    for (k = 1; k <= idx->size[1]; k++) {
      b->data[(int32_T)idx->data[k - 1] - 1] = TRUE;
    }

    nb = 0;
    for (k = 1; k <= b->size[1]; k++) {
      k0 = (int32_T)b->data[k - 1];
      nb += k0;
    }

    nxout = nxin - nb;
    nb = b->size[1];
    k0 = -1;
    for (k = 1; k <= nxin; k++) {
      if ((k > nb) || (!b->data[k - 1])) {
        k0++;
        x->data[k0] = x->data[k - 1];
      }
    }

    emxFree_boolean_T(&b);
    if (x->size[0] != 1) {
      if (1 > nxout) {
        nxout = 0;
      }

      emxInit_real_T(&b_x, 1);
      k0 = b_x->size[0];
      b_x->size[0] = nxout;
      emxEnsureCapacity((emxArray__common *)b_x, k0, (int32_T)sizeof(real_T));
      nb = nxout - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        b_x->data[k0] = x->data[k0];
      }

      k0 = x->size[0];
      x->size[0] = b_x->size[0];
      emxEnsureCapacity((emxArray__common *)x, k0, (int32_T)sizeof(real_T));
      nb = b_x->size[0] - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        x->data[k0] = b_x->data[k0];
      }

      emxFree_real_T(&b_x);
    } else {
      if (1 > nxout) {
        nxout = 0;
      }

      emxInit_real_T(&b_x, 1);
      k0 = b_x->size[0];
      b_x->size[0] = nxout;
      emxEnsureCapacity((emxArray__common *)b_x, k0, (int32_T)sizeof(real_T));
      nb = nxout - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        b_x->data[k0] = x->data[k0];
      }

      k0 = x->size[0];
      x->size[0] = b_x->size[0];
      emxEnsureCapacity((emxArray__common *)x, k0, (int32_T)sizeof(real_T));
      nb = b_x->size[0] - 1;
      for (k0 = 0; k0 <= nb; k0++) {
        x->data[k0] = b_x->data[k0];
      }

      emxFree_real_T(&b_x);
    }
  }
}

static real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

void obtain_neighbor_tets(int32_T cid, const emxArray_int32_T *sibhfs,
  emxArray_real_T *ngbtets)
{
  int32_T n_ngbtets;
  int32_T i0;
  int32_T lfid;
  emxArray_real_T *r0;
  emxArray_real_T *b_n_ngbtets;
  emxArray_real_T *r1;
  real_T loop_ub;
  n_ngbtets = -1;
  i0 = ngbtets->size[0];
  ngbtets->size[0] = 4;
  emxEnsureCapacity((emxArray__common *)ngbtets, i0, (int32_T)sizeof(real_T));
  for (i0 = 0; i0 < 4; i0++) {
    ngbtets->data[i0] = 0.0;
  }

  for (lfid = 0; lfid < 4; lfid++) {
    if (sibhfs->data[(cid + sibhfs->size[0] * lfid) - 1] != 0) {
      n_ngbtets++;
      ngbtets->data[n_ngbtets] = (real_T)((uint32_T)sibhfs->data[(cid +
        sibhfs->size[0] * lfid) - 1] >> 3U);
    }
  }

  emxInit_real_T(&r0, 1);
  i0 = r0->size[0];
  r0->size[0] = ngbtets->size[0];
  emxEnsureCapacity((emxArray__common *)r0, i0, (int32_T)sizeof(real_T));
  lfid = ngbtets->size[0] - 1;
  for (i0 = 0; i0 <= lfid; i0++) {
    r0->data[i0] = ngbtets->data[i0];
  }

  b_emxInit_real_T(&b_n_ngbtets, 2);
  emxInit_real_T(&r1, 1);
  i0 = r1->size[0];
  r1->size[0] = (int32_T)(4.0 - ((real_T)(n_ngbtets + 1) + 1.0)) + 1;
  emxEnsureCapacity((emxArray__common *)r1, i0, (int32_T)sizeof(real_T));
  loop_ub = 4.0 - ((real_T)(n_ngbtets + 1) + 1.0);
  for (i0 = 0; i0 <= (int32_T)loop_ub; i0++) {
    r1->data[i0] = ((real_T)(n_ngbtets + 1) + 1.0) + (real_T)i0;
  }

  i0 = b_n_ngbtets->size[0] * b_n_ngbtets->size[1];
  b_n_ngbtets->size[0] = 1;
  emxEnsureCapacity((emxArray__common *)b_n_ngbtets, i0, (int32_T)sizeof(real_T));
  lfid = r1->size[0];
  i0 = b_n_ngbtets->size[0] * b_n_ngbtets->size[1];
  b_n_ngbtets->size[1] = lfid;
  emxEnsureCapacity((emxArray__common *)b_n_ngbtets, i0, (int32_T)sizeof(real_T));
  lfid = r1->size[0] - 1;
  for (i0 = 0; i0 <= lfid; i0++) {
    b_n_ngbtets->data[i0] = r1->data[i0];
  }

  emxFree_real_T(&r1);
  eml_null_assignment(r0, b_n_ngbtets);
  i0 = ngbtets->size[0];
  ngbtets->size[0] = r0->size[0];
  emxEnsureCapacity((emxArray__common *)ngbtets, i0, (int32_T)sizeof(real_T));
  emxFree_real_T(&b_n_ngbtets);
  lfid = r0->size[0] - 1;
  for (i0 = 0; i0 <= lfid; i0++) {
    ngbtets->data[i0] = r0->data[i0];
  }

  emxFree_real_T(&r0);
}

void obtain_neighbor_tets_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void obtain_neighbor_tets_terminate(void)
{
}

void obtain_neighbor_tets_usestruct(int32_T cid, const struct_T sibhfs,
  boolean_T usestruct, emxArray_real_T *ngbtets)
{
  emxArray_real_T *b_ngbtets;
  int32_T n_ngbtets;
  int32_T i1;
  int32_T lfid;
  emxArray_real_T *b_n_ngbtets;
  emxArray_real_T *r2;
  real_T loop_ub;
  emxInit_real_T(&b_ngbtets, 1);
  n_ngbtets = -1;
  i1 = b_ngbtets->size[0];
  b_ngbtets->size[0] = 4;
  emxEnsureCapacity((emxArray__common *)b_ngbtets, i1, (int32_T)sizeof(real_T));
  for (i1 = 0; i1 < 4; i1++) {
    b_ngbtets->data[i1] = 0.0;
  }

  for (lfid = 0; lfid < 4; lfid++) {
    if (sibhfs.cid->data[(cid + sibhfs.cid->size[0] * lfid) - 1] != 0) {
      n_ngbtets++;
      b_ngbtets->data[n_ngbtets] = (real_T)sibhfs.cid->data[(cid +
        sibhfs.cid->size[0] * lfid) - 1];
    }
  }

  i1 = ngbtets->size[0];
  ngbtets->size[0] = b_ngbtets->size[0];
  emxEnsureCapacity((emxArray__common *)ngbtets, i1, (int32_T)sizeof(real_T));
  lfid = b_ngbtets->size[0] - 1;
  for (i1 = 0; i1 <= lfid; i1++) {
    ngbtets->data[i1] = b_ngbtets->data[i1];
  }

  emxFree_real_T(&b_ngbtets);
  b_emxInit_real_T(&b_n_ngbtets, 2);
  emxInit_real_T(&r2, 1);
  i1 = r2->size[0];
  r2->size[0] = (int32_T)(4.0 - ((real_T)(n_ngbtets + 1) + 1.0)) + 1;
  emxEnsureCapacity((emxArray__common *)r2, i1, (int32_T)sizeof(real_T));
  loop_ub = 4.0 - ((real_T)(n_ngbtets + 1) + 1.0);
  for (i1 = 0; i1 <= (int32_T)loop_ub; i1++) {
    r2->data[i1] = ((real_T)(n_ngbtets + 1) + 1.0) + (real_T)i1;
  }

  i1 = b_n_ngbtets->size[0] * b_n_ngbtets->size[1];
  b_n_ngbtets->size[0] = 1;
  emxEnsureCapacity((emxArray__common *)b_n_ngbtets, i1, (int32_T)sizeof(real_T));
  lfid = r2->size[0];
  i1 = b_n_ngbtets->size[0] * b_n_ngbtets->size[1];
  b_n_ngbtets->size[1] = lfid;
  emxEnsureCapacity((emxArray__common *)b_n_ngbtets, i1, (int32_T)sizeof(real_T));
  lfid = r2->size[0] - 1;
  for (i1 = 0; i1 <= lfid; i1++) {
    b_n_ngbtets->data[i1] = r2->data[i1];
  }

  emxFree_real_T(&r2);
  eml_null_assignment(ngbtets, b_n_ngbtets);
  i1 = ngbtets->size[0];
  ngbtets->size[0] = ngbtets->size[0];
  emxEnsureCapacity((emxArray__common *)ngbtets, i1, (int32_T)sizeof(real_T));
  emxFree_real_T(&b_n_ngbtets);
}

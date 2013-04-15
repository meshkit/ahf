#include "rt_nonfinite.h"
#include "determine_sibling_halfedges.h"
#include "stdio.h"
#define M2C_ADD(a,b)                   (a)+(b)
#ifdef BUILD_MEX

#include "mex.h"
#define malloc                         mxMalloc
#define calloc                         mxCalloc
#define realloc                        mxRealloc
#define free                           mxFree
#define emlrtIsMATLABThread(s)         1
#define M2C_CHK_OPAQUE_PTR(ptr,parent,offset) \
 if ((parent) && (ptr) != ((char*)mxGetData(parent))+(offset)) \
 mexErrMsgIdAndTxt("opaque_ptr:ParentObjectChanged", \
 "The parent mxArray has changed. Avoid changing a MATLAB variable when dereferenced by an opaque_ptr.");
#else
#define emlrtIsMATLABThread(s)         0
#define mexErrMsgIdAndTxt(a,b)
#define M2C_CHK_OPAQUE_PTR(ptr,parent,offset)
#endif

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

static void b_emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T
  numDimensions);
static void b_emxInit_int8_T(emxArray_int8_T **pEmxArray, int32_T numDimensions);
static void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel,
  int32_T elementSize);
static void emxFree_int32_T(emxArray_int32_T **pEmxArray);
static void emxFree_int8_T(emxArray_int8_T **pEmxArray);
static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions);
static void emxInit_int8_T(emxArray_int8_T **pEmxArray, int32_T numDimensions);
static void b_emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T
  numDimensions)
{
  emxArray_int32_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_int32_T *)malloc(sizeof(emxArray_int32_T));
  emxArray = *pEmxArray;
  emxArray->data = (int32_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int32_T *)malloc((uint32_T)(sizeof(int32_T) * numDimensions));
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = TRUE;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    emxArray->size[i] = 0;
  }
}

static void b_emxInit_int8_T(emxArray_int8_T **pEmxArray, int32_T numDimensions)
{
  emxArray_int8_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_int8_T *)malloc(sizeof(emxArray_int8_T));
  emxArray = *pEmxArray;
  emxArray->data = (int8_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int32_T *)malloc((uint32_T)(sizeof(int32_T) * numDimensions));
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = TRUE;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    emxArray->size[i] = 0;
  }
}

static void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel,
  int32_T elementSize)
{
  int32_T newNumel;
  int32_T loop_ub;
  int32_T i;
  void *newData;
  newNumel = 1;
  loop_ub = emxArray->numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    newNumel *= emxArray->size[i];
  }

  if (newNumel > emxArray->allocatedSize) {
    loop_ub = emxArray->allocatedSize;
    if (loop_ub < 16) {
      loop_ub = 16;
    }

    while (loop_ub < newNumel) {
      loop_ub <<= 1;
    }

    newData = calloc((uint32_T)loop_ub, (uint32_T)elementSize);
    if (emxArray->data != NULL) {
      memcpy(newData, emxArray->data, (uint32_T)(elementSize * oldNumel));
      if (emxArray->canFreeData) {
        free(emxArray->data);
      }
    }

    emxArray->data = newData;
    emxArray->allocatedSize = loop_ub;
    emxArray->canFreeData = TRUE;
  }
}

static void emxFree_int32_T(emxArray_int32_T **pEmxArray)
{
  if (*pEmxArray != (emxArray_int32_T *)NULL) {
    if ((*pEmxArray)->canFreeData) {
      free((void *)(*pEmxArray)->data);
    }

    free((void *)(*pEmxArray)->size);
    free((void *)*pEmxArray);
    *pEmxArray = (emxArray_int32_T *)NULL;
  }
}

static void emxFree_int8_T(emxArray_int8_T **pEmxArray)
{
  if (*pEmxArray != (emxArray_int8_T *)NULL) {
    if ((*pEmxArray)->canFreeData) {
      free((void *)(*pEmxArray)->data);
    }

    free((void *)(*pEmxArray)->size);
    free((void *)*pEmxArray);
    *pEmxArray = (emxArray_int8_T *)NULL;
  }
}

static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions)
{
  emxArray_int32_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_int32_T *)malloc(sizeof(emxArray_int32_T));
  emxArray = *pEmxArray;
  emxArray->data = (int32_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int32_T *)malloc((uint32_T)(sizeof(int32_T) * numDimensions));
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = TRUE;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    emxArray->size[i] = 0;
  }
}

static void emxInit_int8_T(emxArray_int8_T **pEmxArray, int32_T numDimensions)
{
  emxArray_int8_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_int8_T *)malloc(sizeof(emxArray_int8_T));
  emxArray = *pEmxArray;
  emxArray->data = (int8_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int32_T *)malloc((uint32_T)(sizeof(int32_T) * numDimensions));
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = TRUE;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    emxArray->size[i] = 0;
  }
}

void determine_sibling_halfedges(int32_T nv, const emxArray_int32_T *elems,
  emxArray_int32_T *sibhes, boolean_T *manifold, boolean_T *oriented)
{
  int32_T nvpE;
  int32_T nepE;
  emxArray_int32_T *is_index;
  int32_T i0;
  int32_T nelems;
  int32_T ii;
  boolean_T exitg1;
  boolean_T b0;
  int32_T k;
  emxArray_int32_T *v2nv;
  emxArray_int32_T *v2he_fid;
  emxArray_int8_T *v2he_leid;
  boolean_T hasthree;
  static const int8_T iv0[4] = { 2, 3, 4, 1 };

  int32_T prev_heid_leid;
  int32_T nhes;
  int32_T i1;
  int32_T b_index;
  nvpE = elems->size[1];
  if ((nvpE == 4) || (nvpE == 8) || (nvpE == 9)) {
    nepE = 4;
  } else {
    nepE = 3;
  }

  emxInit_int32_T(&is_index, 1);
  i0 = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, i0, (int32_T)sizeof(int32_T));
  for (i0 = 0; i0 <= nv; i0++) {
    is_index->data[i0] = 0;
  }

  nelems = elems->size[0];
  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= nelems)) {
    if (elems->data[ii] == 0) {
      nelems = ii;
      exitg1 = TRUE;
    } else {
      if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
        b0 = TRUE;
      } else {
        b0 = FALSE;
      }

      i0 = 4 - (int32_T)b0;
      for (nvpE = 1; nvpE <= i0; nvpE++) {
        k = elems->data[ii + elems->size[0] * (nvpE - 1)];
        is_index->data[k]++;
      }

      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2nv, 1);
  emxInit_int32_T(&v2he_fid, 1);
  emxInit_int8_T(&v2he_leid, 1);
  nvpE = nelems * nepE;
  i0 = v2nv->size[0];
  v2nv->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2nv, i0, (int32_T)sizeof(int32_T));
  i0 = v2he_fid->size[0];
  v2he_fid->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2he_fid, i0, (int32_T)sizeof(int32_T));
  i0 = v2he_leid->size[0];
  v2he_leid->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2he_leid, i0, (int32_T)sizeof(int8_T));
  for (ii = 0; ii + 1 <= nelems; ii++) {
    if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
      hasthree = TRUE;
    } else {
      hasthree = FALSE;
    }

    i0 = 4 - (int32_T)hasthree;
    for (nvpE = 0; nvpE + 1 <= i0; nvpE++) {
      v2nv->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1] - 1]
        = elems->data[ii + elems->size[0] * (iv0[nvpE + (hasthree && (nvpE + 1 ==
        3))] - 1)];
      v2he_fid->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]
        - 1] = ii + 1;
      v2he_leid->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]
        - 1] = (int8_T)(nvpE + 1);
      is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]++;
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;
  i0 = sibhes->size[0] * sibhes->size[1];
  sibhes->size[0] = nelems;
  sibhes->size[1] = nepE;
  emxEnsureCapacity((emxArray__common *)sibhes, i0, (int32_T)sizeof(int32_T));
  nvpE = nelems * nepE - 1;
  for (i0 = 0; i0 <= nvpE; i0++) {
    sibhes->data[i0] = 0;
  }

  *manifold = TRUE;
  *oriented = TRUE;
  for (ii = 0; ii + 1 <= nelems; ii++) {
    if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
      hasthree = TRUE;
    } else {
      hasthree = FALSE;
    }

    i0 = 4 - (int32_T)hasthree;
    for (nvpE = 0; nvpE + 1 <= i0; nvpE++) {
      b0 = (nvpE + 1 == 3);
      if (elems->data[ii + elems->size[0] * (iv0[nvpE + (hasthree && b0)] - 1)] <
          elems->data[ii + elems->size[0] * nvpE]) {
      } else {
        k = ii;
        prev_heid_leid = nvpE;
        nhes = 0;
        i1 = is_index->data[elems->data[ii + elems->size[0] * (iv0[nvpE +
          (hasthree && b0)] - 1)]] - 1;
        for (b_index = is_index->data[elems->data[ii + elems->size[0] *
             (iv0[nvpE + (hasthree && (nvpE + 1 == 3))] - 1)] - 1] - 1; b_index
             + 1 <= i1; b_index++) {
          if (v2nv->data[b_index] == elems->data[ii + elems->size[0] * nvpE]) {
            sibhes->data[k + sibhes->size[0] * prev_heid_leid] =
              ((v2he_fid->data[b_index] << 2) + v2he_leid->data[b_index]) - 1;
            k = v2he_fid->data[b_index] - 1;
            prev_heid_leid = v2he_leid->data[b_index] - 1;
            nhes++;
          }
        }

        i1 = is_index->data[elems->data[ii + elems->size[0] * nvpE]] - 1;
        for (b_index = is_index->data[elems->data[ii + elems->size[0] * nvpE] -
             1] - 1; b_index + 1 <= i1; b_index++) {
          if ((v2nv->data[b_index] == elems->data[ii + elems->size[0] *
               (iv0[nvpE + (hasthree && b0)] - 1)]) && (v2he_fid->data[b_index]
               != ii + 1)) {
            sibhes->data[k + sibhes->size[0] * prev_heid_leid] =
              ((v2he_fid->data[b_index] << 2) + v2he_leid->data[b_index]) - 1;
            k = v2he_fid->data[b_index] - 1;
            prev_heid_leid = v2he_leid->data[b_index] - 1;
            nhes++;
            *oriented = FALSE;
          }
        }

        if ((k + 1 != ii + 1) && (prev_heid_leid + 1 != nvpE + 1)) {
          sibhes->data[k + sibhes->size[0] * prev_heid_leid] = ((ii + 1) << 2) +
            nvpE;
          nhes++;
        }

        if ((*manifold) && (nhes > 2)) {
          *manifold = FALSE;
          *oriented = FALSE;
        }
      }
    }
  }

  emxFree_int8_T(&v2he_leid);
  emxFree_int32_T(&v2he_fid);
  emxFree_int32_T(&v2nv);
  emxFree_int32_T(&is_index);
}

void determine_sibling_halfedges_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void determine_sibling_halfedges_terminate(void)
{
}

void determine_sibling_halfedges_usestruct(int32_T nv, const emxArray_int32_T
  *elems, boolean_T usestruct, struct_T *sibhes, boolean_T *manifold, boolean_T *
  oriented)
{
  int32_T nvpE;
  int32_T nepE;
  emxArray_int32_T *is_index;
  int32_T i2;
  int32_T nelems;
  int32_T ii;
  boolean_T exitg1;
  boolean_T b1;
  int32_T k;
  emxArray_int32_T *v2nv;
  emxArray_int32_T *v2he_fid;
  emxArray_int8_T *v2he_leid;
  boolean_T hasthree;
  static const int8_T iv1[4] = { 2, 3, 4, 1 };

  uint32_T uv0[2];
  uint32_T uv1[2];
  boolean_T b_manifold;
  boolean_T b_oriented;
  int32_T prev_heid_leid;
  int32_T nhes;
  int32_T i3;
  int32_T b_index;
  nvpE = elems->size[1];
  if ((nvpE == 4) || (nvpE == 8) || (nvpE == 9)) {
    nepE = 4;
  } else {
    nepE = 3;
  }

  emxInit_int32_T(&is_index, 1);
  i2 = is_index->size[0];
  is_index->size[0] = nv + 1;
  emxEnsureCapacity((emxArray__common *)is_index, i2, (int32_T)sizeof(int32_T));
  for (i2 = 0; i2 <= nv; i2++) {
    is_index->data[i2] = 0;
  }

  nelems = elems->size[0];
  ii = 0;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii + 1 <= nelems)) {
    if (elems->data[ii] == 0) {
      nelems = ii;
      exitg1 = TRUE;
    } else {
      if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
        b1 = TRUE;
      } else {
        b1 = FALSE;
      }

      i2 = 4 - (int32_T)b1;
      for (nvpE = 1; nvpE <= i2; nvpE++) {
        k = elems->data[ii + elems->size[0] * (nvpE - 1)];
        is_index->data[k]++;
      }

      ii++;
    }
  }

  is_index->data[0] = 1;
  for (ii = 1; ii <= nv; ii++) {
    is_index->data[ii] += is_index->data[ii - 1];
  }

  emxInit_int32_T(&v2nv, 1);
  emxInit_int32_T(&v2he_fid, 1);
  emxInit_int8_T(&v2he_leid, 1);
  nvpE = nelems * nepE;
  i2 = v2nv->size[0];
  v2nv->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2nv, i2, (int32_T)sizeof(int32_T));
  i2 = v2he_fid->size[0];
  v2he_fid->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2he_fid, i2, (int32_T)sizeof(int32_T));
  i2 = v2he_leid->size[0];
  v2he_leid->size[0] = nvpE;
  emxEnsureCapacity((emxArray__common *)v2he_leid, i2, (int32_T)sizeof(int8_T));
  for (ii = 0; ii + 1 <= nelems; ii++) {
    if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
      hasthree = TRUE;
    } else {
      hasthree = FALSE;
    }

    i2 = 4 - (int32_T)hasthree;
    for (nvpE = 0; nvpE + 1 <= i2; nvpE++) {
      v2nv->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1] - 1]
        = elems->data[ii + elems->size[0] * (iv1[nvpE + (hasthree && (nvpE + 1 ==
        3))] - 1)];
      v2he_fid->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]
        - 1] = ii + 1;
      v2he_leid->data[is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]
        - 1] = (int8_T)(nvpE + 1);
      is_index->data[elems->data[ii + elems->size[0] * nvpE] - 1]++;
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;
  for (i2 = 0; i2 < 2; i2++) {
    uv0[i2] = (uint32_T)elems->size[i2];
  }

  for (i2 = 0; i2 < 2; i2++) {
    uv1[i2] = (uint32_T)elems->size[i2];
  }

  i2 = sibhes->fid->size[0] * sibhes->fid->size[1];
  sibhes->fid->size[0] = (int32_T)uv0[0];
  emxEnsureCapacity((emxArray__common *)sibhes->fid, i2, (int32_T)sizeof(int32_T));
  i2 = sibhes->fid->size[0] * sibhes->fid->size[1];
  sibhes->fid->size[1] = (int32_T)uv0[1];
  emxEnsureCapacity((emxArray__common *)sibhes->fid, i2, (int32_T)sizeof(int32_T));
  nvpE = (int32_T)uv0[0] * (int32_T)uv0[1] - 1;
  for (i2 = 0; i2 <= nvpE; i2++) {
    sibhes->fid->data[i2] = 0;
  }

  i2 = sibhes->leid->size[0] * sibhes->leid->size[1];
  sibhes->leid->size[0] = (int32_T)uv1[0];
  emxEnsureCapacity((emxArray__common *)sibhes->leid, i2, (int32_T)sizeof(int8_T));
  i2 = sibhes->leid->size[0] * sibhes->leid->size[1];
  sibhes->leid->size[1] = (int32_T)uv1[1];
  emxEnsureCapacity((emxArray__common *)sibhes->leid, i2, (int32_T)sizeof(int8_T));
  nvpE = (int32_T)uv1[0] * (int32_T)uv1[1] - 1;
  for (i2 = 0; i2 <= nvpE; i2++) {
    sibhes->leid->data[i2] = 0;
  }

  b_manifold = TRUE;
  b_oriented = TRUE;
  for (ii = 0; ii + 1 <= nelems; ii++) {
    if ((nepE != 4) || (!(elems->data[ii + elems->size[0] * 3] != 0))) {
      hasthree = TRUE;
    } else {
      hasthree = FALSE;
    }

    i2 = 4 - (int32_T)hasthree;
    for (nvpE = 0; nvpE + 1 <= i2; nvpE++) {
      b1 = (nvpE + 1 == 3);
      if (elems->data[ii + elems->size[0] * (iv1[nvpE + (hasthree && b1)] - 1)] <
          elems->data[ii + elems->size[0] * nvpE]) {
      } else {
        k = ii;
        prev_heid_leid = nvpE;
        nhes = 0;
        i3 = is_index->data[elems->data[ii + elems->size[0] * (iv1[nvpE +
          (hasthree && b1)] - 1)]] - 1;
        for (b_index = is_index->data[elems->data[ii + elems->size[0] *
             (iv1[nvpE + (hasthree && (nvpE + 1 == 3))] - 1)] - 1] - 1; b_index
             + 1 <= i3; b_index++) {
          if (v2nv->data[b_index] == elems->data[ii + elems->size[0] * nvpE]) {
            sibhes->fid->data[k + sibhes->fid->size[0] * prev_heid_leid] =
              v2he_fid->data[b_index];
            sibhes->leid->data[k + sibhes->leid->size[0] * prev_heid_leid] =
              v2he_leid->data[b_index];
            k = v2he_fid->data[b_index] - 1;
            prev_heid_leid = v2he_leid->data[b_index] - 1;
            nhes++;
          }
        }

        i3 = is_index->data[elems->data[ii + elems->size[0] * nvpE]] - 1;
        for (b_index = is_index->data[elems->data[ii + elems->size[0] * nvpE] -
             1] - 1; b_index + 1 <= i3; b_index++) {
          if ((v2nv->data[b_index] == elems->data[ii + elems->size[0] *
               (iv1[nvpE + (hasthree && b1)] - 1)]) && (v2he_fid->data[b_index]
               != ii + 1)) {
            sibhes->fid->data[k + sibhes->fid->size[0] * prev_heid_leid] =
              v2he_fid->data[b_index];
            sibhes->leid->data[k + sibhes->leid->size[0] * prev_heid_leid] =
              v2he_leid->data[b_index];
            k = v2he_fid->data[b_index] - 1;
            prev_heid_leid = v2he_leid->data[b_index] - 1;
            nhes++;
            b_oriented = FALSE;
          }
        }

        if ((k + 1 != ii + 1) && (prev_heid_leid + 1 != nvpE + 1)) {
          sibhes->fid->data[k + sibhes->fid->size[0] * prev_heid_leid] = ii + 1;
          sibhes->leid->data[k + sibhes->leid->size[0] * prev_heid_leid] =
            (int8_T)(nvpE + 1);
          nhes++;
        }

        if (b_manifold && (nhes > 2)) {
          b_manifold = FALSE;
          b_oriented = FALSE;
        }
      }
    }
  }

  emxFree_int8_T(&v2he_leid);
  emxFree_int32_T(&v2he_fid);
  emxFree_int32_T(&v2nv);
  emxFree_int32_T(&is_index);
  *manifold = b_manifold;
  *oriented = b_oriented;
}

emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size)
{
  emxArray_int32_T *emx;
  int32_T numEl;
  int32_T loop_ub;
  int32_T i;
  b_emxInit_int32_T(&emx, numDimensions);
  numEl = 1;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = (int32_T *)calloc((uint32_T)numEl, sizeof(int32_T));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

emxArray_int8_T *emxCreateND_int8_T(int32_T numDimensions, int32_T *size)
{
  emxArray_int8_T *emx;
  int32_T numEl;
  int32_T loop_ub;
  int32_T i;
  b_emxInit_int8_T(&emx, numDimensions);
  numEl = 1;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = (int8_T *)calloc((uint32_T)numEl, sizeof(int8_T));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T
  numDimensions, int32_T *size)
{
  emxArray_int32_T *emx;
  int32_T numEl;
  int32_T loop_ub;
  int32_T i;
  b_emxInit_int32_T(&emx, numDimensions);
  numEl = 1;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = data;
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  emx->canFreeData = FALSE;
  return emx;
}

emxArray_int8_T *emxCreateWrapperND_int8_T(int8_T *data, int32_T numDimensions,
  int32_T *size)
{
  emxArray_int8_T *emx;
  int32_T numEl;
  int32_T loop_ub;
  int32_T i;
  b_emxInit_int8_T(&emx, numDimensions);
  numEl = 1;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = data;
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  emx->canFreeData = FALSE;
  return emx;
}

emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T
  cols)
{
  emxArray_int32_T *emx;
  int32_T size[2];
  int32_T numEl;
  int32_T i;
  size[0] = rows;
  size[1] = cols;
  b_emxInit_int32_T(&emx, 2);
  numEl = 1;
  for (i = 0; i < 2; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  emx->canFreeData = FALSE;
  return emx;
}

emxArray_int8_T *emxCreateWrapper_int8_T(int8_T *data, int32_T rows, int32_T
  cols)
{
  emxArray_int8_T *emx;
  int32_T size[2];
  int32_T numEl;
  int32_T i;
  size[0] = rows;
  size[1] = cols;
  b_emxInit_int8_T(&emx, 2);
  numEl = 1;
  for (i = 0; i < 2; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  emx->canFreeData = FALSE;
  return emx;
}

emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols)
{
  emxArray_int32_T *emx;
  int32_T size[2];
  int32_T numEl;
  int32_T i;
  size[0] = rows;
  size[1] = cols;
  b_emxInit_int32_T(&emx, 2);
  numEl = 1;
  for (i = 0; i < 2; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = (int32_T *)calloc((uint32_T)numEl, sizeof(int32_T));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

emxArray_int8_T *emxCreate_int8_T(int32_T rows, int32_T cols)
{
  emxArray_int8_T *emx;
  int32_T size[2];
  int32_T numEl;
  int32_T i;
  size[0] = rows;
  size[1] = cols;
  b_emxInit_int8_T(&emx, 2);
  numEl = 1;
  for (i = 0; i < 2; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }

  emx->data = (int8_T *)calloc((uint32_T)numEl, sizeof(int8_T));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

void emxDestroyArray_int32_T(emxArray_int32_T *emxArray)
{
  emxFree_int32_T(&emxArray);
}

void emxDestroyArray_int8_T(emxArray_int8_T *emxArray)
{
  emxFree_int8_T(&emxArray);
}

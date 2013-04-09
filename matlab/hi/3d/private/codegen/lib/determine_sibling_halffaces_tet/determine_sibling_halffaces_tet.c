#include "rt_nonfinite.h"
#include "determine_sibling_halffaces_tet.h"
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

#ifndef struct_emxArray_int8_T
#define struct_emxArray_int8_T

typedef struct emxArray_int8_T
{
  int8_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray_int8_T;

#endif

static void b_emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T
  numDimensions);
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

void determine_sibling_halffaces_tet(int32_T nv, const emxArray_int32_T *elems,
  const emxArray_int32_T *varargin_1, emxArray_int32_T *sibhfs, boolean_T
  *manifold, boolean_T *oriented)
{
  emxArray_int32_T *is_index;
  int32_T i0;
  int32_T nelems;
  int32_T ii;
  boolean_T exitg1;
  int32_T jj;
  static const int8_T hf_tet[12] = { 1, 1, 2, 3, 3, 2, 3, 1, 2, 4, 4, 4 };

  int32_T mtmp;
  int32_T nf;
  emxArray_int32_T *v2hf_cid;
  emxArray_int8_T *v2hf_lfid;
  emxArray_int32_T *v2oe_v1;
  emxArray_int32_T *v2oe_v2;
  static const int8_T iv0[3] = { 2, 3, 1 };

  static const int8_T v2av_tet[12] = { 2, 1, 4, 3, 4, 3, 2, 1, 3, 4, 1, 2 };

  static const int8_T v2f_tet[12] = { 2, 1, 3, 4, 4, 3, 1, 2, 1, 2, 4, 3 };

  uint32_T uv0[2];
  int32_T itmp;
  int8_T prev_lfid;
  int32_T nhfs;
  int32_T b_index;
  static const int8_T iv1[3] = { 3, 1, 2 };

  emxInit_int32_T(&is_index, 1);
  *manifold = TRUE;
  *oriented = TRUE;
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
      for (jj = 0; jj < 4; jj++) {
        mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj] - 1)];
        for (nf = 0; nf < 2; nf++) {
          if (elems->data[ii + elems->size[0] * (hf_tet[jj + ((nf + 1) << 2)] -
               1)] > mtmp) {
            mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj + ((nf + 1) << 2)]
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

  emxInit_int32_T(&v2hf_cid, 1);
  emxInit_int8_T(&v2hf_lfid, 1);
  emxInit_int32_T(&v2oe_v1, 1);
  emxInit_int32_T(&v2oe_v2, 1);
  nf = nelems * 12;
  i0 = v2hf_cid->size[0];
  v2hf_cid->size[0] = nf;
  emxEnsureCapacity((emxArray__common *)v2hf_cid, i0, (int32_T)sizeof(int32_T));
  i0 = v2hf_lfid->size[0];
  v2hf_lfid->size[0] = nf;
  emxEnsureCapacity((emxArray__common *)v2hf_lfid, i0, (int32_T)sizeof(int8_T));
  i0 = v2oe_v1->size[0];
  v2oe_v1->size[0] = nf;
  emxEnsureCapacity((emxArray__common *)v2oe_v1, i0, (int32_T)sizeof(int32_T));
  i0 = v2oe_v2->size[0];
  v2oe_v2->size[0] = nf;
  emxEnsureCapacity((emxArray__common *)v2oe_v2, i0, (int32_T)sizeof(int32_T));
  for (ii = 0; ii + 1 <= nelems; ii++) {
    for (jj = 0; jj < 4; jj++) {
      for (nf = 0; nf < 3; nf++) {
        if ((elems->data[ii + elems->size[0] * jj] > elems->data[ii +
             elems->size[0] * (v2av_tet[jj + (nf << 2)] - 1)]) && (elems->
             data[ii + elems->size[0] * jj] > elems->data[ii + elems->size[0] *
             (v2av_tet[jj + ((iv0[nf] - 1) << 2)] - 1)])) {
          v2oe_v1->data[is_index->data[elems->data[ii + elems->size[0] * jj] - 1]
            - 1] = elems->data[ii + elems->size[0] * (v2av_tet[jj + (nf << 2)] -
            1)];
          v2oe_v2->data[is_index->data[elems->data[ii + elems->size[0] * jj] - 1]
            - 1] = elems->data[ii + elems->size[0] * (v2av_tet[jj + ((iv0[nf] -
            1) << 2)] - 1)];
          v2hf_cid->data[is_index->data[elems->data[ii + elems->size[0] * jj] -
            1] - 1] = ii + 1;
          v2hf_lfid->data[is_index->data[elems->data[ii + elems->size[0] * jj] -
            1] - 1] = v2f_tet[jj + (nf << 2)];
          is_index->data[elems->data[ii + elems->size[0] * jj] - 1]++;
        }
      }
    }
  }

  for (ii = nv - 1; ii > 0; ii--) {
    is_index->data[ii] = is_index->data[ii - 1];
  }

  is_index->data[0] = 1;
  for (i0 = 0; i0 < 2; i0++) {
    uv0[i0] = (uint32_T)elems->size[i0];
  }

  i0 = sibhfs->size[0] * sibhfs->size[1];
  sibhfs->size[0] = (int32_T)uv0[0];
  emxEnsureCapacity((emxArray__common *)sibhfs, i0, (int32_T)sizeof(int32_T));
  i0 = sibhfs->size[0] * sibhfs->size[1];
  sibhfs->size[1] = (int32_T)uv0[1];
  emxEnsureCapacity((emxArray__common *)sibhfs, i0, (int32_T)sizeof(int32_T));
  nf = (int32_T)uv0[0] * (int32_T)uv0[1] - 1;
  for (i0 = 0; i0 <= nf; i0++) {
    sibhfs->data[i0] = 0;
  }

  for (ii = 0; ii + 1 <= nelems; ii++) {
    for (jj = 0; jj < 4; jj++) {
      if (sibhfs->data[ii + sibhfs->size[0] * jj] != 0) {
      } else {
        mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj] - 1)];
        itmp = 0;
        for (nf = 0; nf < 2; nf++) {
          if (elems->data[ii + elems->size[0] * (hf_tet[jj + ((nf + 1) << 2)] -
               1)] > mtmp) {
            mtmp = elems->data[ii + elems->size[0] * (hf_tet[jj + ((nf + 1) << 2)]
              - 1)];
            itmp = nf + 1;
          }
        }

        nf = ii;
        prev_lfid = (int8_T)(jj + 1);
        nhfs = 0;
        i0 = is_index->data[mtmp] - 1;
        for (b_index = is_index->data[mtmp - 1] - 1; b_index + 1 <= i0; b_index
             ++) {
          if ((v2oe_v1->data[b_index] == elems->data[ii + elems->size[0] *
               (hf_tet[jj + ((iv1[itmp] - 1) << 2)] - 1)]) && (v2oe_v2->
               data[b_index] == elems->data[ii + elems->size[0] * (hf_tet[jj +
                ((iv0[itmp] - 1) << 2)] - 1)])) {
            sibhfs->data[nf + sibhfs->size[0] * (prev_lfid - 1)] =
              ((v2hf_cid->data[b_index] << 3) + v2hf_lfid->data[b_index]) - 1;
            nf = v2hf_cid->data[b_index] - 1;
            prev_lfid = v2hf_lfid->data[b_index];
            nhfs++;
          }
        }

        i0 = is_index->data[mtmp] - 1;
        for (b_index = is_index->data[mtmp - 1] - 1; b_index + 1 <= i0; b_index
             ++) {
          if ((v2oe_v1->data[b_index] == elems->data[ii + elems->size[0] *
               (hf_tet[jj + ((iv0[itmp] - 1) << 2)] - 1)]) && (v2oe_v2->
               data[b_index] == elems->data[ii + elems->size[0] * (hf_tet[jj +
                ((iv1[itmp] - 1) << 2)] - 1)]) && (v2hf_cid->data[b_index] != ii
               + 1)) {
            sibhfs->data[nf + sibhfs->size[0] * (prev_lfid - 1)] =
              ((v2hf_cid->data[b_index] << 3) + v2hf_lfid->data[b_index]) - 1;
            nf = v2hf_cid->data[b_index] - 1;
            prev_lfid = v2hf_lfid->data[b_index];
            nhfs++;
            *oriented = FALSE;
          }
        }

        if (nf + 1 != ii + 1) {
          sibhfs->data[nf + sibhfs->size[0] * (prev_lfid - 1)] = ((ii + 1) << 3)
            + jj;
          nhfs++;
        }

        if ((*manifold) && (nhfs > 2)) {
          *manifold = FALSE;
          *oriented = FALSE;
        }
      }
    }
  }

  emxFree_int32_T(&v2oe_v2);
  emxFree_int32_T(&v2oe_v1);
  emxFree_int8_T(&v2hf_lfid);
  emxFree_int32_T(&v2hf_cid);
  emxFree_int32_T(&is_index);
}

void determine_sibling_halffaces_tet_initialize(void)
{
  rt_InitInfAndNaN(8U);
}

void determine_sibling_halffaces_tet_terminate(void)
{
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

void emxDestroyArray_int32_T(emxArray_int32_T *emxArray)
{
  emxFree_int32_T(&emxArray);
}

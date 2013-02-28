/*
 * convert_mixed_elements.c
 *
 * Code generation for function 'convert_mixed_elements'
 *
 * C source code generated on: Mon Feb 25 13:46:03 2013
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "convert_mixed_elements.h"

/* Custom Source Code */
#define M2C_ASSIGN(dst,src)            dst=src

/* Type Definitions */
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

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static emlrtMCInfo emlrtMCI = { 35, 5, "convert_mixed_elements",
  "/Users/vladimir/projects/BitBucket/NumGeom/IO/Meshes/mexCGNS/convert_mixed_elements.m"
};

static emlrtMCInfo b_emlrtMCI = { 16, 7, "error",
  "/Applications/MATLAB_R2012a.app/toolbox/eml/lib/matlab/lang/error.m" };

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y);
static const mxArray *b_emlrt_marshallOut(emxArray_int32_T *u);
static void b_error(const mxArray *b, const mxArray *c, emlrtMCInfo *location);
static int32_T c_emlrt_marshallIn(const mxArray *dim, const char_T *identifier);
static int32_T d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId);
static void e_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret);
static void emlrt_marshallIn(const mxArray *elems, const char_T *identifier,
  emxArray_int32_T *y);
static const mxArray *emlrt_marshallOut(int32_T u);
static void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel,
  int32_T elementSize);
static void emxFree_int32_T(emxArray_int32_T **pEmxArray);
static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush);
static void error(const mxArray *b, emlrtMCInfo *location);
static int32_T f_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId);

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y)
{
  e_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *b_emlrt_marshallOut(emxArray_int32_T *u)
{
  const mxArray *y;
  const mxArray *m1;
  int32_T (*pData)[];
  int32_T i0;
  int32_T i;
  y = NULL;
  m1 = mxCreateNumericArray(1, (int32_T *)u->size, mxINT32_CLASS, mxREAL);
  pData = (int32_T (*)[])mxGetData(m1);
  i0 = 0;
  for (i = 0; i < u->size[0]; i++) {
    (*pData)[i0] = u->data[i];
    i0++;
  }

  emlrtAssign(&y, m1);
  return y;
}

static void b_error(const mxArray *b, const mxArray *c, emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  pArrays[0] = b;
  pArrays[1] = c;
  emlrtCallMATLAB(0, NULL, 2, pArrays, "error", TRUE, location);
}

static int32_T c_emlrt_marshallIn(const mxArray *dim, const char_T *identifier)
{
  int32_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = d_emlrt_marshallIn(emlrtAlias(dim), &thisId);
  emlrtDestroyArray(&dim);
  return y;
}

static int32_T d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId)
{
  int32_T y;
  y = f_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void e_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret)
{
  int32_T iv0[1];
  boolean_T bv0[1];
  int32_T i1;
  iv0[0] = -1;
  bv0[0] = TRUE;
  emlrtCheckVsBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "int32", FALSE,
    1U, iv0, bv0, ret->size);
  i1 = ret->size[0];
  ret->size[0] = ret->size[0];
  emxEnsureCapacity((emxArray__common *)ret, i1, (int32_T)sizeof(int32_T));
  emlrtImportArrayR2011b(src, ret->data, 4, FALSE);
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const mxArray *elems, const char_T *identifier,
  emxArray_int32_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  b_emlrt_marshallIn(emlrtAlias(elems), &thisId, y);
  emlrtDestroyArray(&elems);
}

static const mxArray *emlrt_marshallOut(int32_T u)
{
  const mxArray *y;
  const mxArray *m0;
  y = NULL;
  m0 = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int32_T *)mxGetData(m0) = u;
  emlrtAssign(&y, m0);
  return y;
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

static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush)
{
  emxArray_int32_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_int32_T *)malloc(sizeof(emxArray_int32_T));
  if (doPush) {
    emlrtPushHeapReferenceStack((void *)pEmxArray, (void (*)(void *, boolean_T))
      emxFree_int32_T);
  }

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

static void error(const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLAB(0, NULL, 1, &pArray, "error", TRUE, location);
}

static int32_T f_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId)
{
  int32_T ret;
  emlrtCheckBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "int32", FALSE, 0U,
    0);
  ret = *(int32_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

int32_T convert_mixed_elements(emxArray_int32_T *elems, int32_T dim)
{
  int32_T nelems;
  emxArray_int32_T *b_elems;
  int32_T es;
  int32_T ii;
  int32_T nvpe;
  const mxArray *y;
  const mxArray *m2;
  const mxArray *b_y;
  static const int32_T iv1[2] = { 1, 42 };

  const mxArray *c_y;
  static const int32_T iv2[2] = { 1, 42 };

  static const char_T cv0[42] = { 'E', 'R', 'R', 'O', 'R', ':', ' ', 'u', 'n',
    'k', 'n', 'o', 'w', 'n', ' ', 'e', 'l', 'e', 'm', 'e', 'n', 't', ' ', 't',
    'y', 'p', 'e', ' ', 'w', 'i', 't', 'h', ' ', '%', 'd', ' ', 'n', 'o', 'd',
    'e', 's', '.' };

  emlrtHeapReferenceStackEnterFcn();
  emxInit_int32_T(&b_elems, 1, TRUE);

  /*  Convert from the number of vertices per element into */
  /*  element_type in the connecitvity table. */
  es = elems->size[0];
  ii = 0;
  nelems = 0;
  if (dim == 2) {
    /*  Convert 2-D elements */
    while (ii + 1 < es) {
      nvpe = elems->data[ii];
      switch (elems->data[ii]) {
       case 3:
        elems->data[ii] = 5;
        break;

       case 4:
        elems->data[ii] = 7;
        break;

       case 6:
        elems->data[ii] = 6;
        break;

       case 8:
        elems->data[ii] = 8;
        break;

       case 9:
        elems->data[ii] = 9;
        break;

       default:
        c_y = NULL;
        m2 = mxCreateCharArray(2, iv2);
        emlrtInitCharArray(42, m2, cv0);
        emlrtAssign(&c_y, m2);
        b_error(c_y, emlrt_marshallOut(elems->data[ii]), &b_emlrtMCI);
        break;
      }

      ii = (ii + nvpe) + 1;
      nelems++;
    }
  } else {
    /*  Convert 3-D elements */
    if (dim == 3) {
    } else {
      y = NULL;
      m2 = mxCreateString("Assertion failed.");
      emlrtAssign(&y, m2);
      error(y, &emlrtMCI);
    }

    while (ii + 1 < es) {
      nvpe = elems->data[ii];
      switch (elems->data[ii]) {
       case 4:
        elems->data[ii] = 10;
        break;

       case 5:
        elems->data[ii] = 12;
        break;

       case 6:
        elems->data[ii] = 15;
        break;

       case 8:
        elems->data[ii] = 18;
        break;

       case 10:
        elems->data[ii] = 11;
        break;

       case 13:
        elems->data[ii] = 13;
        break;

       case 14:
        elems->data[ii] = 14;
        break;

       case 15:
        elems->data[ii] = 16;
        break;

       case 18:
        elems->data[ii] = 17;
        break;

       case 20:
        elems->data[ii] = 19;
        break;

       case 27:
        elems->data[ii] = 20;
        break;

       default:
        b_y = NULL;
        m2 = mxCreateCharArray(2, iv1);
        emlrtInitCharArray(42, m2, cv0);
        emlrtAssign(&b_y, m2);
        b_error(b_y, emlrt_marshallOut(elems->data[ii]), &b_emlrtMCI);
        break;
      }

      ii = (ii + nvpe) + 1;
      nelems++;
    }
  }

  emxFree_int32_T(&b_elems);
  emlrtHeapReferenceStackLeaveFcn();
  return nelems;
}

void convert_mixed_elements_api(const mxArray * const prhs[2], const mxArray
  *plhs[2])
{
  emxArray_int32_T *elems;
  int32_T dim;
  emlrtHeapReferenceStackEnterFcn();
  emxInit_int32_T(&elems, 1, TRUE);

  /* Marshall function inputs */
  emlrt_marshallIn(emlrtAliasP(prhs[0]), "elems", elems);
  dim = c_emlrt_marshallIn(emlrtAliasP(prhs[1]), "dim");

  /* Invoke the target function */
  dim = convert_mixed_elements(elems, dim);

  /* Marshall function outputs */
  plhs[0] = b_emlrt_marshallOut(elems);
  plhs[1] = emlrt_marshallOut(dim);
  emxFree_int32_T(&elems);
  emlrtHeapReferenceStackLeaveFcn();
}

void convert_mixed_elements_atexit(void)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtLeaveRtStack(&emlrtContextGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void convert_mixed_elements_initialize(emlrtContext *context)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtFirstTime(context);
}

void convert_mixed_elements_terminate(void)
{
  emlrtLeaveRtStack(&emlrtContextGlobal);
}

/* End of code generation (convert_mixed_elements.c) */

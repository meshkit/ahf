/*
 * inverse_mixed_elements.c
 *
 * Code generation for function 'inverse_mixed_elements'
 *
 * C source code generated on: Mon Feb 25 13:46:02 2013
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "inverse_mixed_elements.h"

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
static emlrtMCInfo emlrtMCI = { 16, 7, "error",
  "/Applications/MATLAB_R2012a.app/toolbox/eml/lib/matlab/lang/error.m" };

static emlrtMCInfo b_emlrtMCI = { 16, 7, "error",
  "/Applications/MATLAB_R2012a.app/toolbox/eml/lib/matlab/lang/error.m" };

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y);
static void c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret);
static void emlrt_marshallIn(const mxArray *elems, const char_T *identifier,
  emxArray_int32_T *y);
static const mxArray *emlrt_marshallOut(emxArray_int32_T *u);
static void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel,
  int32_T elementSize);
static void emxFree_int32_T(emxArray_int32_T **pEmxArray);
static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush);
static void error(const mxArray *b, emlrtMCInfo *location);

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y)
{
  c_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
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

static const mxArray *emlrt_marshallOut(emxArray_int32_T *u)
{
  const mxArray *y;
  const mxArray *m0;
  int32_T (*pData)[];
  int32_T i0;
  int32_T i;
  y = NULL;
  m0 = mxCreateNumericArray(1, (int32_T *)u->size, mxINT32_CLASS, mxREAL);
  pData = (int32_T (*)[])mxGetData(m0);
  i0 = 0;
  for (i = 0; i < u->size[0]; i++) {
    (*pData)[i0] = u->data[i];
    i0++;
  }

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

void inverse_mixed_elements(emxArray_int32_T *elems)
{
  emxArray_int32_T *b_elems;
  int32_T es;
  int32_T ii;
  int32_T npe;
  const mxArray *y;
  static const int32_T iv1[2] = { 1, 43 };

  const mxArray *m1;
  static const char_T cv0[43] = { 'F', 'o', 'r', ' ', 'm', 'i', 'x', 'e', 'd',
    ' ', 'm', 'e', 's', 'h', 'e', 's', ',', ' ', 'd', 'i', 'm', 'e', 'n', 's',
    'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'b', 'e', ' ', '2', ' ', 'o',
    'r', ' ', '3', '.' };

  const mxArray *b_y;
  static const int32_T iv2[2] = { 1, 27 };

  static const char_T cv1[27] = { 'E', 'r', 'r', 'o', 'r', ':', ' ', 'u', 'n',
    'k', 'n', 'o', 'w', 'n', ' ', 'e', 'l', 'e', 'm', 'e', 'n', 't', ' ', 't',
    'y', 'p', 'e' };

  emlrtHeapReferenceStackEnterFcn();
  emxInit_int32_T(&b_elems, 1, TRUE);

  /*  Convert from element_type in the connectivity table into the number of */
  /*  vertices per element. */
  es = elems->size[0];
  for (ii = 1; ii < es; ii = (ii + elems->data[ii - 1]) + 1) {
    /*  Obtain a string of element type */
    /*  [NPE, TYPESTR] = GET_ELEMTYPE_STRING( ITYPE) */
    /*  [NPE, TYPESTR] = GET_ELEMTYPE_STRING( ITYPE, ICELLDIM) */
    /*  */
    /*  Input argument: */
    /*      ITYPE is CGNS type ID */
    /*      ICELLDIM is 2 or 3, and is needed only if itype is MIXED. */
    /*  Output argument: */
    /*      NPE is the number of nodes per element */
    /*      TYPESTR is a string for the element type. */
    switch (elems->data[ii - 1]) {
     case 2:
      npe = 1;
      break;

     case 3:
      npe = 2;
      break;

     case 4:
      npe = 3;
      break;

     case 5:
      npe = 3;
      break;

     case 6:
      npe = 6;
      break;

     case 7:
      npe = 4;
      break;

     case 8:
      npe = 8;
      break;

     case 9:
      npe = 9;
      break;

     case 10:
      npe = 4;
      break;

     case 11:
      npe = 10;
      break;

     case 12:
      npe = 5;
      break;

     case 13:
      npe = 13;
      break;

     case 14:
      npe = 14;
      break;

     case 15:
      npe = 6;
      break;

     case 16:
      npe = 15;
      break;

     case 17:
      npe = 18;
      break;

     case 18:
      npe = 8;
      break;

     case 19:
      npe = 20;
      break;

     case 20:
      npe = 27;
      break;

     case 21:
      y = NULL;
      m1 = mxCreateCharArray(2, iv1);
      emlrtInitCharArray(43, m1, cv0);
      emlrtAssign(&y, m1);
      error(y, &emlrtMCI);
      npe = 1;
      break;

     default:
      b_y = NULL;
      m1 = mxCreateCharArray(2, iv2);
      emlrtInitCharArray(27, m1, cv1);
      emlrtAssign(&b_y, m1);
      error(b_y, &b_emlrtMCI);
      break;
    }

    elems->data[ii - 1] = npe;
  }

  emxFree_int32_T(&b_elems);
  emlrtHeapReferenceStackLeaveFcn();
}

void inverse_mixed_elements_api(const mxArray * const prhs[1], const mxArray
  *plhs[1])
{
  emxArray_int32_T *elems;
  emlrtHeapReferenceStackEnterFcn();
  emxInit_int32_T(&elems, 1, TRUE);

  /* Marshall function inputs */
  emlrt_marshallIn(emlrtAliasP(prhs[0]), "elems", elems);

  /* Invoke the target function */
  inverse_mixed_elements(elems);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(elems);
  emxFree_int32_T(&elems);
  emlrtHeapReferenceStackLeaveFcn();
}

void inverse_mixed_elements_atexit(void)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtLeaveRtStack(&emlrtContextGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void inverse_mixed_elements_initialize(emlrtContext *context)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtFirstTime(context);
}

void inverse_mixed_elements_terminate(void)
{
  emlrtLeaveRtStack(&emlrtContextGlobal);
}

/* End of code generation (inverse_mixed_elements.c) */

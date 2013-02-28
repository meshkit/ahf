/*
 * check_mixed.c
 *
 * Code generation for function 'check_mixed'
 *
 * C source code generated on: Mon Feb 25 13:46:01 2013
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "check_mixed.h"

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
static emlrtMCInfo emlrtMCI = { 2, 1, "check_mixed",
  "/Users/vladimir/projects/BitBucket/NumGeom/IO/Meshes/mexCGNS/check_mixed.m" };

static emlrtMCInfo b_emlrtMCI = { 6, 1, "check_mixed",
  "/Users/vladimir/projects/BitBucket/NumGeom/IO/Meshes/mexCGNS/check_mixed.m" };

static emlrtMCInfo c_emlrtMCI = { 16, 7, "error",
  "/Applications/MATLAB_R2012a.app/toolbox/eml/lib/matlab/lang/error.m" };

static emlrtMCInfo d_emlrtMCI = { 16, 7, "error",
  "/Applications/MATLAB_R2012a.app/toolbox/eml/lib/matlab/lang/error.m" };

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y);
static const mxArray *b_emlrt_marshallOut(emxArray_char_T *u);
static void b_emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T
  numDimensions, boolean_T doPush);
static int32_T c_emlrt_marshallIn(const mxArray *nelems, const char_T
  *identifier);
static int32_T d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId);
static void e_emlrt_marshallIn(const mxArray *typestr, const char_T *identifier,
  emxArray_char_T *y);
static void emlrt_marshallIn(const mxArray *elems, const char_T *identifier,
  emxArray_int32_T *y);
static const mxArray *emlrt_marshallOut(emxArray_int32_T *u);
static void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel,
  int32_T elementSize);
static void emxFree_char_T(emxArray_char_T **pEmxArray);
static void emxFree_int32_T(emxArray_int32_T **pEmxArray);
static void emxInit_char_T(emxArray_char_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush);
static void emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush);
static void error(const mxArray *b, emlrtMCInfo *location);
static void f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_char_T *y);
static void g_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_int32_T *ret);
static int32_T h_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId);
static void i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_char_T *ret);

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_int32_T *y)
{
  g_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *b_emlrt_marshallOut(emxArray_char_T *u)
{
  const mxArray *y;
  const mxArray *m1;
  y = NULL;
  m1 = mxCreateCharArray(2, u->size);
  emlrtInitCharArray(u->size[0] * u->size[1], m1, u->data);
  emlrtAssign(&y, m1);
  return y;
}

static void b_emxInit_int32_T(emxArray_int32_T **pEmxArray, int32_T
  numDimensions, boolean_T doPush)
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

static int32_T c_emlrt_marshallIn(const mxArray *nelems, const char_T
  *identifier)
{
  int32_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = d_emlrt_marshallIn(emlrtAlias(nelems), &thisId);
  emlrtDestroyArray(&nelems);
  return y;
}

static int32_T d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId)
{
  int32_T y;
  y = h_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void e_emlrt_marshallIn(const mxArray *typestr, const char_T *identifier,
  emxArray_char_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  f_emlrt_marshallIn(emlrtAlias(typestr), &thisId, y);
  emlrtDestroyArray(&typestr);
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
  int32_T b_i;
  y = NULL;
  m0 = mxCreateNumericArray(2, (int32_T *)u->size, mxINT32_CLASS, mxREAL);
  pData = (int32_T (*)[])mxGetData(m0);
  i0 = 0;
  for (i = 0; i < u->size[1]; i++) {
    for (b_i = 0; b_i < u->size[0]; b_i++) {
      (*pData)[i0] = u->data[b_i + u->size[0] * i];
      i0++;
    }
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

static void emxFree_char_T(emxArray_char_T **pEmxArray)
{
  if (*pEmxArray != (emxArray_char_T *)NULL) {
    if ((*pEmxArray)->canFreeData) {
      free((void *)(*pEmxArray)->data);
    }

    free((void *)(*pEmxArray)->size);
    free((void *)*pEmxArray);
    *pEmxArray = (emxArray_char_T *)NULL;
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

static void emxInit_char_T(emxArray_char_T **pEmxArray, int32_T numDimensions,
  boolean_T doPush)
{
  emxArray_char_T *emxArray;
  int32_T loop_ub;
  int32_T i;
  *pEmxArray = (emxArray_char_T *)malloc(sizeof(emxArray_char_T));
  if (doPush) {
    emlrtPushHeapReferenceStack((void *)pEmxArray, (void (*)(void *, boolean_T))
      emxFree_char_T);
  }

  emxArray = *pEmxArray;
  emxArray->data = (char_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int32_T *)malloc((uint32_T)(sizeof(int32_T) * numDimensions));
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = TRUE;
  loop_ub = numDimensions - 1;
  for (i = 0; i <= loop_ub; i++) {
    emxArray->size[i] = 0;
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

static void f_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_char_T *y)
{
  i_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void g_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
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

static int32_T h_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId)
{
  int32_T ret;
  emlrtCheckBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "int32", FALSE, 0U,
    0);
  ret = *(int32_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static void i_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_char_T *ret)
{
  int32_T iv1[2];
  boolean_T bv1[2];
  int32_T i;
  for (i = 0; i < 2; i++) {
    iv1[i] = -1;
    bv1[i] = TRUE;
  }

  emlrtCheckVsBuiltInCtxR2011b(&emlrtContextGlobal, msgId, src, "char", FALSE,
    2U, iv1, bv1, ret->size);
  i = ret->size[0] * ret->size[1];
  ret->size[0] = ret->size[0];
  ret->size[1] = ret->size[1];
  emxEnsureCapacity((emxArray__common *)ret, i, (int32_T)sizeof(char_T));
  emlrtImportArrayR2011b(src, ret->data, 1, FALSE);
  emlrtDestroyArray(&src);
}

void check_mixed(const emxArray_int32_T *elems, int32_T nelems, int32_T
                 element_type, int32_T icelldim, emxArray_char_T *typestr,
                 emxArray_int32_T *new_elems)
{
  boolean_T b0;
  const mxArray *y;
  const mxArray *m2;
  const mxArray *b_y;
  int32_T num_type;
  int32_T elems_idx_0;
  int32_T i2;
  int32_T ii;
  boolean_T exitg1;
  emxArray_int32_T *r0;
  emxArray_int32_T *b_elems;
  int32_T i3;
  int32_T i4;
  emxArray_char_T *b_typestr;
  static const char_T cv0[4] = { 'N', 'O', 'D', 'E' };

  static const char_T cv1[5] = { 'B', 'A', 'R', '_', '2' };

  static const char_T cv2[5] = { 'B', 'A', 'R', '_', '3' };

  static const char_T cv3[5] = { 'T', 'R', 'I', '_', '3' };

  static const char_T cv4[5] = { 'T', 'R', 'I', '_', '6' };

  static const char_T cv5[6] = { 'Q', 'U', 'A', 'D', '_', '4' };

  static const char_T cv6[6] = { 'Q', 'U', 'A', 'D', '_', '8' };

  static const char_T cv7[6] = { 'Q', 'U', 'A', 'D', '_', '9' };

  static const char_T cv8[7] = { 'T', 'E', 'T', 'R', 'A', '_', '4' };

  static const char_T cv9[8] = { 'T', 'E', 'T', 'R', 'A', '_', '1', '0' };

  static const char_T cv10[6] = { 'P', 'Y', 'R', 'A', '_', '5' };

  static const char_T cv11[7] = { 'P', 'Y', 'R', 'A', '_', '1', '3' };

  static const char_T cv12[7] = { 'P', 'Y', 'R', 'A', '_', '1', '4' };

  static const char_T cv13[7] = { 'P', 'E', 'N', 'T', 'A', '_', '6' };

  static const char_T cv14[8] = { 'P', 'E', 'N', 'T', 'A', '_', '1', '5' };

  static const char_T cv15[8] = { 'P', 'E', 'N', 'T', 'A', '_', '1', '8' };

  static const char_T cv16[6] = { 'H', 'E', 'X', 'A', '_', '8' };

  static const char_T cv17[7] = { 'H', 'E', 'X', 'A', '_', '2', '0' };

  static const char_T cv18[7] = { 'H', 'E', 'X', 'A', '_', '2', '7' };

  static const char_T cv19[6] = { 'M', 'I', 'X', 'E', 'D', '2' };

  static const char_T cv20[6] = { 'M', 'I', 'X', 'E', 'D', '3' };

  const mxArray *c_y;
  static const int32_T iv2[2] = { 1, 43 };

  static const char_T cv21[43] = { 'F', 'o', 'r', ' ', 'm', 'i', 'x', 'e', 'd',
    ' ', 'm', 'e', 's', 'h', 'e', 's', ',', ' ', 'd', 'i', 'm', 'e', 'n', 's',
    'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'b', 'e', ' ', '2', ' ', 'o',
    'r', ' ', '3', '.' };

  const mxArray *d_y;
  static const int32_T iv3[2] = { 1, 27 };

  static const char_T cv22[27] = { 'E', 'r', 'r', 'o', 'r', ':', ' ', 'u', 'n',
    'k', 'n', 'o', 'w', 'n', ' ', 'e', 'l', 'e', 'm', 'e', 'n', 't', ' ', 't',
    'y', 'p', 'e' };

  emlrtHeapReferenceStackEnterFcn();
  if (elems->size[0] >= 1) {
    b0 = TRUE;
  } else {
    b0 = FALSE;
  }

  if (b0) {
  } else {
    y = NULL;
    m2 = mxCreateString("Assertion failed.");
    emlrtAssign(&y, m2);
    error(y, &emlrtMCI);
  }

  if (typestr->size[1] >= 1) {
    b0 = TRUE;
  } else {
    b0 = FALSE;
  }

  if (b0) {
  } else {
    b_y = NULL;
    m2 = mxCreateString("Assertion failed.");
    emlrtAssign(&b_y, m2);
    error(b_y, &b_emlrtMCI);
  }

  /*  Check that mesh is indeed MIXED */
  num_type = elems->data[0];
  elems_idx_0 = elems->size[0];
  i2 = new_elems->size[0] * new_elems->size[1];
  new_elems->size[0] = elems_idx_0;
  emxEnsureCapacity((emxArray__common *)new_elems, i2, (int32_T)sizeof(int32_T));
  i2 = new_elems->size[0] * new_elems->size[1];
  new_elems->size[1] = 1;
  emxEnsureCapacity((emxArray__common *)new_elems, i2, (int32_T)sizeof(int32_T));
  elems_idx_0 = elems->size[0] - 1;
  for (i2 = 0; i2 <= elems_idx_0; i2++) {
    new_elems->data[i2] = elems->data[i2];
  }

  ii = 2;
  exitg1 = FALSE;
  while ((exitg1 == 0U) && (ii <= nelems)) {
    if (elems->data[0] != elems->data[(elems->data[0] + 1) * (ii - 1)]) {
      num_type = 0;
      exitg1 = TRUE;
    } else {
      ii++;
    }
  }

  /*  Convert MIXED2 and MIXED3 types to actual types, if they have been */
  /*  mislabeled.  Additionally change ELEMS so that it is the correct type of */
  /*  output matrix. */
  if (num_type != 0) {
    i2 = new_elems->size[0] * new_elems->size[1];
    new_elems->size[0] = nelems;
    new_elems->size[1] = num_type;
    emxEnsureCapacity((emxArray__common *)new_elems, i2, (int32_T)sizeof(int32_T));
    elems_idx_0 = nelems * num_type - 1;
    for (i2 = 0; i2 <= elems_idx_0; i2++) {
      new_elems->data[i2] = 0;
    }

    ii = 1;
    emxInit_int32_T(&r0, 1, TRUE);
    emxInit_int32_T(&b_elems, 1, TRUE);
    while (ii <= nelems) {
      i2 = (num_type + 1) * (ii - 1) + 2;
      i3 = ((num_type + 1) * (ii - 1) + num_type) + 1;
      if (i2 > i3) {
        i2 = 0;
        i3 = 0;
      } else {
        i2--;
      }

      i4 = new_elems->size[1];
      elems_idx_0 = r0->size[0];
      r0->size[0] = i4;
      emxEnsureCapacity((emxArray__common *)r0, elems_idx_0, (int32_T)sizeof
                        (int32_T));
      elems_idx_0 = i4 - 1;
      for (i4 = 0; i4 <= elems_idx_0; i4++) {
        r0->data[i4] = i4;
      }

      i4 = b_elems->size[0];
      b_elems->size[0] = i3 - i2;
      emxEnsureCapacity((emxArray__common *)b_elems, i4, (int32_T)sizeof(int32_T));
      elems_idx_0 = (i3 - i2) - 1;
      for (i3 = 0; i3 <= elems_idx_0; i3++) {
        b_elems->data[i3] = elems->data[i2 + i3];
      }

      elems_idx_0 = r0->size[0];
      elems_idx_0--;
      for (i2 = 0; i2 <= elems_idx_0; i2++) {
        i3 = 0;
        while (i3 <= 0) {
          new_elems->data[(ii + new_elems->size[0] * r0->data[i2]) - 1] =
            b_elems->data[i2];
          i3 = 1;
        }
      }

      ii++;
    }

    emxFree_int32_T(&b_elems);
    emxFree_int32_T(&r0);

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
    emxInit_char_T(&b_typestr, 2, TRUE);
    switch (element_type) {
     case 2:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 4;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 4; i2++) {
        b_typestr->data[i2] = cv0[i2];
      }
      break;

     case 3:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 5;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 5; i2++) {
        b_typestr->data[i2] = cv1[i2];
      }
      break;

     case 4:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 5;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 5; i2++) {
        b_typestr->data[i2] = cv2[i2];
      }
      break;

     case 5:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 5;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 5; i2++) {
        b_typestr->data[i2] = cv3[i2];
      }
      break;

     case 6:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 5;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 5; i2++) {
        b_typestr->data[i2] = cv4[i2];
      }
      break;

     case 7:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 6; i2++) {
        b_typestr->data[i2] = cv5[i2];
      }
      break;

     case 8:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 6; i2++) {
        b_typestr->data[i2] = cv6[i2];
      }
      break;

     case 9:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 6; i2++) {
        b_typestr->data[i2] = cv7[i2];
      }
      break;

     case 10:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv8[i2];
      }
      break;

     case 11:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 8;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 8; i2++) {
        b_typestr->data[i2] = cv9[i2];
      }
      break;

     case 12:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 6; i2++) {
        b_typestr->data[i2] = cv10[i2];
      }
      break;

     case 13:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv11[i2];
      }
      break;

     case 14:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv12[i2];
      }
      break;

     case 15:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv13[i2];
      }
      break;

     case 16:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 8;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 8; i2++) {
        b_typestr->data[i2] = cv14[i2];
      }
      break;

     case 17:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 8;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 8; i2++) {
        b_typestr->data[i2] = cv15[i2];
      }
      break;

     case 18:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 6;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 6; i2++) {
        b_typestr->data[i2] = cv16[i2];
      }
      break;

     case 19:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv17[i2];
      }
      break;

     case 20:
      i2 = b_typestr->size[0] * b_typestr->size[1];
      b_typestr->size[0] = 1;
      b_typestr->size[1] = 7;
      emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                        (char_T));
      for (i2 = 0; i2 < 7; i2++) {
        b_typestr->data[i2] = cv18[i2];
      }
      break;

     case 21:
      if (icelldim == 2) {
        i2 = b_typestr->size[0] * b_typestr->size[1];
        b_typestr->size[0] = 1;
        b_typestr->size[1] = 6;
        emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                          (char_T));
        for (i2 = 0; i2 < 6; i2++) {
          b_typestr->data[i2] = cv19[i2];
        }
      } else if (icelldim == 3) {
        i2 = b_typestr->size[0] * b_typestr->size[1];
        b_typestr->size[0] = 1;
        b_typestr->size[1] = 6;
        emxEnsureCapacity((emxArray__common *)b_typestr, i2, (int32_T)sizeof
                          (char_T));
        for (i2 = 0; i2 < 6; i2++) {
          b_typestr->data[i2] = cv20[i2];
        }
      } else {
        c_y = NULL;
        m2 = mxCreateCharArray(2, iv2);
        emlrtInitCharArray(43, m2, cv21);
        emlrtAssign(&c_y, m2);
        error(c_y, &c_emlrtMCI);
      }
      break;

     default:
      d_y = NULL;
      m2 = mxCreateCharArray(2, iv3);
      emlrtInitCharArray(27, m2, cv22);
      emlrtAssign(&d_y, m2);
      error(d_y, &d_emlrtMCI);
      break;
    }

    i2 = typestr->size[0] * typestr->size[1];
    typestr->size[0] = 1;
    typestr->size[1] = b_typestr->size[1];
    emxEnsureCapacity((emxArray__common *)typestr, i2, (int32_T)sizeof(char_T));
    elems_idx_0 = b_typestr->size[1] - 1;
    for (i2 = 0; i2 <= elems_idx_0; i2++) {
      typestr->data[typestr->size[0] * i2] = b_typestr->data[b_typestr->size[0] *
        i2];
    }

    emxFree_char_T(&b_typestr);
  }

  emlrtHeapReferenceStackLeaveFcn();
}

void check_mixed_api(const mxArray * const prhs[5], const mxArray *plhs[2])
{
  emxArray_int32_T *elems;
  emxArray_char_T *typestr;
  emxArray_int32_T *new_elems;
  int32_T nelems;
  int32_T element_type;
  int32_T icelldim;
  emlrtHeapReferenceStackEnterFcn();
  emxInit_int32_T(&elems, 1, TRUE);
  emxInit_char_T(&typestr, 2, TRUE);
  b_emxInit_int32_T(&new_elems, 2, TRUE);

  /* Marshall function inputs */
  emlrt_marshallIn(emlrtAliasP(prhs[0]), "elems", elems);
  nelems = c_emlrt_marshallIn(emlrtAliasP(prhs[1]), "nelems");
  element_type = c_emlrt_marshallIn(emlrtAliasP(prhs[2]), "element_type");
  icelldim = c_emlrt_marshallIn(emlrtAliasP(prhs[3]), "icelldim");
  e_emlrt_marshallIn(emlrtAliasP(prhs[4]), "typestr", typestr);

  /* Invoke the target function */
  check_mixed(elems, nelems, element_type, icelldim, typestr, new_elems);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(new_elems);
  plhs[1] = b_emlrt_marshallOut(typestr);
  emxFree_int32_T(&new_elems);
  emxFree_char_T(&typestr);
  emxFree_int32_T(&elems);
  emlrtHeapReferenceStackLeaveFcn();
}

void check_mixed_atexit(void)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtLeaveRtStack(&emlrtContextGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void check_mixed_initialize(emlrtContext *context)
{
  emlrtEnterRtStack(&emlrtContextGlobal);
  emlrtFirstTime(context);
}

void check_mixed_terminate(void)
{
  emlrtLeaveRtStack(&emlrtContextGlobal);
}

/* End of code generation (check_mixed.c) */

/*
 * check_mixed.h
 *
 * Code generation for function 'check_mixed'
 *
 * C source code generated on: Mon Feb 25 13:46:01 2013
 *
 */

#ifndef __CHECK_MIXED_H__
#define __CHECK_MIXED_H__
/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blascompat32.h"
#include "rtwtypes.h"
#include "check_mixed_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern void check_mixed(const emxArray_int32_T *elems, int32_T nelems, int32_T element_type, int32_T icelldim, emxArray_char_T *typestr, emxArray_int32_T *new_elems);
extern void check_mixed_api(const mxArray * const prhs[5], const mxArray *plhs[2]);
extern void check_mixed_atexit(void);
extern void check_mixed_initialize(emlrtContext *context);
extern void check_mixed_terminate(void);
#endif
/* End of code generation (check_mixed.h) */

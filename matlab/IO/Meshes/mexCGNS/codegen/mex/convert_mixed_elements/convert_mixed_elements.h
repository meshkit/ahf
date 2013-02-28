/*
 * convert_mixed_elements.h
 *
 * Code generation for function 'convert_mixed_elements'
 *
 * C source code generated on: Mon Feb 25 13:46:03 2013
 *
 */

#ifndef __CONVERT_MIXED_ELEMENTS_H__
#define __CONVERT_MIXED_ELEMENTS_H__
/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blascompat32.h"
#include "rtwtypes.h"
#include "convert_mixed_elements_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern int32_T convert_mixed_elements(emxArray_int32_T *elems, int32_T dim);
extern void convert_mixed_elements_api(const mxArray * const prhs[2], const mxArray *plhs[2]);
extern void convert_mixed_elements_atexit(void);
extern void convert_mixed_elements_initialize(emlrtContext *context);
extern void convert_mixed_elements_terminate(void);
#endif
/* End of code generation (convert_mixed_elements.h) */

/*
 * inverse_mixed_elements.h
 *
 * Code generation for function 'inverse_mixed_elements'
 *
 * C source code generated on: Mon Feb 25 13:46:02 2013
 *
 */

#ifndef __INVERSE_MIXED_ELEMENTS_H__
#define __INVERSE_MIXED_ELEMENTS_H__
/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blascompat32.h"
#include "rtwtypes.h"
#include "inverse_mixed_elements_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern void inverse_mixed_elements(emxArray_int32_T *elems);
extern void inverse_mixed_elements_api(const mxArray * const prhs[1], const mxArray *plhs[1]);
extern void inverse_mixed_elements_atexit(void);
extern void inverse_mixed_elements_initialize(emlrtContext *context);
extern void inverse_mixed_elements_terminate(void);
#endif
/* End of code generation (inverse_mixed_elements.h) */

#ifndef __DETERMINE_SIBLING_HALFFACES_PYRAMID_H__
#define __DETERMINE_SIBLING_HALFFACES_PYRAMID_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "determine_sibling_halffaces_pyramid_types.h"
extern void determine_sibling_halffaces_pyramid(int32_T nv, const emxArray_int32_T *elems, const emxArray_int32_T *varargin_1, emxArray_int32_T *sibhfs);
extern void determine_sibling_halffaces_pyramid_initialize(void);
extern void determine_sibling_halffaces_pyramid_terminate(void);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
#endif

#ifndef __DETERMINE_SIBLING_HALFVERTS_H__
#define __DETERMINE_SIBLING_HALFVERTS_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "determine_sibling_halfverts_types.h"
extern void determine_sibling_halfverts(int32_T nv, const emxArray_int32_T *edges, emxArray_int32_T *sibhvs, boolean_T *manifold, boolean_T *oriented);
extern void determine_sibling_halfverts_initialize(void);
extern void determine_sibling_halfverts_terminate(void);
extern void determine_sibling_halfverts_usestruct(int32_T nv, const emxArray_int32_T *edges, boolean_T usestruct, struct_T *sibhvs, boolean_T *manifold, boolean_T *oriented);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateND_int8_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateWrapperND_int8_T(int8_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreateWrapper_int8_T(int8_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreate_int8_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void emxDestroyArray_int8_T(emxArray_int8_T *emxArray);
#endif

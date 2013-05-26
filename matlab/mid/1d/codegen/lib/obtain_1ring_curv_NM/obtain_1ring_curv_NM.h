#ifndef __OBTAIN_1RING_CURV_NM_H__
#define __OBTAIN_1RING_CURV_NM_H__
#include <stddef.h>
#include <stdlib.h>

#include "rtwtypes.h"
#include "obtain_1ring_curv_NM_types.h"
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
extern void obtain_1ring_curv_NM(int32_T vid, const emxArray_int32_T *edges, const emxArray_int32_T *sibhvs, const emxArray_int32_T *v2hv, int32_T ngbvs[10], int32_T *nverts);
extern void obtain_1ring_curv_NM_initialize(void);
extern void obtain_1ring_curv_NM_terminate(void);
extern void obtain_1ring_curv_NM_usestruct(int32_T vid, const emxArray_int32_T *edges, const struct_T sibhvs, const struct_T v2hv, boolean_T usestruct, int32_T ngbvs[10], int32_T *nverts);
#endif

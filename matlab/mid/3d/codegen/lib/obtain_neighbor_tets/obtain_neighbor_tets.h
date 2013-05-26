#ifndef __OBTAIN_NEIGHBOR_TETS_H__
#define __OBTAIN_NEIGHBOR_TETS_H__
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "obtain_neighbor_tets_types.h"
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateND_int8_T(int32_T numDimensions, int32_T *size);
extern emxArray_real_T *emxCreateND_real_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateWrapperND_int8_T(int8_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_real_T *emxCreateWrapperND_real_T(real_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreateWrapper_int8_T(int8_T *data, int32_T rows, int32_T cols);
extern emxArray_real_T *emxCreateWrapper_real_T(real_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreate_int8_T(int32_T rows, int32_T cols);
extern emxArray_real_T *emxCreate_real_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void emxDestroyArray_int8_T(emxArray_int8_T *emxArray);
extern void emxDestroyArray_real_T(emxArray_real_T *emxArray);
extern void obtain_neighbor_tets(int32_T cid, const emxArray_int32_T *sibhfs, emxArray_real_T *ngbtets);
extern void obtain_neighbor_tets_initialize(void);
extern void obtain_neighbor_tets_terminate(void);
extern void obtain_neighbor_tets_usestruct(int32_T cid, const struct_T sibhfs, boolean_T usestruct, emxArray_real_T *ngbtets);
#endif

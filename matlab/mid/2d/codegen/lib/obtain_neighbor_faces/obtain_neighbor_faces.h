#ifndef __OBTAIN_NEIGHBOR_FACES_H__
#define __OBTAIN_NEIGHBOR_FACES_H__
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "obtain_neighbor_faces_types.h"
extern emxArray_boolean_T *emxCreateND_boolean_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateND_int8_T(int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapperND_boolean_T(boolean_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateWrapperND_int8_T(int8_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapper_boolean_T(boolean_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreateWrapper_int8_T(int8_T *data, int32_T rows, int32_T cols);
extern emxArray_boolean_T *emxCreate_boolean_T(int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreate_int8_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_boolean_T(emxArray_boolean_T *emxArray);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void emxDestroyArray_int8_T(emxArray_int8_T *emxArray);
extern void obtain_neighbor_faces(int32_T fid, const emxArray_int32_T *sibhes, emxArray_boolean_T *ftags, real_T ngbfaces[100], real_T *nfaces);
extern void obtain_neighbor_faces_initialize(void);
extern void obtain_neighbor_faces_terminate(void);
extern void obtain_neighbor_faces_usestruct(int32_T fid, const b_struct_T sibhes, emxArray_boolean_T *ftags, boolean_T usestruct, real_T ngbfaces[100], real_T *nfaces);
#endif

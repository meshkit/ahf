#ifndef __OBTAIN_1RING_ELEMS_TET_H__
#define __OBTAIN_1RING_ELEMS_TET_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "obtain_1ring_elems_tet_types.h"
extern emxArray_boolean_T *emxCreateND_boolean_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapperND_boolean_T(boolean_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapper_boolean_T(boolean_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_boolean_T *emxCreate_boolean_T(int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_boolean_T(emxArray_boolean_T *emxArray);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern int32_T obtain_1ring_elems_tet(int32_T vid, const emxArray_int32_T *tets, const emxArray_int32_T *sibhfs, const emxArray_int32_T *v2hf, emxArray_int32_T *ngbes, emxArray_boolean_T *etags);
extern void obtain_1ring_elems_tet_initialize(void);
extern void obtain_1ring_elems_tet_terminate(void);
#endif

#ifndef __OBTAIN_1RING_SURF_NMANFLD_H__
#define __OBTAIN_1RING_SURF_NMANFLD_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "obtain_1ring_surf_nmanfld_types.h"
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
extern void obtain_1ring_surf_nmanfld(int32_T vid, const emxArray_int32_T *tris, const emxArray_int32_T *sibhes, const emxArray_int32_T *v2he, emxArray_boolean_T *vtags, emxArray_boolean_T *ftags, emxArray_int32_T *ngbvs, int32_T *nverts, emxArray_int32_T *ngbfs, int32_T *nfaces);
extern void obtain_1ring_surf_nmanfld_initialize(void);
extern void obtain_1ring_surf_nmanfld_terminate(void);
#endif

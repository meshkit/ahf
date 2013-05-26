#ifndef __EID2ADJ_FACES_H__
#define __EID2ADJ_FACES_H__
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "eid2adj_faces_types.h"
extern real_T eid2adj_faces(int32_T eid, const emxArray_int32_T *edges, const emxArray_int32_T *tris, const emxArray_int32_T *v2he, const emxArray_int32_T *sibhes, emxArray_int32_T *flist, emxArray_boolean_T *ftags);
extern void eid2adj_faces_initialize(void);
extern void eid2adj_faces_terminate(void);
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
#endif

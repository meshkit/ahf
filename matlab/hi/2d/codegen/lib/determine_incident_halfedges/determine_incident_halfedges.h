#ifndef __DETERMINE_INCIDENT_HALFEDGES_H__
#define __DETERMINE_INCIDENT_HALFEDGES_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "determine_incident_halfedges_types.h"
extern void determine_incident_halfedges(int32_T nv, const emxArray_int32_T *elems, const emxArray_int32_T *sibhes, emxArray_int32_T *v2he);
extern void determine_incident_halfedges_initialize(void);
extern void determine_incident_halfedges_terminate(void);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
#endif

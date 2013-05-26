#ifndef __VID2ADJ_EDGES_H__
#define __VID2ADJ_EDGES_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "vid2adj_edges_types.h"
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void vid2adj_edges(int32_T vid, const emxArray_int32_T *v2hv, const emxArray_int32_T *sibhvs, int32_T edge_list[50], real_T *nedges);
extern void vid2adj_edges_initialize(void);
extern void vid2adj_edges_terminate(void);
#endif

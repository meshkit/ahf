#ifndef __EID2ADJ_EDGES_H__
#define __EID2ADJ_EDGES_H__
#include <stddef.h>
#include <stdlib.h>

#include "rtwtypes.h"
#include "eid2adj_edges_types.h"
extern real_T eid2adj_edges(int32_T eid, const emxArray_int32_T *edges, const emxArray_int32_T *v2hv, const emxArray_int32_T *sibhvs, emxArray_int32_T *edge_list);
extern void eid2adj_edges_initialize(void);
extern void eid2adj_edges_terminate(void);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
#endif

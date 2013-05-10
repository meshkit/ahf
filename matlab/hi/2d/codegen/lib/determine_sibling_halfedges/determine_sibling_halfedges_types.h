#ifndef __DETERMINE_SIBLING_HALFEDGES_TYPES_H__
#define __DETERMINE_SIBLING_HALFEDGES_TYPES_H__
#include "rtwtypes.h"
#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T
struct emxArray_int32_T
{
    int32_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
};
#endif /*struct_emxArray_int32_T*/
#ifndef typedef_emxArray_int32_T
#define typedef_emxArray_int32_T
typedef struct emxArray_int32_T emxArray_int32_T;
#endif /*typedef_emxArray_int32_T*/
#ifndef struct_emxArray_int8_T
#define struct_emxArray_int8_T
struct emxArray_int8_T
{
    int8_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
};
#endif /*struct_emxArray_int8_T*/
#ifndef typedef_emxArray_int8_T
#define typedef_emxArray_int8_T
typedef struct emxArray_int8_T emxArray_int8_T;
#endif /*typedef_emxArray_int8_T*/
#ifndef typedef_struct_T
#define typedef_struct_T
typedef struct
{
    emxArray_int32_T *fid;
    emxArray_int8_T *leid;
} struct_T;
#endif /*typedef_struct_T*/

#endif

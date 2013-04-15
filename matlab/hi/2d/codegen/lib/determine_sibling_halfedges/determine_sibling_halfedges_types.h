#ifndef __DETERMINE_SIBLING_HALFEDGES_TYPES_H__
#define __DETERMINE_SIBLING_HALFEDGES_TYPES_H__
#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T
typedef struct emxArray_int32_T
{
    int32_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray_int32_T;
#endif
#ifndef struct_emxArray_int8_T
#define struct_emxArray_int8_T
typedef struct emxArray_int8_T
{
    int8_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray_int8_T;
#endif
typedef struct
{
    emxArray_int32_T *fid;
    emxArray_int8_T *leid;
} struct_T;

#endif

#ifndef __OBTAIN_NEIGHBOR_FACES_TYPES_H__
#define __OBTAIN_NEIGHBOR_FACES_TYPES_H__
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
} b_struct_T;
#ifndef struct_emxArray_boolean_T
#define struct_emxArray_boolean_T
typedef struct emxArray_boolean_T
{
    boolean_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray_boolean_T;
#endif
typedef struct
{
    real_T fid[100];
    real_T leid[100];
} struct_T;

#endif

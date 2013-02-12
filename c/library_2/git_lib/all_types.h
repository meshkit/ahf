

/*
 * obtain_1ring_vol_types.h
 *
 * Code generation for function 'obtain_1ring_vol'
 *
 * C source code generated on: Tue Feb  5 18:00:20 2013
 *
 */

#ifndef __OBTAIN_1RING_VOL_TYPES_H__
#define __OBTAIN_1RING_VOL_TYPES_H__

/* Type Definitions */
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

#endif
/* End of code generation (obtain_1ring_vol_types.h) */

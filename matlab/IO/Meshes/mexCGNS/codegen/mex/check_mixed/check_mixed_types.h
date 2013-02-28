/*
 * check_mixed_types.h
 *
 * Code generation for function 'check_mixed'
 *
 * C source code generated on: Mon Feb 25 13:46:01 2013
 *
 */

#ifndef __CHECK_MIXED_TYPES_H__
#define __CHECK_MIXED_TYPES_H__

/* Type Definitions */
#ifndef struct_emxArray_char_T
#define struct_emxArray_char_T
typedef struct emxArray_char_T
{
    char_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray_char_T;
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
/* End of code generation (check_mixed_types.h) */

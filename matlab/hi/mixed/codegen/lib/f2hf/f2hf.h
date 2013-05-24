#ifndef __F2HF_H__
#define __F2HF_H__
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "rtwtypes.h"
#include "f2hf_types.h"
extern emxArray_boolean_T *emxCreateND_boolean_T(int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateND_int32_T(int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateND_int8_T(int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapperND_boolean_T(boolean_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int32_T *emxCreateWrapperND_int32_T(int32_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_int8_T *emxCreateWrapperND_int8_T(int8_T *data, int32_T numDimensions, int32_T *size);
extern emxArray_boolean_T *emxCreateWrapper_boolean_T(boolean_T *data, int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreateWrapper_int32_T(int32_T *data, int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreateWrapper_int8_T(int8_T *data, int32_T rows, int32_T cols);
extern emxArray_boolean_T *emxCreate_boolean_T(int32_T rows, int32_T cols);
extern emxArray_int32_T *emxCreate_int32_T(int32_T rows, int32_T cols);
extern emxArray_int8_T *emxCreate_int8_T(int32_T rows, int32_T cols);
extern void emxDestroyArray_boolean_T(emxArray_boolean_T *emxArray);
extern void emxDestroyArray_int32_T(emxArray_int32_T *emxArray);
extern void emxDestroyArray_int8_T(emxArray_int8_T *emxArray);
extern int32_T f2hf(int32_T *fid, const emxArray_int32_T *faces, const emxArray_int32_T *tets, const emxArray_int32_T *sibhfs, const emxArray_int32_T *v2hf, emxArray_boolean_T *etags);
extern void f2hf_initialize(void);
extern void f2hf_terminate(void);
extern int32_T f2hf_usestruct(int32_T *fid, const emxArray_int32_T *faces, const emxArray_int32_T *tets, const struct_T sibhfs, const struct_T v2hf, emxArray_boolean_T *etags, boolean_T usestruct);
#endif

/*
 * f2hf_mex.c
 *
 * Auxiliary code generation for function f2hf
 *
 * C source code generated by m2c.
*
 */

#include "mex.h"

#define BUILD_MEX
/* Include the C file generated by codegen in lib mode */
#include "f2hf.h"
#include "m2c.c"
#include "f2hf.c"
/* Include declaration of some helper functions. */
#include "lib2mex_helper.c"

void f2hf_api(const mxArray ** prhs, const mxArray **plhs) {

    emxArray_int32_T     faces;
    emxArray_int32_T     tets;
    emxArray_int32_T     sibhfs;
    emxArray_int32_T     v2hf;
    emxArray_boolean_T   etags;

    int32_T              *fid;
    int32_T              lfid;

    /* Marshall in function inputs */
    plhs[0] = mxDuplicateArray( prhs[0]);
    if ( mxGetNumberOfElements(plhs[0]) && mxGetClassID(plhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument fid has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(plhs[0]) != 1)
        mexErrMsgIdAndTxt("f2hf:WrongSizeOfInputArg",
            "Argument fid should be a scalar.");
    fid = (int32_T*)mxGetData(plhs[0]);
    if ( mxGetNumberOfElements(prhs[1]) && mxGetClassID(prhs[1]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument faces has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[1], (emxArray__common *)&faces, "faces", 2);
    if ( mxGetNumberOfElements(prhs[2]) && mxGetClassID(prhs[2]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument tets has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[2], (emxArray__common *)&tets, "tets", 2);
    if ( mxGetNumberOfElements(prhs[3]) && mxGetClassID(prhs[3]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument sibhfs has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[3], (emxArray__common *)&sibhfs, "sibhfs", 2);
    if ( mxGetNumberOfElements(prhs[4]) && mxGetClassID(prhs[4]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument v2hf has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[4], (emxArray__common *)&v2hf, "v2hf", 1);
    plhs[2] = mxDuplicateArray( prhs[5]);
    if ( mxGetNumberOfElements(plhs[2]) && mxGetClassID(plhs[2]) != mxLOGICAL_CLASS)
        mexErrMsgIdAndTxt("f2hf:WrongInputType",
            "Input argument etags has incorrect data type. logical is expected.");
    alias_mxArray_to_emxArray(plhs[2], (emxArray__common *)&etags, "etags", 1);

    /* Preallocate output variables */

    /* Invoke the target function */
    f2hf_initialize();
    lfid = f2hf(fid, &faces, &tets, &sibhfs, &v2hf, &etags);
    f2hf_terminate();
    /* Marshall out function outputs */
    /* Nothing to do for plhs[0] */
    plhs[1] = copy_scalar_to_mxArray(&lfid, mxINT32_CLASS);
    if (etags.canFreeData) plhs[5] = move_emxArray_to_mxArray((emxArray__common*)&etags, mxLOGICAL_CLASS);    /* Free temporary variables */
    free_emxArray( (emxArray__common*)&faces);
    free_emxArray( (emxArray__common*)&tets);
    free_emxArray( (emxArray__common*)&sibhfs);
    free_emxArray( (emxArray__common*)&v2hf);
    free_emxArray( (emxArray__common*)&etags);}

void f2hf_usestruct_api(const mxArray ** prhs, const mxArray **plhs) {

    emxArray_int32_T     faces;
    emxArray_int32_T     tets;
    emxArray_boolean_T   etags;

    struct_T             sibhfs;
    struct_T             v2hf;
    mxArray              *_sub_mx1;

    int32_T              *fid;
    boolean_T            usestruct;
    int32_T              lfid;

    /* Marshall in function inputs */
    plhs[0] = mxDuplicateArray( prhs[0]);
    if ( mxGetNumberOfElements(plhs[0]) && mxGetClassID(plhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument fid has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(plhs[0]) != 1)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongSizeOfInputArg",
            "Argument fid should be a scalar.");
    fid = (int32_T*)mxGetData(plhs[0]);
    if ( mxGetNumberOfElements(prhs[1]) && mxGetClassID(prhs[1]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument faces has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[1], (emxArray__common *)&faces, "faces", 2);
    if ( mxGetNumberOfElements(prhs[2]) && mxGetClassID(prhs[2]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument tets has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[2], (emxArray__common *)&tets, "tets", 2);

    if ( !mxIsStruct(prhs[3]))
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument sibhfs has incorrect data type. struct is expected.");
    if ( mxGetNumberOfFields( prhs[3])!=2)
        mexWarnMsgIdAndTxt("f2hf_usestruct:InputStructWrongFields",
            "Input argument sibhfs has incorrect number of fields.");
    if ( mxGetNumberOfElements(prhs[3]) != 1)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongSizeOfInputArg",
            "Argument sibhfs must contain 1 items.");

    _sub_mx1 = mxGetField( prhs[3], 0, "cid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputStruct",
            "Input argument sibhfs does not have the field cid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument sibhfs.cid has incorrect data type. int32 is expected.");
    *(void**)&sibhfs.cid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)sibhfs.cid, "sibhfs.cid", 2);
    _sub_mx1 = mxGetField( prhs[3], 0, "lfid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputStruct",
            "Input argument sibhfs does not have the field lfid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT8_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument sibhfs.lfid has incorrect data type. int8 is expected.");
    *(void**)&sibhfs.lfid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)sibhfs.lfid, "sibhfs.lfid", 2);

    if ( !mxIsStruct(prhs[4]))
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument v2hf has incorrect data type. struct is expected.");
    if ( mxGetNumberOfFields( prhs[4])!=2)
        mexWarnMsgIdAndTxt("f2hf_usestruct:InputStructWrongFields",
            "Input argument v2hf has incorrect number of fields.");
    if ( mxGetNumberOfElements(prhs[4]) != 1)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongSizeOfInputArg",
            "Argument v2hf must contain 1 items.");

    _sub_mx1 = mxGetField( prhs[4], 0, "cid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputStruct",
            "Input argument v2hf does not have the field cid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument v2hf.cid has incorrect data type. int32 is expected.");
    *(void**)&v2hf.cid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)v2hf.cid, "v2hf.cid", 1);
    _sub_mx1 = mxGetField( prhs[4], 0, "lfid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputStruct",
            "Input argument v2hf does not have the field lfid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT8_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument v2hf.lfid has incorrect data type. int8 is expected.");
    *(void**)&v2hf.lfid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)v2hf.lfid, "v2hf.lfid", 1);
    plhs[2] = mxDuplicateArray( prhs[5]);
    if ( mxGetNumberOfElements(plhs[2]) && mxGetClassID(plhs[2]) != mxLOGICAL_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument etags has incorrect data type. logical is expected.");
    alias_mxArray_to_emxArray(plhs[2], (emxArray__common *)&etags, "etags", 1);
    if ( mxGetNumberOfElements(prhs[6]) && mxGetClassID(prhs[6]) != mxLOGICAL_CLASS)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongInputType",
            "Input argument usestruct has incorrect data type. logical is expected.");
    if ( mxGetNumberOfElements(prhs[6]) != 1)
        mexErrMsgIdAndTxt("f2hf_usestruct:WrongSizeOfInputArg",
            "Argument usestruct should be a scalar.");
    usestruct = *(boolean_T*)mxGetData(prhs[6]);

    /* Preallocate output variables */

    /* Invoke the target function */
    f2hf_initialize();
    lfid = f2hf_usestruct(fid, &faces, &tets, sibhfs, v2hf, &etags, usestruct);
    f2hf_terminate();
    /* Marshall out function outputs */
    /* Nothing to do for plhs[0] */
    plhs[1] = copy_scalar_to_mxArray(&lfid, mxINT32_CLASS);
    if (etags.canFreeData) plhs[5] = move_emxArray_to_mxArray((emxArray__common*)&etags, mxLOGICAL_CLASS);    /* Free temporary variables */
    free_emxArray( (emxArray__common*)&faces);
    free_emxArray( (emxArray__common*)&tets);
    free_emxArray( (emxArray__common*)sibhfs.lfid); mxFree( sibhfs.lfid);
    free_emxArray( (emxArray__common*)sibhfs.cid); mxFree( sibhfs.cid);

    free_emxArray( (emxArray__common*)v2hf.lfid); mxFree( v2hf.lfid);
    free_emxArray( (emxArray__common*)v2hf.cid); mxFree( v2hf.cid);

    free_emxArray( (emxArray__common*)&etags);}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Temporary copy for mex outputs. */
    mxArray *outputs[3];
    int i;
    int nOutputs = (nlhs < 1 ? 1 : nlhs);
    if (nrhs == 6) {
         if (nlhs > 3)
            mexErrMsgIdAndTxt("f2hf:TooManyOutputArguments","Too many output arguments for entry-point 'f2hf'.");
        /* Call the API function. */
    f2hf_api(prhs, (const mxArray**)outputs);
    }
    else if (nrhs == 7) {
         if (nlhs > 3)
            mexErrMsgIdAndTxt("f2hf_usestruct:TooManyOutputArguments","Too many output arguments for entry-point 'f2hf_usestruct'.");
        /* Call the API function. */
    f2hf_usestruct_api(prhs, (const mxArray**)outputs);
    }
    else
        mexErrMsgIdAndTxt("f2hf:WrongNumberOfInputs","Incorrect number of input variables for entry-point 'f2hf'.");
    /* Copy over outputs to the caller. */
    for (i = 0; i < nOutputs; ++i) {
        plhs[i] = outputs[i];
    }
}
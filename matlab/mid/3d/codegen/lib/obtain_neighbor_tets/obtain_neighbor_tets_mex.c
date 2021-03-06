/*
 * obtain_neighbor_tets_mex.c
 *
 * Auxiliary code generation for function obtain_neighbor_tets
 *
 * C source code generated by m2c.
*
 */

#include "mex.h"

#define BUILD_MEX
/* Include the C file generated by codegen in lib mode */
#include "obtain_neighbor_tets.h"
#include "m2c.c"
#include "obtain_neighbor_tets.c"
/* Include declaration of some helper functions. */
#include "lib2mex_helper.c"

void obtain_neighbor_tets_api(const mxArray ** prhs, const mxArray **plhs) {

    emxArray_int32_T     sibhfs;
    emxArray_real_T      ngbtets;

    int32_T              cid;

    /* Marshall in function inputs */
    if ( mxGetNumberOfElements(prhs[0]) && mxGetClassID(prhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets:WrongInputType",
            "Input argument cid has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(prhs[0]) != 1)
        mexErrMsgIdAndTxt("obtain_neighbor_tets:WrongSizeOfInputArg",
            "Argument cid should be a scalar.");
    cid = *(int32_T*)mxGetData(prhs[0]);
    if ( mxGetNumberOfElements(prhs[1]) && mxGetClassID(prhs[1]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets:WrongInputType",
            "Input argument sibhfs has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[1], (emxArray__common *)&sibhfs, "sibhfs", 2);

    /* Preallocate output variables */
    init_emxArray((emxArray__common*)&ngbtets, 1);

    /* Invoke the target function */
    obtain_neighbor_tets_initialize();
    obtain_neighbor_tets(cid, &sibhfs, &ngbtets);
    obtain_neighbor_tets_terminate();
    /* Marshall out function outputs */
    plhs[0] = move_emxArray_to_mxArray((emxArray__common*)&ngbtets, mxDOUBLE_CLASS);    /* Free temporary variables */
    free_emxArray( (emxArray__common*)&sibhfs);
    free_emxArray( (emxArray__common*)&ngbtets);}

void obtain_neighbor_tets_usestruct_api(const mxArray ** prhs, const mxArray **plhs) {

    emxArray_real_T      ngbtets;

    struct_T             sibhfs;
    mxArray              *_sub_mx1;

    int32_T              cid;
    boolean_T            usestruct;

    /* Marshall in function inputs */
    if ( mxGetNumberOfElements(prhs[0]) && mxGetClassID(prhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputType",
            "Input argument cid has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(prhs[0]) != 1)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongSizeOfInputArg",
            "Argument cid should be a scalar.");
    cid = *(int32_T*)mxGetData(prhs[0]);

    if ( !mxIsStruct(prhs[1]))
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputType",
            "Input argument sibhfs has incorrect data type. struct is expected.");
    if ( mxGetNumberOfFields( prhs[1])!=2)
        mexWarnMsgIdAndTxt("obtain_neighbor_tets_usestruct:InputStructWrongFields",
            "Input argument sibhfs has incorrect number of fields.");
    if ( mxGetNumberOfElements(prhs[1]) != 1)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongSizeOfInputArg",
            "Argument sibhfs must contain 1 items.");

    _sub_mx1 = mxGetField( prhs[1], 0, "cid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputStruct",
            "Input argument sibhfs does not have the field cid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputType",
            "Input argument sibhfs.cid has incorrect data type. int32 is expected.");
    *(void**)&sibhfs.cid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)sibhfs.cid, "sibhfs.cid", 2);
    _sub_mx1 = mxGetField( prhs[1], 0, "lfid");
    if ( _sub_mx1==NULL)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputStruct",
            "Input argument sibhfs does not have the field lfid.");
    if ( mxGetNumberOfElements(_sub_mx1) && mxGetClassID(_sub_mx1) != mxINT8_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputType",
            "Input argument sibhfs.lfid has incorrect data type. int8 is expected.");
    *(void**)&sibhfs.lfid = mxCalloc(1, sizeof(emxArray__common));
    alias_mxArray_to_emxArray(_sub_mx1, (emxArray__common*)sibhfs.lfid, "sibhfs.lfid", 2);
    if ( mxGetNumberOfElements(prhs[2]) && mxGetClassID(prhs[2]) != mxLOGICAL_CLASS)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongInputType",
            "Input argument usestruct has incorrect data type. logical is expected.");
    if ( mxGetNumberOfElements(prhs[2]) != 1)
        mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:WrongSizeOfInputArg",
            "Argument usestruct should be a scalar.");
    usestruct = *(boolean_T*)mxGetData(prhs[2]);

    /* Preallocate output variables */
    init_emxArray((emxArray__common*)&ngbtets, 1);

    /* Invoke the target function */
    obtain_neighbor_tets_initialize();
    obtain_neighbor_tets_usestruct(cid, sibhfs, usestruct, &ngbtets);
    obtain_neighbor_tets_terminate();
    /* Marshall out function outputs */
    plhs[0] = move_emxArray_to_mxArray((emxArray__common*)&ngbtets, mxDOUBLE_CLASS);    /* Free temporary variables */
    free_emxArray( (emxArray__common*)sibhfs.lfid); mxFree( sibhfs.lfid);
    free_emxArray( (emxArray__common*)sibhfs.cid); mxFree( sibhfs.cid);

    free_emxArray( (emxArray__common*)&ngbtets);}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs == 2) {
         if (nlhs > 1)
            mexErrMsgIdAndTxt("obtain_neighbor_tets:TooManyOutputArguments","Too many output arguments for entry-point 'obtain_neighbor_tets'.");
        /* Call the API function. */
        obtain_neighbor_tets_api(prhs, (const mxArray**)plhs);
    }
    else if (nrhs == 3) {
         if (nlhs > 1)
            mexErrMsgIdAndTxt("obtain_neighbor_tets_usestruct:TooManyOutputArguments","Too many output arguments for entry-point 'obtain_neighbor_tets_usestruct'.");
        /* Call the API function. */
        obtain_neighbor_tets_usestruct_api(prhs, (const mxArray**)plhs);
    }
    else
        mexErrMsgIdAndTxt("obtain_neighbor_tets:WrongNumberOfInputs","Incorrect number of input variables for entry-point 'obtain_neighbor_tets'.");
}
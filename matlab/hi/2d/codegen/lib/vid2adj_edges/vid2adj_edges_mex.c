/*
 * vid2adj_edges_mex.c
 *
 * Auxiliary code generation for function vid2adj_edges
 *
 * C source code generated by m2c.
*
 */

#include "mex.h"

#define BUILD_MEX
/* Include the C file generated by codegen in lib mode */
#include "vid2adj_edges.h"
#include "m2c.c"
#include "vid2adj_edges.c"
/* Include declaration of some helper functions. */
#include "lib2mex_helper.c"

void vid2adj_edges_api(const mxArray ** prhs, const mxArray **plhs) {

    emxArray_int32_T     v2hv;
    emxArray_int32_T     sibhvs;

    int32_T              vid;
    int32_T              *edge_list;
    real_T               *nedges;

    /* Marshall in function inputs */
    if ( mxGetNumberOfElements(prhs[0]) && mxGetClassID(prhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("vid2adj_edges:WrongInputType",
            "Input argument vid has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(prhs[0]) != 1)
        mexErrMsgIdAndTxt("vid2adj_edges:WrongSizeOfInputArg",
            "Argument vid should be a scalar.");
    vid = *(int32_T*)mxGetData(prhs[0]);
    if ( mxGetNumberOfElements(prhs[1]) && mxGetClassID(prhs[1]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("vid2adj_edges:WrongInputType",
            "Input argument v2hv has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[1], (emxArray__common *)&v2hv, "v2hv", 1);
    if ( mxGetNumberOfElements(prhs[2]) && mxGetClassID(prhs[2]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("vid2adj_edges:WrongInputType",
            "Input argument sibhvs has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[2], (emxArray__common *)&sibhvs, "sibhvs", 2);

    /* Preallocate output variables */
    {mwSize l_size[] = {50};
    *(void **)&edge_list = prealloc_mxArray((mxArray**)&plhs[0], mxINT32_CLASS, 1, l_size); }
    {mwSize l_size[] = {1, 1};
    *(void **)&nedges = prealloc_mxArray((mxArray**)&plhs[1], mxDOUBLE_CLASS, 2, l_size); }

    /* Invoke the target function */
    vid2adj_edges_initialize();
    vid2adj_edges(vid, &v2hv, &sibhvs, edge_list, nedges);
    vid2adj_edges_terminate();
    /* Marshall out function outputs */
    /* Nothing to do for plhs[0] */
    /* Nothing to do for plhs[1] */    /* Free temporary variables */
    free_emxArray( (emxArray__common*)&v2hv);
    free_emxArray( (emxArray__common*)&sibhvs);}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Temporary copy for mex outputs. */
    mxArray *outputs[2];
    int i;
    int nOutputs = (nlhs < 1 ? 1 : nlhs);
    if (nrhs == 3) {
         if (nlhs > 2)
            mexErrMsgIdAndTxt("vid2adj_edges:TooManyOutputArguments","Too many output arguments for entry-point 'vid2adj_edges'.");
        /* Call the API function. */
    vid2adj_edges_api(prhs, (const mxArray**)outputs);
    }
    else
        mexErrMsgIdAndTxt("vid2adj_edges:WrongNumberOfInputs","Incorrect number of input variables for entry-point 'vid2adj_edges'.");
    /* Copy over outputs to the caller. */
    for (i = 0; i < nOutputs; ++i) {
        plhs[i] = outputs[i];
    }
}
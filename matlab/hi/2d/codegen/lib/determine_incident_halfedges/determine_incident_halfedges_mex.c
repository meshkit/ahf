/*
 * determine_incident_halfedges_mex.c
 *
 * Auxiliary code generation for function determine_incident_halfedges
 *
 * C source code generated by lib2mex on: 09-Apr-2013 00:51:18
*
 */

#include "mex.h"

#define BUILD_MEX
/* Include the C file generated by codegen in lib mode */
#include "determine_incident_halfedges.c"
/* Include declaration of some helper functions. */
#include "lib2mex_helper.c"


void determine_incident_halfedges_api(const mxArray * prhs[3], const mxArray *plhs[1]) {

    emxArray_int32_T     elems;
    emxArray_int32_T     sibhes;
    emxArray_int32_T     v2he;


    int32_T              nv;

    /* Marshall in function inputs */
    if ( mxGetClassID(prhs[0]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("determine_incident_halfedges:WrongInputType",
            "Input argument nv has incorrect data type. int32 is expected.");
    if ( mxGetNumberOfElements(prhs[0]) != 1)
        mexErrMsgIdAndTxt("determine_incident_halfedges:WrongSizeOfInputArg",
            "Argument nv should be a scalar.");
    nv = *(int32_T*)mxGetData(prhs[0]);
    if ( mxGetClassID(prhs[1]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("determine_incident_halfedges:WrongInputType",
            "Input argument elems has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[1], (emxArray__common *)&elems, "elems", 2);
    if ( mxGetClassID(prhs[2]) != mxINT32_CLASS)
        mexErrMsgIdAndTxt("determine_incident_halfedges:WrongInputType",
            "Input argument sibhes has incorrect data type. int32 is expected.");
    alias_mxArray_to_emxArray(prhs[2], (emxArray__common *)&sibhes, "sibhes", 2);

    /* Preallocate output variables */
    init_emxArray((emxArray__common*)&v2he, 1);

    /* Invoke the target function */
    determine_incident_halfedges_initialize();
    determine_incident_halfedges(nv, &elems, &sibhes, &v2he);
    determine_incident_halfedges_terminate();

    /* Marshall out function outputs */
    plhs[0] = move_emxArray_to_mxArray((emxArray__common*)&v2he, mxINT32_CLASS);

    /* Free temporary variables */
    free_emxArray( (emxArray__common*)&elems);
    free_emxArray( (emxArray__common*)&sibhes);
    free_emxArray( (emxArray__common*)&v2he);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    if (nrhs == 3) {
         if (nlhs > 1)
            mexErrMsgIdAndTxt("determine_incident_halfedges:TooManyOutputArguments","Too many output arguments for entry-point 'determine_incident_halfedges'.");

        /* Call the API function. */
        determine_incident_halfedges_api(prhs, (const mxArray**)plhs);
    }

    else
        mexErrMsgIdAndTxt("determine_incident_halfedges:WrongNumberOfInputs","Incorrect number of input variables for entry-point 'determine_incident_halfedges'.");

}

/*
 * inverse_mixed_elements_mex.c
 *
 * Code generation for function 'inverse_mixed_elements'
 *
 * C source code generated on: Mon Feb 25 13:46:02 2013
 *
 */

/* Include files */
#include "mex.h"
#include "inverse_mixed_elements.h"

/* Type Definitions */

/* Function Declarations */
static void inverse_mixed_elements_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
MEXFUNCTION_LINKAGE mxArray *emlrtMexFcnProperties(void);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "inverse_mixed_elements", NULL, false, {2045744189U,2170104910U,2743257031U,4284093946U}, 0, false, 1, false };

/* Function Definitions */
static void inverse_mixed_elements_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Temporary copy for mex outputs. */
  mxArray *outputs[1];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  /* Check for proper number of arguments. */
  if(nrhs != 1) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:WrongNumberOfInputs","1 input required for entry-point 'inverse_mixed_elements'.");
  } else if(nlhs > 1) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:TooManyOutputArguments","Too many output arguments for entry-point 'inverse_mixed_elements'.");
  }
  /* Module initialization. */
  inverse_mixed_elements_initialize(&emlrtContextGlobal);
  /* Call the function. */
  inverse_mixed_elements_api(prhs,(const mxArray**)outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  inverse_mixed_elements_terminate();
}

void inverse_mixed_elements_atexit_wrapper(void)
{
  inverse_mixed_elements_atexit();
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(inverse_mixed_elements_atexit_wrapper);
  emlrtClearAllocCount(&emlrtContextGlobal, 0, 0, NULL);
  /* Dispatch the entry-point. */
  inverse_mixed_elements_mexFunction(nlhs, plhs, nrhs, prhs);
}

mxArray *emlrtMexFcnProperties(void)
{
    const char *mexProperties[] = {
        "Version",
        "EntryPoints"};
    const char *epProperties[] = {
        "Name",
        "NumberOfInputs",
        "NumberOfOutputs",
        "ConstantInputs"};
    mxArray *xResult = mxCreateStructMatrix(1,1,2,mexProperties);
    mxArray *xEntryPoints = mxCreateStructMatrix(1,1,4,epProperties);
    mxArray *xInputs = NULL;
    xInputs = mxCreateLogicalMatrix(1, 1);
    mxSetFieldByNumber(xEntryPoints, 0, 0, mxCreateString("inverse_mixed_elements"));
    mxSetFieldByNumber(xEntryPoints, 0, 1, mxCreateDoubleScalar(1));
    mxSetFieldByNumber(xEntryPoints, 0, 2, mxCreateDoubleScalar(1));
    mxSetFieldByNumber(xEntryPoints, 0, 3, xInputs);
    mxSetFieldByNumber(xResult, 0, 0, mxCreateString("7.14.0.739 (R2012a)"));
    mxSetFieldByNumber(xResult, 0, 1, xEntryPoints);

    return xResult;
}
/* End of code generation (inverse_mixed_elements_mex.c) */

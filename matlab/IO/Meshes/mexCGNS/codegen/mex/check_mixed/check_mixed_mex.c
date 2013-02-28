/*
 * check_mixed_mex.c
 *
 * Code generation for function 'check_mixed'
 *
 * C source code generated on: Mon Feb 25 13:46:02 2013
 *
 */

/* Include files */
#include "mex.h"
#include "check_mixed.h"

/* Type Definitions */

/* Function Declarations */
static void check_mixed_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
MEXFUNCTION_LINKAGE mxArray *emlrtMexFcnProperties(void);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "check_mixed", NULL, false, {2045744189U,2170104910U,2743257031U,4284093946U}, 0, false, 1, false };

/* Function Definitions */
static void check_mixed_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Temporary copy for mex outputs. */
  mxArray *outputs[2];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  /* Check for proper number of arguments. */
  if(nrhs != 5) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:WrongNumberOfInputs","5 inputs required for entry-point 'check_mixed'.");
  } else if(nlhs > 2) {
    mexErrMsgIdAndTxt("emlcoder:emlmex:TooManyOutputArguments","Too many output arguments for entry-point 'check_mixed'.");
  }
  /* Module initialization. */
  check_mixed_initialize(&emlrtContextGlobal);
  /* Call the function. */
  check_mixed_api(prhs,(const mxArray**)outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  check_mixed_terminate();
}

void check_mixed_atexit_wrapper(void)
{
  check_mixed_atexit();
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(check_mixed_atexit_wrapper);
  emlrtClearAllocCount(&emlrtContextGlobal, 0, 0, NULL);
  /* Dispatch the entry-point. */
  check_mixed_mexFunction(nlhs, plhs, nrhs, prhs);
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
    xInputs = mxCreateLogicalMatrix(1, 5);
    mxSetFieldByNumber(xEntryPoints, 0, 0, mxCreateString("check_mixed"));
    mxSetFieldByNumber(xEntryPoints, 0, 1, mxCreateDoubleScalar(5));
    mxSetFieldByNumber(xEntryPoints, 0, 2, mxCreateDoubleScalar(2));
    mxSetFieldByNumber(xEntryPoints, 0, 3, xInputs);
    mxSetFieldByNumber(xResult, 0, 0, mxCreateString("7.14.0.739 (R2012a)"));
    mxSetFieldByNumber(xResult, 0, 1, xEntryPoints);

    return xResult;
}
/* End of code generation (check_mixed_mex.c) */

% Build script for f2hf
if ~isnewer( ['../../../f2hf.' mexext], 'f2hf_mex.c', 'f2hf.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'f2hf_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../f2hf ' ];
    disp( 'run codegen/lib/f2hf/mex_f2hf.m');
    eval(cmd);
else
    fprintf( 'f2hf.%s is up to date.\n', mexext);
end

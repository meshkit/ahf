% Build script for determine_sibling_halfverts
if ~isnewer( ['../../../determine_sibling_halfverts.' mexext], 'determine_sibling_halfverts_mex.c', 'determine_sibling_halfverts.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'determine_sibling_halfverts_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../determine_sibling_halfverts ' ];
    disp( 'run 1d\codegen/lib/determine_sibling_halfverts/mex_determine_sibling_halfverts.m');
    eval(cmd);
else
    fprintf( 'determine_sibling_halfverts.%s is up to date.\n', mexext);
end

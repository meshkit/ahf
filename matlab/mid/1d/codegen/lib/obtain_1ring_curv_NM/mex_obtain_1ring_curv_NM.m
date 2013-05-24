% Build script for obtain_1ring_curv_NM
if ~isnewer( ['../../../obtain_1ring_curv_NM.' mexext], 'obtain_1ring_curv_NM_mex.c', 'obtain_1ring_curv_NM.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'obtain_1ring_curv_NM_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../obtain_1ring_curv_NM ' ];
    disp( 'run mid\1d\codegen/lib/obtain_1ring_curv_NM/mex_obtain_1ring_curv_NM.m');
    eval(cmd);
else
    fprintf( 'obtain_1ring_curv_NM.%s is up to date.\n', mexext);
end

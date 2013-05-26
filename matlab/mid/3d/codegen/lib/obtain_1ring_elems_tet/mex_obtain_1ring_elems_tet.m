% Build script for obtain_1ring_elems_tet
if ~isnewer( ['../../../obtain_1ring_elems_tet.' mexext], 'obtain_1ring_elems_tet_mex.c', 'obtain_1ring_elems_tet.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'obtain_1ring_elems_tet_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../obtain_1ring_elems_tet ' ];
    disp( 'run codegen/lib/obtain_1ring_elems_tet/mex_obtain_1ring_elems_tet.m');
    eval(cmd);
else
    fprintf( 'obtain_1ring_elems_tet.%s is up to date.\n', mexext);
end

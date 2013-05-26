% Build script for obtain_neighbor_tets
if ~isnewer( ['../../../obtain_neighbor_tets.' mexext], 'obtain_neighbor_tets_mex.c', 'obtain_neighbor_tets.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'obtain_neighbor_tets_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../obtain_neighbor_tets ' ];
    disp( 'run codegen/lib/obtain_neighbor_tets/mex_obtain_neighbor_tets.m');
    eval(cmd);
else
    fprintf( 'obtain_neighbor_tets.%s is up to date.\n', mexext);
end

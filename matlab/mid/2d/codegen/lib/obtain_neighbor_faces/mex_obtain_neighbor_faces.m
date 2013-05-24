% Build script for obtain_neighbor_faces
if ~isnewer( ['../../../obtain_neighbor_faces.' mexext], 'obtain_neighbor_faces_mex.c', 'obtain_neighbor_faces.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'obtain_neighbor_faces_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../obtain_neighbor_faces ' ];
    disp( 'run mid\2d\codegen/lib/obtain_neighbor_faces/mex_obtain_neighbor_faces.m');
    eval(cmd);
else
    fprintf( 'obtain_neighbor_faces.%s is up to date.\n', mexext);
end

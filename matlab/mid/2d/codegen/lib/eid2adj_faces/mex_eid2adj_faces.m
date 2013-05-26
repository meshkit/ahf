% Build script for eid2adj_faces
if ~isnewer( ['../../../eid2adj_faces.' mexext], 'eid2adj_faces_mex.c', 'eid2adj_faces.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'eid2adj_faces_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../eid2adj_faces ' ];
    disp( 'run mid\2d\codegen/lib/eid2adj_faces/mex_eid2adj_faces.m');
    eval(cmd);
else
    fprintf( 'eid2adj_faces.%s is up to date.\n', mexext);
end

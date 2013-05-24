% Build script for vid2adj_edges
if ~isnewer( ['../../../vid2adj_edges.' mexext], 'vid2adj_edges_mex.c', 'vid2adj_edges.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'vid2adj_edges_mex.c rtGetInf.c rtGetNaN.c rt_nonfinite.c  ' output ' ../../../vid2adj_edges ' ];
    disp( 'run codegen/lib/vid2adj_edges/mex_vid2adj_edges.m');
    eval(cmd);
else
    fprintf( 'vid2adj_edges.%s is up to date.\n', mexext);
end

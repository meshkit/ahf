% Build script for determine_sibling_halfedges
if ~isnewer( ['../../../determine_sibling_halfedges.' mexext], 'determine_sibling_halfedges_mex.c', 'determine_sibling_halfedges.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'determine_sibling_halfedges_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../determine_sibling_halfedges ' ];
    disp( 'run hi\2d\codegen/lib/determine_sibling_halfedges/mex_determine_sibling_halfedges.m');
    eval(cmd);
else
    fprintf( 'determine_sibling_halfedges.%s is up to date.\n', mexext);
end

% Build script for determine_incident_halfedges
if ~isnewer( ['../../../determine_incident_halfedges.' mexext], 'determine_incident_halfedges_mex.c', 'determine_incident_halfedges.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'determine_incident_halfedges_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../determine_incident_halfedges ' ];
    disp( 'run codegen/lib/determine_incident_halfedges/mex_determine_incident_halfedges.m');
    eval(cmd);
else
    fprintf( 'determine_incident_halfedges.%s is up to date.\n', mexext);
end

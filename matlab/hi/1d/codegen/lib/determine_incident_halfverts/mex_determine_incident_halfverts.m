% Build script for determine_incident_halfverts
if ~isnewer( ['../../../determine_incident_halfverts.' mexext], 'determine_incident_halfverts_mex.c', 'determine_incident_halfverts.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('opaque_obj.m'); dir=dir(1:end-12);


    if exist('octave_config_info', 'builtin'); output = '-o'; else output = '-largeArrayDims -output'; end
    cmd = ['mex'  ' ' dbopts ' -I"' dir 'include" -I. '  'determine_incident_halfverts_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../determine_incident_halfverts ' ];
    disp( 'run hi\1d\codegen/lib/determine_incident_halfverts/mex_determine_incident_halfverts.m');
    eval(cmd);
else
    fprintf( 'determine_incident_halfverts.%s is up to date.\n', mexext);
end

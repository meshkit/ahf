% Build script for determine_incident_halfedges
if ~isnewer( ['../../../determine_incident_halfedges.' mexext], 'determine_incident_halfedges_mex.c', 'determine_incident_halfedges.c')
    if ~exist('dbopts.m', 'file'); dbopts = ''; end
    dir = which('lib2mex'); dir=dir(1:end-10);


    if exist('octave_config_info', 'builtin'); output='-o'; else output='-output'; end 
    cmd = ['mex   ' dbopts ' -I"' dir '" -I. '  'determine_incident_halfedges_mex.c  rtGetInf.c rtGetNaN.c rt_nonfinite.c ' output ' ../../../determine_incident_halfedges ' ];
    disp( 'run codegen/lib/determine_incident_halfedges/mex_determine_incident_halfedges.m');
    eval(cmd);
else
    fprintf( 'determine_incident_halfedges.%s is up to date.\n', mexext);
end

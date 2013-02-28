% This script sets up the correct paths for AHF in MATLAB.
% If you start up MATLAB from this directory, MATLAB will automatically
% run the script startup.m, which calls this script.

% Set up projroot
projroot = which('startup_ahf');
projroot = projroot(1:end-14);

if projroot == '.'
    projroot=pwd;
end
if ispc
    projroot = strrep(projroot,'\','/');
end

addpath(projroot); %#ok<*MCAP>
addpath([projroot '/util']);
addpath([projroot '/util/CodeGen']);
addpath([projroot '/matlab/IO/Meshes']);


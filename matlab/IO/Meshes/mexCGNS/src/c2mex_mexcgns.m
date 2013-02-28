function c2mex_mexcgns(mexcgnsroot)
% Script for generating C and M-code for mexCGNS.

srcdir = 'cgnslib_2.5';
oldpwd = pwd;

if nargin<1
    mexcgnsroot = which('build_mexcgns'); mexcgnsroot(end-15:end)=[];
end

% We run in the mexCGNS directory. Change the directory first.
if ~strcmp(mexcgnsroot,'.') && ~strcmp(mexcgnsroot,pwd)
    disp(['Changing to directory ' mexcgnsroot]);
    cd(mexcgnsroot);
else
    mexcgnsroot = pwd;
end

% Generate CGNS C-files and M-files
copyfile('../share/c2mex.h', 'src');

if ~exist('../bin/c2mex', 'file')
    error(['The source code for mexCGNS does not seem to exist, but I ' ...
        'cannot generate them because c2mex is not available.']);
end

command = ['../bin/c2mex ' srcdir '/cgnslib.h -outdir src'];
system(command);

% Change directory back.
if ~strcmp(mexcgnsroot,'.') && ~strcmp(mexcgnsroot,oldpwd)
    disp(['Changing back to directory ' oldpwd]);
    cd(oldpwd);
end

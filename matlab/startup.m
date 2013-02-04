% startup script.
if exists('../startup_ahf.m', 'file')
   run('../../startup_ahf.m');
end
addpath([projroot 'matlab/1d'])
addpath([projroot 'matlab/2d'])
addpath([projroot 'matlab/3d'])
addpath([projroot 'matlab/mixed'])
addpath('test')

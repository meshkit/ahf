% startup script.
if exist('../startup_ahf.m', 'file')
   run('../startup_ahf.m');
end
addpath([projroot '/matlab/low/1d']) %#ok<*MCAP>
addpath([projroot '/matlab/low/2d'])
addpath([projroot '/matlab/low/3d'])
addpath([projroot '/matlab/low/mixed'])
addpath([projroot '/matlab/mid/1d'])
addpath([projroot '/matlab/mid/2d'])
addpath([projroot '/matlab/mid/3d'])
addpath([projroot '/matlab/mid/mixed'])
addpath([projroot '/matlab/hi/1d'])
addpath([projroot '/matlab/hi/2d'])
addpath([projroot '/matlab/hi/3d'])
addpath([projroot '/matlab/hi/mixed'])
addpath([projroot '/matlab/qual'])
addpath('test')
addpath('examples')

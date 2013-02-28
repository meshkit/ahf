function build
% Build writegmv

if strcmp(mexext, 'mex') % Octave
    command = 'mex -o ../../../util/writegmv_mex.mex -I../Source write_gmv_unst.c';
else
    command = 'mex -O -output ../../../util/writegmv -I../Source write_gmv_unst.c';
end

disp(command);
eval(command);

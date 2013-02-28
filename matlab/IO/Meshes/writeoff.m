function writeoff( fname_off, xs, fs)
% WRITEOFF   Write out file in OFF format.
% WRITEOFF( FNAME, XS, FS).

if ( size(xs,1)==3 && size(xs,2)~=3)
    error( 'coordinates must be nx3');
end

if ( size(fs,1)==3 && size(fs,2)~=3)
    error( 'triangles must be nx3');
end

% Write out in OFF format
fid = fopen(fname_off, 'Wt');
fprintf(fid, 'OFF\n');

fprintf(fid, '%d %d %d\n', size(xs,1), size(fs,1), 0);

if ( size(xs,1)==3)
    fprintf(fid, '%.16e %.16e %.16e\n', xs);
else
    fprintf(fid, '%.16e %.16e %.16e\n', xs');
end

if ( size(fs,1)==3)
   fprintf(fid, '3 %d %d %d\n', fs-1);
else
   fprintf(fid, '3 %d %d %d\n', fs'-1);
end

fclose( fid);
end

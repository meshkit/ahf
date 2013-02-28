function writepoly( fname, xs, edgs)
%WRITEPOLY    Write a curve as PSLG in .poly format for Triangle.
%    WRITEPOLY( FNAME, XS, EDGS) write out the curve into file specified 
%    by FNAME. FNAME should have suffix .poly.
%    XS is Nx2, and EDGS is Mx2.
%    If EDGS is not give, then vertices are assumed to be give in cyclic order.

fid = fopen(fname,'Wt');

% Nodes:
nnodes = size(xs,1);
fprintf(fid,'%d 2 0 0\n',nnodes);
fprintf(fid,'%d %g %g \n',[(1:nnodes); xs']);

% Segments:
if nargin>2
    nsegs = size(edgs,1);
    fprintf(fid,'%i 0 \n',nsegs); % #segs, #boundary markers=0
    fprintf(fid,'%d %d %d \n',[(1:nsegs)', edgs]);
else
    fprintf(fid,'%i 0 \n',nnodes); % #segs, #boundary markers=0
    fprintf(fid,'%d %d %d \n',[(1:nnodes); 1:nnodes; [2:nnodes,1]]);
end

% Holes:
fprintf(fid,'0\n');
% attribute and Area contraints:
fprintf(fid,'0\n');

% Close file
fclose(fid);

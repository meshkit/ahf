function writeplt_prism( fname, xs_layers, tris, flabels)
% Example use: 
% writeplt( 'fname.plt', xs_layers, tris)
% xs_layers is n*3*layers.

% Mask constrained triangles
if nargin>3 && ~isempty(flabels)
    % Mask constrained triangles
    tris(flabels~=0,:)=[];
    nv = size(xs_layers,1);
    
    % remove isolated vertices
    nodes = zeros(nv,1,'int32');
    nodes(tris(:,1))=tris(:,1);
    nodes(tris(:,2))=tris(:,2);
    nodes(tris(:,3))=tris(:,3);
    isolated = nodes==0;
    
    if any(isolated)
        xs_layers(isolated,:,:) = [];
        nodes(isolated) = [];
    
        % Construct mapping from new IDs to old IDs
        newnodes=zeros(nv,1,'int32');
        newnodes(nodes)=int32(1:size(nodes,1));
        tris(:,1)=newnodes(tris(:,1));
        tris(:,2)=newnodes(tris(:,2));
        tris(:,3)=newnodes(tris(:,3));
    end
end

nv = size( xs_layers,1);
nlayers = size(xs_layers,3);
ntris = size(tris, 1);

fid = fopen(fname, 'w');

% Write out header file
fprintf(fid, 'TITLE="%s"\n', fname);
fprintf(fid, 'VARIABLES= "x", "y", "z"');

%modified by Ying Chen, Oct 28, 2008
%fprintf(fid, '\nZONE T="00001", N=%d, E=%d, ZONETYPE=FEBRICK, DATAPACKING=POINT', nv*nlayers, ntris*(nlayers-1));
fprintf(fid, '\nZONE T="00001", N=%d, E=%d, ET=BRICK, F=FEPOINT', nv*nlayers, ntris*(nlayers-1));

for ii=1:nlayers
    fprintf(fid, '\n%g %g %g', xs_layers(:,:,ii)');
end

prisms = [tris'; tris(:,3)'; nv+tris'; nv+tris(:,3)'];

for ii=1:nlayers-1
    offset = (ii-1)*nv;

    fprintf(fid, '\n%d %d %d %d %d %d', offset + prisms);
end
fprintf(fid, '\n');

fclose( fid);

function writeUCD_prism(filename, xs_layers, tris, flabels)
%WRITEUCD   Write out triangle mesh in AVS/UCD format.
% If flabel is present, write it out also.
% writeplt( 'fname.plt', xs_layers, tris)
% xs_layers is n*3*layers.

if nargin>3
    % Mask constrained triangles
    tris(flabels~=0,:)=[];
    nv = int32(size(xs_layers,1));
    
    % remove isolated vertices
    nodes = zeros(nv,1);
    nodes(tris(:,1))=tris(:,1);
    nodes(tris(:,2))=tris(:,2);
    nodes(tris(:,3))=tris(:,3);
    isolated = nodes==0;
    
    if any(isolated)
        xs_layers(isolated,:,:) = [];
        nodes(isolated) = [];
    
        % Construct mapping from new IDs to old IDs
        newnodes=zeros(nv,1);
        newnodes(nodes)=1:size(nodes,1);
        tris(:,1)=newnodes(tris(:,1));
        tris(:,2)=newnodes(tris(:,2));
        tris(:,3)=newnodes(tris(:,3));
    end
end

nv = int32(size( xs_layers,1));
nlayers = size(xs_layers,3);
ntris = size(tris, 1);

fid = fopen(filename,'wt');

fprintf(fid,'%d %d 0 0 0\n', nv*nlayers, ntris*(nlayers-1));

if nv*nlayers>=1.e6
    pat = '%07d %0E %0E %0E\n';
elseif nv*nlayers>=1.e5
    pat = '%06d %0E %0E %0E\n';
else
    pat = '%05d %0E %0E %0E\n';
end    
    
% Write out nodes
nodes =1:double(nv);
for ii=1:nlayers
    fprintf(fid,pat,[nodes; xs_layers(:,:,ii)']);
    nodes = nodes + nv;
end

% Write out cellls
if ntris*(nlayers-1)>=1.e6
    pat = '%07d %d prism %d %d %d %d %d %d\n';
elseif ntris*(nlayers-1)>=1.e5
    pat = '%06d %d prism %d %d %d %d %d %d\n';
else
    pat = '%05d %d prism %d %d %d %d %d %d\n';
end    

triIDs = int32(1:ntris);
prisms = [int32(tris'); nv+tris'];
for ii=1:nlayers-1
    fprintf(fid,pat,[triIDs; zeros(1,ntris,'int32'); prisms]);

    prisms = prisms + nv; triIDs = triIDs+ntris;
end

fclose(fid);

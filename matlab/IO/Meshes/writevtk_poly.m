function writevtk_poly( fname_vtk, ps, ngon_n, nface_n)
nnodes=size(ps,1);
[num_per_face,numfaces] = get_nodes_or_faces_per_poly(ngon_n);
[num_per_poly,numpolys] = get_nodes_or_faces_per_poly(ngon_n);
mincoord=min(min(min(ps)));
maxcoord=max(max(max(ps)));

fid = fopen(fname_vtk, 'Wt');
fprintf(fid, '<VTKFile type="UnstructuredGrid" version="0.1" byte_order="LittleEndian">\n');
fprintf(fid, '  <UnstructuredGrid>\n');
fprintf(fid, '    <Piece NumberOfPoints="%d" NumberOfCells="%d">\n',nnodes,numpolys);
fprintf(fid, '      <PointData>\n');
fprintf(fid, '      <PointData>\n');
fprintf(fid, '      <CellData>\n');
fprintf(fid, '      <CellData>\n');
fprintf(fid, '        <DataArray type="double" Name="Points" NumberOfComponents="3" format="ascii" RangeMin="%g" RangeMax="%g">\n',mincoord,maxcoord);
% WRITE OUT THE COORDINATES
fprintf(fid, '\n%g %g %g %g %g %g', ps');

fprintf(fid, '        </DataArray>\n');
fprintf(fid, '      </Points>\n');
fprintf(fid, '      </Cells>\n');
fprintf(fid, '        <DataArray type="Int32" Name="connectivity" format="ascii" RangeMin="0" RangeMax="7">\n');



fprintf(fid, '        </DataArray>\n');
fprintf(fid, '        <DataArray type="Int32" Name="offsets" format="ascii" RangeMin="8" RangeMax="8">\n');

fprintf(fid, '        </DataArray>\n');
fprintf(fid, '        <DataArray type="UInt8" Name="types" format="ascii" RangeMin="42" RangeMax="42">\n');

%WRITE OUT THE TYPES
types=repmat(int32(42),numpolys,1);
fprintf(fid, '\n%d %d %d %d %d', types);
clear types;

fprintf(fid, '        </DataArray>\n');
fprintf(fid, '        <DataArray type="Int32" Name="faces" format="ascii" RangeMin="0" RangeMax="7">\n');

%WRITE OUT THE FACES
faces=zeros(numpolys+numfaces+sum(num_per_face),1);
faceoffsets=zeros(numpolys-1,1);
count=0;
for i=1:numpolys
    count=count+1;
    faces(count)=num_per_poly(i);
end

fprintf(fid, '        </DataArray>\n');
fprintf(fid, '        <DataArray type="Int32" Name="faceoffsets" format="ascii" RangeMin="31" RangeMax="31">\n');
     
fprintf(fid, '        </DataArray>\n');
fprintf(fid, '      </Cells>\n');
fprintf(fid, '    </Piece>\n');
fprintf(fid, '  </UnstructuredGrid>\n');
fprintf(fid, '</VTKFile>\n');

fclose(fid);
%END FUNCTION
end


function [num_per_poly,numpolys] = get_nodes_or_faces_per_poly(polys)
% Convert from the number of vertices per element into
% element_type in the connecitvity table.
es = size(polys,1);
ii=1;
numpolys = 0;

while (ii<es)
    nvpp = polys(ii);
    num_per_poly=nvpp;
    ii = ii + nvpp + 1;
    numpolys = numpolys + 1;
end

end
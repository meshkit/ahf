function writefoam_tet(ps, tets, facmap, flabels, noutlets, lagrit,...
  initialfield)
%WRITE OPENFOAM POLYMESH FILES
%
%writefoam_tet(ps, tets, facmap, flabels, noutlets)
%
%Arguements:
%   PS:         the nvx3 array of coordintate
%   TETS:       the tet connectivity
%   FACMAP:     the element and local face correspoding to BDFACE
%   FLABELS:    face labels for boundary conditions.
%               FLABEL==0 is WALL
%               FLABEL==1:NOUTLETS are outlets
%               FLABEL==NOUTLETS+1:MAX(FLABEL) ARE WALL COMPARTMENTS
%
%NOTE THE ORDERING OF FACES FOR FOAM IS NONTRIVIAL
%ALSO AS OF 2009 THERE IS NO GOOD WAY TO WRITE FOAM BINARY
%
% #####################################################################
%     NOTES ON OPENFOAM FORMAT
%     All meshes are 3D. Use single layer of cells with empty front and
%     back patches to create a 2D simulation.
%
%     Meshes are defined by five files:
%
%     points.foam:    (x y z) point locations
%
%     neighbour.foam: Cell numbers on either side of a face. Boundary faces
%                     have -1 as neighbour (<=v1.4.1) or neighbour list is
%                     truncated to only the internal faces (>=v1.5)
%
%     owner.foam:     The owner cell is the lowest numbered cell of
%                     neighbor pair in neighbor.foam
%
%     faces.foam:     For each face, an ordered list of point labels. The
%                     normal (righthand rule) should point away from the
%                     owner cell (so the boundary faces point out of the
%                     domain)
%     boundary.foam:  The wall is listed last, all other inlet/outlets BC's
%                     are written first such that the faces of the boundary
%                     condition are written in sequential order form first
%                     to last as they appear in the faces.foam file
%     variable.foam is a dummy file to use as a template in initialization
%
%     The face ordering is quite intricate:
%       - internal faces get ordered such that when stepping through the
%         higher numbered neighbouring cells in incremental order one also
%         steps through the corresponding faces in incremental order
%         (upper-triangular ordering)
%
%      - boundary faces are bunched per patch. The boundary file then tells
%        where the start and size of the patch are in the faces list. For
%        coupled faces there is an additional ordering inside the patch:
%                  * cyclics: should be ordered such that face 'i' is
%                    coupled to face 'i + size()/2' where size() is the
%                    number of faces of the patch.
%                    Additionally the 0th point of a face is considered
%                    coupled to the 0th point of its coupled face.
%                  * processor:  should be ordered such that face 'i' on
%                    one processor is coupled to face 'i' on the
%                    neighbouring processor. Same additional constraint on
%                    the order of the points in a face as cyclics.
%
%     While somewhat demanding, these rules make it so that it is
%     relatively easy to extend to n-polyhedrals based on face processing.
% #####################################################################
%
if(nargin<5)
    if(nargin==2)
        fprintf(1,'There are no boundary conidtions\n');
        fprintf(1,'Default is to set all boundary faces to "wall".\n');
        noutlets=0;
    elseif(nargin==3)
        fprintf(1,'There are no boundary conidtions\n');
        fprintf(1,'Default is to set all boundary faces to "wall".\n');
        noutlets=0;
    elseif(nargin==4)
        noutlets=max(flabels);
    end
end
if(nargin<7)
  uniform=true;
else
  uniform=false;
end
% OBTAIN THE OPEN FOAM TEMPLATES
[points_temp, boundary_temp, faces_temp, owner_temp, ...
    neighbor_temp,boundary_uniform_scalarfield_temp,...
    boundary_vectorfield_temp,boundary_nonuniform_scalarfield_temp] = ...
    of_templates();
%
% FIRST WRITE OUT THE POINTS FILE
nv=size(ps,1);
points=fopen('points.foam','Wt');

fprintf(points,points_temp);
fprintf(points,'%d\n(\n',nv);
fprintf(points,'(%20.12E %20.12E %20.12E)\n',ps');
fprintf(points,')\n');
fclose(points);
%
% DETERMINE THE FACE PAIRS
ntets=size(tets,1);
fprintf(1,'Determining half-face data structure ...\n');tic
sibhfs = determine_sibling_halffaces( nv, tets);
fprintf(1, 'Done in %e seconds.\n', toc);
fprintf(1,'Sorting and writing the ascii file ...\n');tic
nfaces=4*ntets;
%OF FOLLOWS THE CONVENTION THAT THE NORMAL (RIGHT HAND RULE
%SHOULD POINT AWAY FROM THE OWNER CELL
if(lagrit)
  facemap=[1,3,2;
           1,2,4;
           2,3,4;
           1,4,3];
else
  facemap=[1,2,3;
           1,4,2;
           2,4,3;
           1,3,4];
end
%F1       N1,N3,N2
%F2       N1,N2,N4
%F3       N2,N3,N4
%F4       N3,N1,N4
facepairs=zeros(nfaces,3);
count=0;
nborder=0;
for tet=1:ntets
    for j=1:4
        count=count+1;
        face=j;
        neighbor=int32(bitshift(uint32(sibhfs(tet,j)),-3)); % hfid2cid(sibhfs(tet,j));
        if(tet > neighbor)
            facepairs(count,1)=neighbor;
            facepairs(count,2)=tet;
            if(neighbor==0)
                facepairs(count,3)=face;
                nborder=nborder+1;
            else
                facepairs(count,3)=mod(sibhfs(tet,j),8)+1; % hfid2lfid(sibhfs(tet,j));
            end
        else
            facepairs(count,1)=tet;
            facepairs(count,2)=neighbor;
            facepairs(count,3)=face;
        end
        %
    end
end
nuniquefaces=0.5*(nfaces-nborder)+nborder;
facepairs = sortrows(facepairs,[1 2]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          WRITE THE HEADERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
faces=fopen('faces.foam','Wt');
fprintf(faces,faces_temp);
fprintf(faces,'%d\n(\n',nuniquefaces);
%
owner=fopen('owner.foam','Wt');
fprintf(owner, [owner_temp, ...
    '   note "nCells: %d nActiveFaces: %d nActivePoints: %d";\n' ...
    '                     \n' ...
    '}\n' ...
    '%d\n' ...
    '(\n'], ntets,nuniquefaces,nv, nuniquefaces);
%

neighbor_f=fopen('neighbor.foam','Wt');
fprintf(neighbor_f,[ neighbor_temp, ...
    '   note "nCells: %d nActiveFaces: %d nActivePoints: %d";\n' ...
    '                     \n' ...
    '}\n' ...
    '%d\n' ...
    '(\n'], ntets,nuniquefaces,nv, nuniquefaces);
%

boundary=fopen('boundary.foam','Wt');
fprintf(boundary,boundary_temp);
%

boundary_scalar=fopen('scalar_variable.foam','Wt');
if(uniform)
  fprintf(boundary_scalar,boundary_uniform_scalarfield_temp);
else
  fprintf(boundary_scalar,boundary_nonuniform_scalarfield_temp);
  ninternal=size(initialfield,1);
  fprintf(boundary_scalar,'%d\n',ninternal);
  fprintf(boundary_scalar,'(\n');
  for i=1:ninternal
    if(initialfield(i))
      fprintf(boundary_scalar,'initVal\n');
    else
      fprintf(boundary_scalar,'%f\n',0);
    end
  end
  fprintf(boundary_scalar,')\n');
  fprintf(boundary_scalar,'boundaryField\n');
  fprintf(boundary_scalar,'\n');
end
%

boundary_vector=fopen('vector_variable.foam','Wt');
fprintf(boundary_vector,boundary_vectorfield_temp);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          WRITE THE FACES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
facecount=0;

facenodes_buf = zeros(nuniquefaces,3);
owner_buf = zeros(nuniquefaces,1);
neighbor_buf = zeros(nuniquefaces,1);

for i=2:nfaces
    if (facepairs(i,1)>0) && ...
            ~( facepairs(i,1)==facepairs(i-1,1) && ...
            facepairs(i,2)==facepairs(i-1,2) )
        
        tet=facepairs(i,1);
        facecount=facecount+1;
        localface=facepairs(i,3);
        
        % C++ is zero based, so all IDs are subtracted by 1
        owner_buf( facecount) = tet-1;
        neighbor_buf( facecount) = facepairs(i,2)-1;
        facenodes_buf( facecount, :) = tets(tet,facemap(localface,:)) - 1;
    end
end

fprintf(faces,'3( %d %d %d )\n',facenodes_buf(1:facecount,:)');
fprintf(owner,'%d\n', owner_buf(1:facecount));
fprintf(neighbor_f,'%d\n',neighbor_buf(1:facecount));

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          WRITE THE BOUNDARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(nargin<3)
    fprintf(boundary,['(\n' ...
        '    w1\n' ...
        '    {\n' ...
        '       type            wall;\n' ...
        '       physicalType    wall;\n' ...
        '       startFace       %d;\n'],facecount);
    
    bdfacecount=0;
    fprintf(boundary_scalar,['    w1\n' ...
        '    {\n' ...
        '       type            zeroGradient;\n'...
        '     }\n']);
    fprintf(boundary_vector,['    w1\n' ...
        '    {\n' ...
        '       type            fixedValue;\n'...
        '       value           uniform (0 0 0);'...
        '     }\n']);
    for i=1:nfaces
        if(facepairs(i,1)==0)
            setsize=setsize+1;
            tet=facepairs(i,2);
            localface = facepairs(i,3);
            
            % C++ is zero based, so all IDs are subtracted by 1
            owner_buf( bdfacecount) = tet-1;
            neighbor_buf( bdfacecount) = -1;
            facenodes_buf(bdfacecount, :) = tets(tet,facemap(localface,:)) - 1;
        else
            fprintf(boundary,'        nFaces       %d;\n      }\n)', bdfacecount);
            break;
        end
    end
else
    fprintf(boundary,'(\n');
    
    bdfacecount = 0;
    for region=1:noutlets
        fprintf(boundary,['out_%d\n' ...
            '    {\n' ...
            '       type            patch;\n' ...
            '       physicalType    pressureOutlet;\n' ...
            '       startFace       %d;\n'], region, facecount);
        %
        fprintf(boundary_scalar,['out_%d\n' ...
            '    {\n' ...
            '       type            zeroGradient;\n' ...
            '    }\n'], region);
        %
        fprintf(boundary_vector,['out_%d\n' ...
            '    {\n' ...
            '       type            fixedValue;\n' ...
            '       value           uniform (0 0 0);'...
            '    }\n'], region);
        outletfaces=find(flabels==region);
        setsize=size(outletfaces,1);
        
        for i=1:setsize
            facecount=facecount+1;
            bdfacecount = bdfacecount + 1;
            
            
            tet=hfid2cid(facmap(outletfaces(i)));
            localface=hfid2lfid(facmap(outletfaces(i)));
          
            
            
            % C++ is zero based, so all IDs are subtracted by 1
            owner_buf( bdfacecount) = tet-1;
            neighbor_buf( bdfacecount) = -1;
            
            facenodes_buf( bdfacecount, :) = tets(tet,facemap(localface,:)) - 1;
        end
        fprintf(boundary,'        nFaces       %d;\n      }\n',setsize);
    end;
    
    if(max(flabels)>noutlets)
        %THERE ARE OTHER SUBDIVISIONS TO DEAL WITH
        count=0;
        for region=noutlets+1:max(flabels)
            count=count+1;
            fprintf(boundary, ['Compartment_%d\n' ...
                '    {\n' ...
                '       type            wall;\n' ...
                '       physicalType    wall;\n' ...
                '       startFace       %d;\n'], count, facecount);
            fprintf(boundary_scalar,['out_%d\n' ...
            '    {\n' ...
            '       type            zeroGradient;\n' ...
            '    }\n'], region);
            %
            fprintf(boundary_vector,['out_%d\n' ...
            '    {\n' ...
            '       type            fixedValue;\n' ...
            '       value           uniform (0 0 0);'...
            '    }\n'], region);
            outletfaces=find(flabels==region);
            setsize=size(outletfaces,1);
            
            for i=1:setsize
                facecount=facecount+1;
                bdfacecount = bdfacecount + 1;
                
                tet=hfid2cid(facmap(outletfaces(i)));
                localface=hfid2lfid(facmap(outletfaces(i)));
                  
                
                % C++ is zero based, so all IDs are subtracted by 1
                owner_buf( bdfacecount) = tet-1;
                neighbor_buf( bdfacecount) = -1;
                facenodes_buf( bdfacecount, :) = tets(tet,facemap(localface,:)) - 1;
            end
            fprintf(boundary,'        nFaces       %d;\n      }\n',setsize);
        end
    end
    
    %FINALLY WRITE OUT ANY DEFAULT WALL CONDITIONS
    wallfaces=find(flabels==0);
    setsize=size(wallfaces,1);
    if(setsize>0)
        fprintf(boundary,['    w1\n' ...
            '    {\n' ...
            '       type            wall;\n' ...
            '       physicalType    wall;\n' ...
            '       startFace       %d;\n'],facecount);
        fprintf(boundary_scalar,['w1\n' ...
            '    {\n' ...
            '       type            zeroGradient;\n' ...
            '    }\n']);
            %
         fprintf(boundary_vector,['w1\n' ...
            '    {\n' ...
            '       type            fixedValue;\n' ...
            '       value           uniform (0 0 0);'...
            '    }\n']);
        for i=1:setsize
            
            tet=hfid2cid(facmap(wallfaces(i)));
            localface=hfid2lfid(facmap(wallfaces(i)));
            
            
            bdfacecount = bdfacecount + 1;
            % C++ is zero based, so all IDs are subtracted by 1
            owner_buf( bdfacecount) = tet-1;
            neighbor_buf( bdfacecount) = -1;
            facenodes_buf( bdfacecount, :) = tets(tet,facemap(localface,:)) - 1;
        end
        fprintf(boundary,'        nFaces       %d;\n      }\n',setsize);
    end
end
    
fprintf(faces,'3( %d %d %d )\n',facenodes_buf(1:bdfacecount,:)');
fprintf(owner,'%d\n', owner_buf(1:bdfacecount));
fprintf(neighbor_f,'%d\n',neighbor_buf(1:bdfacecount));

fprintf(faces,')');
fclose(faces);

fprintf(owner,')');
fclose(owner);

fprintf(neighbor_f,')');
fclose(neighbor_f);

fprintf(boundary,')');
fclose(boundary);

fprintf(boundary_scalar,'}');
fclose(boundary_scalar);

fprintf(boundary_vector,'}');
fclose(boundary_vector);
fprintf(1, 'Done in %e seconds.\n', toc);

%END FUNCTION
end
%
%
%
%
%
%
%
function [points_temp, boundary_temp, faces_temp, owner_temp, ...
    neighbor_temp,boundary_uniform_scalarfield_temp,...
    boundary_vectorfield_temp,boundary_nonuniform_scalarfield_temp] = ...
    of_templates()
%
%POINTS
points_temp = ['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '                     \n' ...
    '    root "working/directory";\n' ...
    '    case "yourcase";\n' ...
    '    instance "constant";\n' ...
    '    local "polyMesh";\n' ...
    '                     \n' ...
    '    class vectorField;\n' ...
    '    object points;\n' ...
    '}\n'];
%
%FACES
faces_temp = ['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '                     \n' ...
    '    root "working/directory";\n' ...
    '    case "yourcase";\n' ...
    '    instance "constant";\n' ...
    '    local "polyMesh";\n' ...
    '                     \n' ...
    '    class faceList;\n' ...
    '    object faces;\n' ...
    '}\n'];
%
%OWNER
owner_temp = ['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '                     \n' ...
    '    root "working/directory";\n' ...
    '    case "yourcase";\n' ...
    '    instance "constant";\n' ...
    '    local "polyMesh";\n' ...
    '                     \n' ...
    '    class labelList;\n' ...
    '    object owner;\n'];
%
% NEIGHBOR
neighbor_temp= ['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '                     \n' ...
    '    root "working/directory";\n' ...
    '    case "yourcase";\n' ...
    '    instance "constant";\n' ...
    '    local "polyMesh";\n' ...
    '                     \n' ...
    '    class labelList;\n' ...
    '    object neighbor;\n'];
%
% BOUNDARY
boundary_temp=['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '                     \n' ...
    '    root "working/directory";\n' ...
    '    case "yourcase";\n' ...
    '    instance "constant";\n' ...
    '    local "polyMesh";\n' ...
    '                     \n' ...
    '    class polyBoundaryMesh;\n' ...
    '    object boundary;\n' ...
    '}\n'];
% BOUNDARY_SCALARFIELD
boundary_uniform_scalarfield_temp=['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '    class volScalarField;\n' ...
    '    location "0";\n' ...
    '    object scalarvariable;\n' ...
    '}\n'...
    '//*************************************//\n'...
    '\n'...
    'dimensions      [0 0 0 0 0 0 0];\n'...
    'internalField   uniform 0;\n'...
    '\n'...
    'boundaryField\n'...
    '{\n'];
boundary_nonuniform_scalarfield_temp=['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '    class volScalarField;\n' ...
    '    location "0";\n' ...
    '    object scalarvariable;\n' ...
    '}\n'...
    '//*************************************//\n'...
    '\n'...
    'dimensions      [0 0 0 0 0 0 0];\n'...
    'internalField   nonuniform List<scalar>\n'];
% BOUNDARY_VECTORFIELD
boundary_vectorfield_temp=['FoamFile\n' ...
    '{\n' ...
    '    version 2.0;\n' ...
    '    format ascii;\n' ...
    '    class volVectorField;\n' ...
    '    location "0";\n' ...
    '    object vectorvariable;\n' ...
    '}\n'...
    '//*************************************//\n'...
    '\n'...
    'dimensions      [0 0 0 0 0 0 0];\n'...
    'internalField   uniform (0 0 0);\n'...
    '\n'...
    'boundaryField\n'...
    '{\n'];
%END FUNCTION
end

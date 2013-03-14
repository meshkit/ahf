function [newnodes,newtris,label]=make_sub_mesh_tri(comp_tris,xs,closed,...
    dogears) %#codegen 
% PURPOSE: THIS FUNCTION MAKES A MESH FROM A SUBSET OF TRIANGLES
% LISTED IN COMP_LIST. THESE TRIANGLES ARE TYPICALLY A SPECIFIC
% COMPONENT OF A LARGER MESH. XS IS THE FULL LIST OF VERTICES.
% IN ESSENCE MAKE_SUB_MESH_TRI REORDERS THE DATA SO THAT THE SUBSET IS 
% CONSISTENTLY NUMBERED AND MAY BE ACTED UPON WITH THE USUAL NUMGEOM
% OPERATIONS
% IF THE OPTIONAL 'CLOSED' ARGUEMENT IS TRUE, TEH FUNCTION DETERMINES IF
% THE RESULTING MESH IS OPEN AND IF IT IS IT CLOSES IT. THE OPENING MAY
% BE NON-PLANAR. A GREEDY ALGORITHM 'GREEDYRTIANGULATE' IS CALLED TO
% STICH IT CLOSED. THIS TYPICALLY RESULTS IN A VERY POOR - BUT VALID -
% TRIANGULATION. IF THE APPLICATION REQUIRES A QUALITY TRIANGULATION, OTHER
% STEPS MUST BE TAKEN TO IMPROVE THE RESULTING CLOSED MESH
coder.extrinsic('fprintf');

if(nargin < 3)
    closed=false;
end
if(nargin<4 && closed)
    dogears=true;
elseif(nargin<5 && closed)
end
label=[];
ntris=int32(size(comp_tris,1));
pointlist=reshape(comp_tris,ntris*3,1);
[pointlist]=sort(pointlist,'ascend');
map=nullcopy(zeros(ntris*3,1,'int32'));
map(1)=pointlist(1);
count=1;
for i=2:ntris*3
    if(pointlist(i)~=pointlist(i-1))
        count=count+1;
        map(count)=pointlist(i);
    end
end

map(count+1:ntris*3)=[];
listsize=max(max(comp_tris));
invmap=nullcopy(zeros(listsize,1,'int32'));
for i=1:count
    invmap(map(i))=i;
end
newnodes=nullcopy(zeros(count,3,'int32'));
for i=1:count
    newnodes(i,1:3)=xs(map(i),1:3);
end
newtris=nullcopy(zeros(ntris,3,'int32'));
for i=1:ntris
    for j=1:3
      newtris(i,j)=invmap(comp_tris(i,j));
    end
end

nv=int32(size(newnodes,1));
if(closed)
    if(dogears)
      %FIRST REMOVE DOG EARS
      fprintf(1,'Removing dog eared triangles.\n');
      for jj=1:2
        fprintf(1,'Build half-edge data structure \n');tic;
        sibhes = determine_opposite_halfedge_tri( nv, newtris);
        toc;
        label=zeros(size(newtris,1),1,'int32');
        T=nullcopy(zeros(3,1,'int32'));
        for ii=1:int32(size(newtris,1))
          T(1)=heid2fid(sibhes(ii,1));
          T(2)=heid2fid(sibhes(ii,2));
          T(3)=heid2fid(sibhes(ii,3)); 
          if(T(1)==0 && T(2)==0)
            label(ii)=1;
          elseif(T(1)==0 && T(3)==0)
            label(ii)=1;
          elseif(T(2)==0 && T(3)==0)
            label(ii)=1;
          end
        end
        [newnodes2, newtris2] = ...
            remove_labeled_faces( newnodes, newtris, label);
        newnodes=newnodes2;
        newtris=newtris2;
        nv=int32(size(newnodes,1));
        ntris=int32(size(newtris,1));
      end
    end
%
    label=zeros(size(newtris,1),1,'int32');
    [b2v, bdedgs] = extract_border_curv_tri(nv, newtris);
    % Flip the order of edges
    bdedgs(:,[2,1]) = bdedgs(:,[1,2]);
    if(isempty(b2v))
        fprintf(1,'Mesh is already closed ...\n');
        return
    end
    nb = int32(length(b2v));

    % Verify boundary curve does not have self-intersections
    nadjbvs = zeros(nb,1,'int32');
    for ii=1:int32(size(bdedgs,1))
      nadjbvs(bdedgs(ii,1)) = nadjbvs(bdedgs(ii,1))+1;
      nadjbvs(bdedgs(ii,2)) = nadjbvs(bdedgs(ii,2))+1;
    end

    for ii=1:nb
      if nadjbvs(ii)~=2
        fprintf(1, 'Boundary vertex %d has %d incident border edges.\n',...
            b2v(ii), nadjbvs(ii));
        fprintf(1,'Input mesh is invalid.\n');
      end
    end

    % Construct half-vertex data structure
    sibhvs = determine_sibling_halfverts(nb, bdedgs);
    b2hv = determine_incident_halfverts(nb, bdedgs);
    % Arrange border edges into individual curves and fill the holes.
    verts_curv = nullcopy(zeros( nb,1,'int32'));
    flags = false(nb,1);
    component=int32(0);
    for ii=1:nb
       if flags(ii); continue; end
    
       ne = 0;
    
       % Obtain first half-vertex
       hv = b2hv(ii);
       fid = hvid2eid(hv); org = bdedgs( fid, 1); start = org;
       while ~flags( org)
         flags(org) = true;
        
         ne = ne+1; verts_curv(ne) = org;
         hv  = sibhvs( fid, 1);
         fid = hvid2eid(hv); org = bdedgs( fid,1);
       end
       verts_curv=verts_curv(1:ne);
       if start ~= org || any( nadjbvs(verts_curv(1:ne))~=2)
         fprintf(1, 'Error: Boundary curve with vertex %d has self-intersection.\n', b2v(org));
         continue;
       end
       % CLOSE THE LOOP
       tempnodes=nullcopy(zeros(ne,3,'int32'));
       tempnodes(1:ne,:)=newnodes(b2v(verts_curv(1:ne)),1:3);
       %edges=nullcopy(zeros(ne,2));
       %edges(ne,2)=1;
       %edges(1:ne,1)=1:ne;
       %edges(1:ne-1,2)=2:ne;
       %writeucd_unstr('badloop_points.inp',tempnodes,[])
       %writeucd_unstr('badloop_edges.inp',tempnodes,edges)
       pos=nullcopy(zeros(ne,1));
       pos(1)=sqrt((tempnodes(1,1)-tempnodes(ne,1))^2 + ...
                   (tempnodes(1,2)-tempnodes(ne,2))^2 + ...
                   (tempnodes(1,3)-tempnodes(ne,3))^2);
       for qq=2:ne
         dist1=sqrt((tempnodes(qq,1)-tempnodes(qq-1,1))^2 + ...
                   (tempnodes(qq,2)-tempnodes(qq-1,2))^2 + ...
                   (tempnodes(qq,3)-tempnodes(qq-1,3))^2);
         pos(qq)=pos(qq-1)+dist1;
       end
       perim=pos(ne);
       work=nullcopy(zeros(ne,1,'int32'));
       nod=nullcopy(zeros(ne,1,'int32')); nod(1:ne)=1:ne;
       temptris=nullcopy(zeros(ne-2,3,'int32'));
       indx=1;
       ntri=0;
       [ntri,temptris] = ...
           greedytriangulate(ne,nod,ntri,temptris,tempnodes,work,indx,...
           pos,perim);
       ne=int32(size(tempnodes,1));
       temptris=surface_tension(ne, temptris, tempnodes, ntri);
       %[tempnodes,temptris]=split_patch(tempnodes,temptris);
       %ntri=int32(size(temptris,1));
       %ne=int32(size(tempnodes,1));
       %temptris=surface_tension(ne, temptris, tempnodes, ntri);
       %
       newtris(ntris+1:ntris+ntri,1:3)=nullcopy(zeros(ntri,3,'int32'));
       label(ntris+1:ntris+ntri,1)=0;
       component=component+1;
       label(ntris+1:ntris+ntri,1)=component;
       for jj=1:ntri
           for kk=1:3
             newtris(ntris+jj,kk)=b2v(verts_curv(temptris(jj,kk)));
           end
       end
       ntris=ntris+ntri;
    end
end

%END FUNCTION
end

function [tempnodes,temptris]=split_patch(tempnodes,temptris)
ne=int32(size(tempnodes,1));
sibhes_tmp = determine_opposite_halfedge_tri( ne, temptris);
v2he = nullcopy(zeros(ne,1,'int32'));
v2he = determine_incident_halfedges(temptris, sibhes_tmp, v2he);
ntris=int32(size(temptris,1));
ntris_start=ntris;
map=[1 2;2 3;3 1];
for i=1:ntris_start
  for neighbor=1:3
    heid=sibhes_tmp(i, neighbor);
    if(heid>0)
      v2he(ne+1)=int32(0);
      tempnodes(ne+1,1:3)=int32(0);
      tempnodes(ne+1,1:3)=...
          mean([tempnodes(temptris(i,map(neighbor,1)),:); ...
          tempnodes(temptris(i,map(neighbor,2)),:)]);
      temptris(ntris+1:ntris+4,1:3)=nullcopy(zeros(4,3,'int32'));
      sibhes_tmp(ntris+1:ntris+4,1:3)=nullcopy(zeros(4,3,'int32'));
      [ne, ntris, temptris, sibhes_tmp, v2he] = ...
          split_edge_surf(heid, ne, ntris, ...
            temptris, sibhes_tmp, v2he);
        if(ne<size(v2he,1))
            v2he(ne+1)=[];
        end
        if(ntris<size(temptris,1))
          temptris(ntris+1:end,:)=[];
          sibhes_tmp(ntris+1:end,:)=[];
        end
    end
  end
end
%END FUNCTION
end

function temptris=surface_tension(ne, temptris,tempnodes,ntri)
sibhes_tmp = determine_opposite_halfedge_tri( ne, temptris);
v2he = nullcopy(zeros(ne,1,'int32'));
v2he = determine_incident_halfedges(temptris, sibhes_tmp, v2he);
notchanged=false;

while(~notchanged)
    notchanged=true;
    for i=1:ntri
        for neighbor=1:3
          heid=sibhes_tmp(i, neighbor);
          if(heid>0)
           TN=heid2fid(sibhes_tmp(i, neighbor));
           vids = temptris(i, 1:3);
           vcoords = tempnodes( vids,1:3);
           vcoords=reshape(vcoords',1,9);
           x1=vcoords(1);y1=vcoords(2);z1=vcoords(3);
           x2=vcoords(4);y2=vcoords(5);z2=vcoords(6);
           x3=vcoords(7);y3=vcoords(8);z3=vcoords(9);
           surface_area1=signed_triangle_area(x1,y1,z1,x2,y2,z2,x3,y3,z3);
           vids = temptris(TN, 1:3);
           vcoords = tempnodes( vids,1:3);
           vcoords=reshape(vcoords',1,9);
           x1=vcoords(1);y1=vcoords(2);z1=vcoords(3);
           x2=vcoords(4);y2=vcoords(5);z2=vcoords(6);
           x3=vcoords(7);y3=vcoords(8);z3=vcoords(9);
           surface_area2=signed_triangle_area(x1,y1,z1,x2,y2,z2,x3,y3,z3);
           presurface_area=surface_area1+surface_area2;
           % TRY FLIPPING
           [temptris, sibhes_tmp, v2he] = flip_edge_surf(heid,...
               temptris, sibhes_tmp, v2he);
           vids = temptris(i, 1:3);
           vcoords = tempnodes( vids,1:3);
           vcoords=reshape(vcoords',1,9);
           x1=vcoords(1);y1=vcoords(2);z1=vcoords(3);
           x2=vcoords(4);y2=vcoords(5);z2=vcoords(6);
           x3=vcoords(7);y3=vcoords(8);z3=vcoords(9);
           surface_area1=signed_triangle_area(x1,y1,z1,x2,y2,z2,x3,y3,z3);
           vids = temptris(TN, 1:3);
           vcoords = tempnodes( vids,1:3);
           vcoords=reshape(vcoords',1,9);
           x1=vcoords(1);y1=vcoords(2);z1=vcoords(3);
           x2=vcoords(4);y2=vcoords(5);z2=vcoords(6);
           x3=vcoords(7);y3=vcoords(8);z3=vcoords(9);
           surface_area2=signed_triangle_area(x1,y1,z1,x2,y2,z2,x3,y3,z3);
           presurface_area2=surface_area1+surface_area2;
           if(presurface_area<presurface_area2)
               if(presurface_area>0)
                 [temptris, sibhes_tmp, v2he] = flip_edge_surf(heid,...
                   temptris, sibhes_tmp, v2he, 1);
               end
           else
               notchanged=false;
           end
          end
        end
    end
end

%END FUNCTION
end

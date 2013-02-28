function testfoamdump(fname)
fprintf(1, 'Reading in volume mesh %s.\n', fname); tic;
if strcmp(fname(end-3:end),'cgns')
    [ps, tets, ~,var_nodes,~,icontab]=readcgns_Lagrit(fname);
end
fprintf(1, 'Done in %e seconds.\n', toc);
%
%    
icr1=var_nodes.icr1;
nv=size(ps,1);
fprintf(1, 'Extracting surface mesh and creating map.\n'); tic;
[b2v, bdtris, facmap] = extract_border_surf_tet(nv, tets);
fprintf(1, 'Done in %e seconds.\n', toc);
ntris=size(bdtris,1);

flabel=zeros(ntris,1,'int32');
maxicr=max(icr1);
iwall=max(icontab(3,1:maxicr));
if(~isempty(icontab))
  for i=1:ntris
    onlywall=false;
    faceicr=0;
    for j=1:3
      node=b2v(bdtris(i,j));
      if(icontab(1,icr1(node))==1 && icontab(3,icr1(node))==iwall)
          onlywall=true;
      elseif(faceicr==0)
        for kk=1:icontab(1,icr1(node))
          conkk=icontab(2+kk,icr1(node));
          if(conkk~=iwall)
             faceicr=conkk;
          end
        end
      end
    end
    if(~onlywall)
      flabel(i)=faceicr;
    end
  end
end
% CREATE SURFACE NODE LIST
xs=zeros(size(b2v,1),3);
for i=1:size(b2v,1);
    xs(i,:)=ps(b2v(i),:);
end
%
%writeucd_unstr('test_surf.inp',xs,bdtris,'',[],struct('flabel',flabel));
facecount=max(flabel);
%for i=1:ntris
%    for j=1:3
%      bdface(i,j)=b2v(bdtris(i,j));
%    end
%end

lagrit=true;
writefoam_tet( ps, tets, facmap, flabel, facecount , lagrit);
 %writefoam_tet( ps, tets);


%END FUNCTION
end
function [xs_new, elem_new, oldVID2newVID, newVID2oldVID, elemOld2elemNew] = ...
    remove_labeled_elements( xs, elem, labels) %#codegen 
% REMOVE_LABELED_ELEMENTS   Remove elements and associated vertices 
%     with nonzero labels.
% Usage: % [xs_new, elem_new, oldVID2newVID] = ...
%          remove_labeled_elements(xs, elem, labels)
%   xs is nx3, elem is mxq, where q is the number of element vertices
%   and labels is mx1.
%   In the output, the elements with zero label are 
%   sorted in the same order as during input. For vertices,
%   the mapping from old VID to new VID is also returned.

% remove isolated vertices
nv = int32(size(xs,1));
nodes = zeros(nv,1,'int32');
elemNew2elemOld = 1:int32(size(elem,1));
elemNew2elemOld(labels~=0) = [];
elem(labels~=0,:)=[];
for q=1:int32(size(elem,2));
  nodes(elem(:,q))=elem(:,q);
end
isolated = nodes==0;

% Construct mapping from new IDs to old IDs
nodes(isolated) = [];
oldVID2newVID=nullcopy(zeros(nv,1,'int32'));
oldVID2newVID(nodes)=1:int32(size(nodes,1));
oldVID2newVID(isolated) = int32(size(nodes,1))+1:nv;
newVID2oldVID = nullcopy(zeros(1,nv,'int32'));
newVID2oldVID(oldVID2newVID) = 1:nv;
xs_new = xs(newVID2oldVID(1:int32(size(nodes,1))),:);
newsize=size(oldVID2newVID(elem(:,1)),1);
elem_new=nullcopy(zeros(newsize,size(elem,2),'int32'));
for q=1:int32(size(elem,2));
  elem_new(:,q)=oldVID2newVID(elem(:,q));
end

nnew = int32(length(elemNew2elemOld));
elemOld2elemNew = nullcopy(zeros(1,nnew,'int32'));   % This is optional
elemOld2elemNew(elemNew2elemOld) = 1:nnew;

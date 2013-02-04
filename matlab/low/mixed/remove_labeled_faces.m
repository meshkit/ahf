function [xs_new, tris_new, oldVID2newVID, newVID2oldVID, trisOld2trisNew] = ...
    remove_labeled_faces( xs, tris, flabels) %#codegen 
% REMOVE_LABELED_FACES   Remove faces and associated vertices 
%     with nonzero face labels.
% Usage: % [xs_new, tris_new, oldVID2newVID] = ...
%          remove_labeled_faces(xs, tris, flabels)
%   xs is nx3, tris is mx3, and flabels is mx1.
%   In the output, the faces with zero face labels are 
%   sorted in the same order as during input. For vertices,
%   the mapping from old VID to new VID is also returned.

% remove isolated vertices
nv = int32(size(xs,1));
nodes = nullcopy(zeros(nv,1,'int32'));
trisNew2trisOld = 1:int32(size(tris,1));
trisNew2trisOld(flabels~=0) = [];
tris(flabels~=0,:)=[];
nodes(tris(:,1))=tris(:,1);
nodes(tris(:,2))=tris(:,2);
nodes(tris(:,3))=tris(:,3);
isolated = nodes==0;

% Construct mapping from new IDs to old IDs
nodes(isolated) = [];
oldVID2newVID=nullcopy(zeros(nv,1,'int32'));
oldVID2newVID(nodes)=1:int32(size(nodes,1));
oldVID2newVID(isolated) = int32(size(nodes,1))+1:nv;
newVID2oldVID=nullcopy(zeros(nv,1,'int32'));
newVID2oldVID(oldVID2newVID) = 1:nv;
xs_new = xs(newVID2oldVID(1:int32(size(nodes,1))),:);

tris_new=[oldVID2newVID(tris(:,1)), oldVID2newVID(tris(:,2)), ...
    oldVID2newVID(tris(:,3))];


nnew = int32(length(trisNew2trisOld));
trisOld2trisNew = nullcopy(zeros(1,nnew,'int32'));   % This is optional
trisOld2trisNew(trisNew2trisOld) = 1:nnew;

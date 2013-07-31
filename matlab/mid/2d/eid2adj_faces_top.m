function  [flist, nfaces, ftags]=eid2adj_faces_top(eid,edges,tris,v2he,sibhes,flist,ftags,varargin)
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen coder.typeof(int32(0), [inf,1]),coder.typeof(int32(0), [inf,3]),coder.typeof(int32(0), [inf,1]),coder.typeof(false, [inf,1])}

%#codegen eid2adj_faces_top_usestruct -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,3]),
%#codegen struct('fid',coder.typeof(int32(0), [inf,1]),'leid',coder.typeof(int8(0), [inf,1])),
%#codegen struct('fid',coder.typeof(int32(0), [inf,3]),'leid',coder.typeof(int8(0), [inf,3])),coder.typeof(int32(0), [inf,1]),
%#codegen coder.typeof(false, [inf,1]),false}


if nargin < 8 || isstruct(sibhes) || isempty(varargin{1}) || ~islogical(varargin{1})
    type_struct = false;
else
    type_struct = true;
end

% First try the manifold case
[success, flist, nfaces, ftags] = eid2adj_faces_manifold(eid,edges,tris,v2he,sibhes,flist,ftags, type_struct);

% If the above is not successful, we try the non-manifold case
if ~success
    [flist, nfaces, ftags] = eid2adj_faces_nonmanifold(eid,edges,tris,v2he,sibhes,flist,ftags,type_struct);
end
end


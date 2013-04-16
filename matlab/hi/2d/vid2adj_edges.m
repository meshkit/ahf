function [edge_list, nedges] = vid2adj_edges(vid,v2hv,sibhvs,varargin) %#codegen

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 1]),
%#codegen        coder.typeof( int32(0), [inf, 2], [1,1])}
%#codegen vid2adj_edges_buffer -args
%#codegen {int32(0), coder.typeof( int32(0), [inf, 1]),
%#codegen        coder.typeof( int32(0), [inf, 2], [1,1]), coder.typeof( int32(0),[inf,1])}

starting_half_vertex=v2hv(vid);
hvid=starting_half_vertex;
if nargin<4
    MAXEDGES=20;
    edge_list=zeros(MAXEDGES,1,'int32');
else
    assert(isa(varargin{1},'int32') && size(varargin{1},1)>=0 && size(varargin{1},2)==1);
    edge_list=varargin{1};
    edge_list(edge_list~=int32(0))=int32(0);
end
nedges=1;
edge_list(nedges,1)=hvid2eid( hvid);
while hvid
    hvid=sibhvs(hvid2eid( hvid), hvid2lvid( hvid));   % obtain local vertex ID within an edge from half-vertex ID
    if ~hvid || hvid==starting_half_vertex;   break;   end;
    nedges=nedges+1;
    edge_list(nedges,1)=hvid2eid( hvid);
end
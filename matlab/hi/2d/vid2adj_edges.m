function [edge_list, nedges] = vid2adj_edges(vid,v2hv,sibhvs,varargin) %#codegen

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 1]),
%#codegen        coder.typeof( int32(0), [inf, 2])}
%%#codegen vid2adj_edges_usestruct -args
%%#codegen {int32(0), struct('eid',coder.typeof( int32(0), [inf, 1]),'lvid',coder.typeof( int8(0), [inf, 1])),
%%#codegen        coder.typeof( int32(0), [inf, 2]),'lvid',coder.typeof( int8(0), [inf, 2])), false}


if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    MAXEDGES=50;
    edge_list=zeros(MAXEDGES,1,'int32');
end
nedges=1;
if nargin<4 || isempty(varargin{1}) || ~islogical(varargin{1})
    starting_half_vertex=v2hv(vid);
    hvid=starting_half_vertex;
    
    edge_list(nedges,1)=hvid2eid( hvid);
    while hvid
        hvid=sibhvs(hvid2eid( hvid), hvid2lvid( hvid));   % obtain local vertex ID within an edge from half-vertex ID
        if ~hvid || hvid==starting_half_vertex;   break;   end;
        nedges=nedges+1;
        edge_list(nedges,1)=hvid2eid( hvid);
    end
else
    starting_half_vertex.eid=v2hv.eid(vid);
    starting_half_vertex.lvid=v2hv.lvid(vid);
    hvid=starting_half_vertex;

    edge_list(nedges,1)=hvid2eid( hvid);
    while hvid.eid
        hvid_tmp.eid=sibhvs.eid(hvid.eid, hvid.lvid);   % obtain local vertex ID within an edge from half-vertex ID
        hvid_tmp.lvid=sibhvs.lvid(hvid.eid, hvid.lvid);
        hvid=hvid_tmp;
        if ~hvid.eid || (hvid.eid==starting_half_vertex.eid && hvid.lvid==starting_half_vertex.lvid);   break;   end;
        nedges=nedges+1;
        edge_list(nedges,1)=hvid.eid;
    end
    
end
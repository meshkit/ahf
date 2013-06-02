function [edge_list, nedges] = eid2adj_edges(eid,edges,v2hv,sibhvs,edge_list,varargin) %#codegen

%#codegen -args {int32(0), coder.typeof( int32(0), [inf, 2]), coder.typeof( int32(0), [inf, 1]),
%#codegen        coder.typeof( int32(0), [inf, 2]), coder.typeof( int32(0), [inf, 1])}
%%#codegen eid2adj_edges_usestruct -args
%%#codegen {int32(0), coder.typeof( int32(0), [inf, 2]), struct('eid',coder.typeof( int32(0), [inf, 1]),'lvid',coder.typeof( int8(0), [inf, 1])),
%%#codegen        coder.typeof( int32(0), [inf, 2]),'lvid',coder.typeof( int8(0), [inf, 2])), coder.typeof( int32(0), [inf, 1]), false}
%MAXNEDGES=50;
%edge_list=zeros(MAXNEDGES,1,'int32');
vid1=1;%edges(eid,1);    
[edge_list, nedges1] = vid2adj_edges_local(vid1,eid,v2hv,sibhvs,0,edge_list);
vid2=2;%edges(eid,2);    
[edge_list, nedges] = vid2adj_edges_local(vid2,eid,v2hv,sibhvs,nedges1,edge_list);


function [edge_list, nedges] = vid2adj_edges_local(lvid,eid,v2hv,sibhvs,nedges,edge_list)
if ~isstruct(v2hv)
    starting_half_vertex = elvids2hvid(eid, lvid); %v2hv(vid);
    hvid=starting_half_vertex;
    
    while hvid
        hvid=sibhvs(hvid2eid( hvid), hvid2lvid( hvid));   % obtain local vertex ID within an edge from half-vertex ID
        if ~hvid || hvid==starting_half_vertex;   break;   end;
        nedges=nedges+1;
        edge_list(nedges,1)=hvid2eid( hvid);
    end
else
    starting_half_vertex.eid=eid;
    starting_half_vertex.lvid=lvid;
    hvid=starting_half_vertex;

    while hvid.eid
        hvid_tmp.eid=sibhvs.eid(hvid.eid, hvid.lvid);   % obtain local vertex ID within an edge from half-vertex ID
        hvid_tmp.lvid=sibhvs.lvid(hvid.eid, hvid.lvid);
        hvid=hvid_tmp;
        if ~hvid.eid || (hvid.eid==starting_half_vertex.eid && hvid.lvid==starting_half_vertex.lvid);   break;   end;
        nedges=nedges+1;
        edge_list(nedges,1)=hvid.eid;
    end
    
end
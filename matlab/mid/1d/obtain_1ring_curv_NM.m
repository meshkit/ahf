function [ngbvs, nverts] = obtain_1ring_curv_NM...
    ( vid, edges, sibhvs, v2hv, varargin) %#codegen 
%OBTAIN_1RING_CURV Collect 1-ring vertices on non-manifold mesh.
% [NGBVS,NVERTS] = OBTAIN_1RING_CURV_NM(VID,EDGS,SIBHVS,V2HV) Collects 1-ring 
% vertices and edges of a vertex and saves them into NGBVS and NGBES. 
%
% See also OBTAIN_1RING_SURF, OBTAIN_1RING_VOL
%#codegen -args {int32(0), coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,2]),coder.typeof(int32(0), [inf,1])}
%#codegen obtain_1ring_curv_NM_usestruct -args
%#codegen {int32(0), coder.typeof(int32(0), [inf,2]),
%#codegen struct('eid',coder.typeof(int32(0), [inf,2]),  'lvid',coder.typeof(int8(0), [inf,2])),
%#codegen struct('eid',coder.typeof(int32(0), [inf,1]),  'lvid',coder.typeof(int8(0), [inf,1])),
%#codegen true}
coder.extrinsic('warning');
%assert( isa(vid, 'int32') && isa( edges, 'int32') && ...
%    isa( sibhvs, 'int32') && isa( v2hv,'int32'));

if nargin<5 || isempty(varargin{1}) || ~islogical(varargin{1})
    eid = hvid2eid(v2hv(vid));
    lid = hvid2lvid(v2hv(vid));
else
    eid = v2hv.eid(vid);
    lid = v2hv.lvid(vid);
end

MAXVALENCE=10;
ngbvs = zeros(MAXVALENCE,1,'int32');
nverts = int32(0);

if ~eid; return; end

% Collect one-ring vertices and edges
v = edges(eid, 3-lid); % another end of the edge
nverts = int32(1); ngbvs( nverts) = v;
if nargin<5 || isempty(varargin{1}) || ~islogical(varargin{1})
    opp = sibhvs(eid, lid);
else
    opp_eid=sibhvs.eid(eid, lid);
    opp_lvid=sibhvs.lvid(eid, lid);
end
if nargin<5 || isempty(varargin{1}) || ~islogical(varargin{1})
    while opp && opp~=v2hv(vid)
        if (nverts==MAXVALENCE); warning('MATLAB:MAXVALENCE','vertex %d valence exceeds MAXVALENCE=%d',vid,MAXVALENCE); end;
        
        eid = hvid2eid(opp); lid = hvid2lvid(opp);
        
        v = edges(eid, 3-lid); nverts = nverts+1; ngbvs( nverts) = v;
        
        % Next edge
        opp = sibhvs(eid, lid);
    end
else 
    while opp_eid && (opp_eid~=v2hv.eid(vid) || opp_lvid~=v2hv.lvid(vid))
        if (nverts==MAXVALENCE); warning('MATLAB:MAXVALENCE','vertex %d valence exceeds MAXVALENCE=%d',vid,MAXVALENCE); end;
        
        v = edges(opp_eid, 3-opp_lvid); nverts = nverts+1; ngbvs( nverts) = v;
       
        % Next edge
        opp_eid=sibhvs.eid(opp_eid, opp_lvid);
        opp_lvid=sibhvs.lvid(opp_eid, opp_lvid);
    end
end
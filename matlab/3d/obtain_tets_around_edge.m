function [nNtets, elms_1ring, lvid_1ring,bitmap] = ...
    obtain_tets_around_edge(itet, iface, iedge, ...
    elems, elems_offsets, elems_type, inset, reg_opphfs,...
    elms_1ring,lvid_1ring,MAX,bitmap,b) %#codegen
% Extract the tetrahedra around an edge, assuming that the edge is 
%     in the interior of the mesh.
% Input:
%     itet:  element ID of a tetrahedron
%     iface: local face ID within the tetrahedron
%     iedge: local edge ID within face <itet, iface>
% Output:
%     ntets: number of tets (if ntets>0) and error code (if <=0)
%     elms_1ring: a list of element IDs of the tets
%     lvid_1ring: a list of local vertex IDs opposite to the edge 
%          in each itet within the face that forms a counterclockwise
%          loop with the edge.

IS_BND=-1;
IS_NOT_TET=-2;
GREATER_THAN_MAX=-3;

tetface_nodes = int32([1 3 2; 1 2 4; 2 3 4; 3 1 4]);
tetface_adjlfid = int32([4 3 2; 1 3 4; 1 4 2; 1 2 3]);
tetface_edges=int32([3 2 1; 1 5 4; 2 6 5; 3 4 6]);
prev = int32([3 1 2]);
next = int32([2 3 1]);
setbitmap=true;
if(nargin<11)
  MAX = 20; % Maximum number of tets around an edge
  elms_1ring = nullcopy(zeros(1, MAX, 'int32'));
  lvid_1ring = nullcopy(zeros(1, MAX, 'int32'));
  setbitmap=false;
  bitmap=[];
  b=0;
elseif(nargin<12)
  setbitmap=false;
  bitmap=[];
  b=0;
end

iface = int32(iface);

v1 = elems(elems_offsets(itet)+tetface_nodes(iface, next(iedge)));
v2 = elems(elems_offsets(itet)+tetface_nodes(iface, iedge));

% Loop through the tetrahedra around the edge
tet_start = itet;
error = 0; 
nNtets = int32(1);
for ntets = 1:MAX
    %Determine the next tetrahedron across the shared edge
    elms_1ring(ntets) = itet;
    lvid_1ring(ntets) = tetface_nodes(iface, prev(iedge));
    opphf = reg_opphfs(itet, tetface_adjlfid(iface, iedge));

    if opphf<=0 % We have reached at boundary
        error = IS_BND; break;
    end
    
    % Locate the next tet and its local face edge containing v1-v2
    itet = int32(hfid2cid( opphf));
    if elems_type(itet) ~= 4 || inset(itet)<=0
        error = IS_NOT_TET; break;
    end
    
    if itet == tet_start
      if(setbitmap)
        %WE SET THEM ALL, EVEN IF THE CYCLE IS LARGE BECAUSE WE WANT TO
        %VISTED, ESPECIALLY THE LONG ONES ONCE
        bitmap(itet) = bitset(bitmap(itet),tetface_edges(iface,iedge),b);
      end
        break; % Finished the rotation around the edge.
    end
    
    % Locate the next local face ID.
    iface = hfid2lfid( opphf); found=false;
    for iedge = 1:3
        if elems(elems_offsets(itet) + tetface_nodes(iface,next(iedge))) == v1
            assert( elems(elems_offsets(itet)+tetface_nodes(iface,iedge)) == v2);

            found=true;
            break;
        end
    end
    assert(found);
    if(setbitmap)
      %WE SET THEM ALL, EVEN IF THE CYCLE IS LARGE BECAUSE WE WANT TO
      %VISTED, ESPECIALLY THE LONG ONES ONCE
      bitmap(itet) = bitset(bitmap(itet),tetface_edges(iface,iedge),b);
    end
    nNtets = nNtets+1;
end
if itet ~= tet_start
  error=GREATER_THAN_MAX;
end

% If error has happened, set ntets to error code, which is negative.
if error; nNtets = error; end

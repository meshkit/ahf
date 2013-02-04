function [nv_out, nf_out, tris, opphes] = split_vert_surf(heid_dst, heid_org, ...
    nv_in, nf_in, tris, opphes, v2he) %#codegen 
%SPLIT_VERT_SURF    Split a vertex into two vertices.
%
%   [NV, NF, TRIS, OPPHES] = SPLIT_VERT_SURF...
%   (HEID_DST, HEID_ORG, NV, NF, TRIS, OPPHES, V2HE) splits the 
%   vertex, which is the destination vertex of heid_dst and the origin
%   vertex of heid_org, into two vertices, inserts an edge between the
%   two vertices, and inserts two new faces. After the operation, the 
%   destination of heid_dst remains unchanged, but the origin vertex of 
%   heid_org becomes the new vertex. The new vertex is appended to the end
%   (with vertex ID NV_IN+1), and the new two triangles are appended to 
%   the end of TRIS (with face IDs NF_IN+1 and NF_IN+2).
%   TRIS and OPPHES must be of size Mx2 with M>NF_IN+1, and V2HE 
%   must be of size Nx1 with N>NV_IN.

assert( size(tris,1)>nf+1 && size(opphes,1)>nf+1);
assert( size(v2he,1)>nv);

%TODO  Vladimir should implement this. This function will supercede
%  split_vert_edge and split_vert_face, as they are both special 
%  cases of this function. Pay special attention to the case where
%  the vertex is a border vertex.

nv_out = nv_in + 1;
nf_out = nf_in + 2;

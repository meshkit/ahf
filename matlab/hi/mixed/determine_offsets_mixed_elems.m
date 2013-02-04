function offsets = determine_offsets_mixed_elems( elems)
% Determine the offsets of each element in a mixed connectivity table.
%
% OFFSETS = DETERMINE_OFFSETS_MIXED_ELEMS( ELEMS)
%
% At input, ELEMS is a column vector, with format
%     [e1_nv, e1_v1,e1_v2,..., e2_nv, e2_v1,e2_v2, ...].
% At output, OFFSETS contains the beginning position for each element
%      in elems (i.e., the index of ei_nv for the ith element).
%
% Note that you can also use this function for the table of opposite
%      half-faces (opphfs) instead of element connectivity. In this case,
%      the first input argument should have format
%      [e1_nf, e1_opphf1,e1_opphf2,..., e2_nf, e2_opphf1, e2_opphf2, ...].
%
% See also LINEARIZE_MIXED_ELEMS, REGULARIZE_MIXED_ELEMS.

%#codegen -args {coder.typeof(int32(0),[inf,1],[1,0])}

assert(size(elems,2)==1);

% Allocate memory space for elems and determine number of elems
offset=int32(1); nelems=int32(0);
while offset<size(elems,1)
    
    nelems = nelems + 1;
    offset = offset+elems(offset)+1;
end

offsets = nullcopy(zeros(nelems,1,'int32'));


% Set offset for the elements.
offset=int32(1); i=int32(1);
while offset<size(elems,1) && i<=nelems
    offsets(i) = offset;
    offset = offset+elems(offset)+1;
    i = i + 1;
end

% Reset the rest to zero.
offsets(i:end) = 0;

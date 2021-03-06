function build(varargin)

files = {'is_quadmesh', 'is_2dmesh', 'determine_border_vertices', ...
         'determine_border_vertices_vol', 'determine_sibling_halffaces', ...
         'extract_border_surf', 'nnz_elements', 'split_mixed_elems', ...
         'determine_offsets_mixed_elems', 'linearize_mixed_elems', ...
         'regularize_mixed_elems', 'merge_mixed_elems'};

for j=1:length(files)
    file = files{j};
    compile('-noinf', file, varargin{:})
end

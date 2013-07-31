function build(varargin)

files = {'construct_halfverts','construct_halfedges','construct_halffaces','test_eid2faces_top'};

for j=1:length(files)
    file = files{j};
    compile('-force -noinf', file, varargin{:})
end
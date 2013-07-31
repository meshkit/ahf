function build_queries(varargin)

files = {'vid2adj_edges','eid2adj_faces','f2hf','obtain_neighbor_faces', 'obtain_neighbor_tets'};

for j=1:length(files)
    file = files{j};
    compile('-force -noinf', file, varargin{:})
end

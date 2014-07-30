function root_tri=get_root_tri(parent_tri, level, degs_level, ntris_level)

if level<=1
    root_tri=parent_tri;
    return
end

for i=1:numel(parent_tri)
    if parent_tri(i)>ntris_level(level-1)&&parent_tri(i)<=ntris_level(level)
        curr_tri =parent_tri(i); 
        for j=level-1:-1:2
            deg =degs_level(j);
            id =ceil((curr_tri-ntris_level(j))/(deg*deg));
            curr_tri =ntris_level(j-1)+id;
        end
        j=1;deg=degs_level(j);
        root_tri =ceil((curr_tri-ntris_level(j))/(deg*deg));
    else
        error('wrong level information');
    end
end

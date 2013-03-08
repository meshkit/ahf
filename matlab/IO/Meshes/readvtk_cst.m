function [xs,elements,var_nodes,var_elems]=readvtk_cst(fname)

[xs,elems,types,var_nodes,var_elems]=readvtk_cst_core('3d.vtk');
eg=0;
fs=0;
ts=0;
p=0;
for i = 1: length(types)
    switch types(i)
	case 2
	    type = 'pt';
            n_positions=2;
	    	
	case 3
	    type = 'line';
            n_positions=3;
	    edges(eg+1,:)=elems(p+1:p+n_positions);	
	    %edge_values(eg+1)=var_elems(i);
	    eg=eg+1;
	    p=p+n_positions;	 
	case 5
	    type = 'tri';
            n_positions=4;
	    faces(fs+1,:)=elems(p+1:p+n_positions);	
	    %face_values(fs+1)=var_elems(i);
	    fs=fs+1;
	    p=p+n_positions;	 
	case 9
	    type = 'quad';
            n_positions=5;
	case 10
	    type = 'tet';
            n_positions=5;
	    tets(ts+1,:)=elems(p+1:p+n_positions);	
            %tet_values(ts+1)=var_elems(i);
	    ts=ts+1;
	    i;
	    p=p+n_positions;	 
	case 12
	    type = 'hex';
            n_positions=10;
	case 13
	    type = 'prism';
            n_positions=7;
	case 14
	    type = 'pyr';
            n_positions=6;

	otherwise
	    types(i)
            i
	    %error('Unknown element type');
    end
    
end

elements.edges=edges(:,2:3)+1;
elements.faces=faces(:,2:4)+1;
elements.tets=tets(:,2:5)+1;

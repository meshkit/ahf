function [xs,elements,var_nodes,var_elementss]=readvtk_cst(fname)

[xs,elems,types,var_nodes,var_elems]=readvtk_cst_core('3d.vtk');
eg=0;
fs=0;
ts=0;
p=0;
for i = 1 : length(types)
    switch types(i)
	case 2
	    type = 'pt';
            n_positions=2;
	    	
	case 3
	    type = 'line';
            n_positions=3;
	    edges[eg+1,:]=elems[p+1:p+n_positions];	
	    eg+=1;
	    p+=n_positions;	 
	case 5
	    type = 'tri';
            n_positions=4;
	    faces[fs+1,:]=elems[p+1:p+n_positions];	
	    fs+=1;
	    p+=n_positions+1;	 
	case 9
	    type = 'quad';
            n_positions=5;
	case 10
	    type = 'tet';
            n_positions=5;
	    tets[ts+1,:]=elems[p+1:p+n_positions];	
	    ts+=1;
	    p+=n_positions+1;	 
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
	    error('Unknown element type');
    end
    
end

elements.edges=edges;
elements.faces=faces;
elements.tets=tets;

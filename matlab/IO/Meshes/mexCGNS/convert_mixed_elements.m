function [elems,nelems] = convert_mixed_elements( elems, dim)
% Convert from the number of vertices per element into
% element_type in the connecitvity table.

%#codegen -args {coder.typeof( int32(0), [inf,1], [1,0]), int32(0)}
 
es = size(elems,1);

ii=int32(1);
nelems = int32(0);
if dim==2
    % Convert 2-D elements
    while (ii<es)
        nvpe = elems(ii);
        switch nvpe
            case 3
                elems(ii) = TRI_3;
            case 4
                elems(ii) = QUAD_4;
            case 6
                elems(ii) = TRI_6;
            case 8
                elems(ii) = QUAD_8;
            case 9
                elems(ii) = QUAD_9;
            otherwise
                error('ERROR: unknown element type with %d nodes.', nvpe);
        end
        
        ii = ii + nvpe + 1;
        nelems = nelems + 1;
    end
else
    % Convert 3-D elements
    assert(dim==3);
    while (ii<es)
        nvpe = elems(ii);
        switch nvpe
            case 4
                elems(ii) = TETRA_4;
            case 5
                elems(ii) = PYRA_5;
            case 6
                elems(ii) = PENTA_6;
            case 8
                elems(ii) = HEXA_8;
            case 10
                elems(ii) = TETRA_10;
            case 13
                elems(ii) = PYRA_13;
            case 14
                elems(ii) = PYRA_14;
            case 15
                elems(ii) = PENTA_15;
            case 18
                elems(ii) = PENTA_18;
            case 20
                elems(ii) = HEXA_20;
            case 27
                elems(ii) = HEXA_27;
            otherwise
                error('ERROR: unknown element type with %d nodes.', nvpe);
        end
        ii = ii + nvpe + 1;
        nelems = nelems + 1;
    end
end
end

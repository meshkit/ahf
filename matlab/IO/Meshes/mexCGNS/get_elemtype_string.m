function [npe, typestr] = get_elemtype_string( itype, icelldim) %#codegen
% Obtain a string of element type
% [NPE, TYPESTR] = GET_ELEMTYPE_STRING( ITYPE)
% [NPE, TYPESTR] = GET_ELEMTYPE_STRING( ITYPE, ICELLDIM)
%
% Input argument:
%     ITYPE is CGNS type ID
%     ICELLDIM is 2 or 3, and is needed only if itype is MIXED.
% Output argument:
%     NPE is the number of nodes per element
%     TYPESTR is a string for the element type.
typestr='NULL';
npe=0;

switch (itype)
    case NODE
        typestr = 'NODE';
        npe = 1;
    case BAR_2
        typestr = 'BAR_2';
        npe = 2;
    case BAR_3
        typestr = 'BAR_3';
        npe = 3;
    case TRI_3
        typestr = 'TRI_3';
        npe = 3;
    case TRI_6
        typestr = 'TRI_6';
        npe = 6;
    case QUAD_4
        typestr = 'QUAD_4';
        npe = 4;
    case QUAD_8
        typestr = 'QUAD_8';
        npe = 8;
    case QUAD_9
        typestr = 'QUAD_9';
        npe = 9;
    case TETRA_4
        typestr = 'TETRA_4';
        npe = 4;
    case TETRA_10
        typestr = 'TETRA_10';
        npe = 10;
    case PYRA_5
        typestr = 'PYRA_5';
        npe = 5;
    case PYRA_13
        typestr = 'PYRA_13';
        npe = 13;
    case PYRA_14
        typestr = 'PYRA_14';
        npe = 14;
    case PENTA_6
        typestr = 'PENTA_6';
        npe = 6;
    case PENTA_15
        typestr = 'PENTA_15';
        npe = 15;
    case PENTA_18
        typestr = 'PENTA_18';
        npe = 18;
    case HEXA_8
        typestr = 'HEXA_8';
        npe = 8;
    case HEXA_20
        typestr = 'HEXA_20';
        npe = 20;
    case HEXA_27
        typestr = 'HEXA_27';
        npe = 27;
    case MIXED
        if nargin>1 && icelldim == 2
            typestr = 'MIXED2';
        elseif nargin>1 && icelldim == 3
            typestr = 'MIXED3';
        else
            error('For mixed meshes, dimension must be 2 or 3.');
        end
        npe = 1;
        
    otherwise
        error('Error: unknown element type');
end

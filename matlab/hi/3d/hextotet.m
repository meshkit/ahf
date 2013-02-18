function [xs, tets, new_fields]=hextotet(xs, hexes, mapping, cell_fields)
% CONVERTS A HEXAHEDRAL INPUT GRID INTO A TETRAHEDRAL GRID WITH THE SAME
% NUMBER OF NODES. IF VECTORS ARE SPECIFIED THESE ARE ASSOCIATED WITH THE
% TETS. CURRENLTY NO INTERPOLATION IS DONE
%
if(mapping==5)
    hexmap=int32([1 3 2 6;
        1 4 3 8;
        5 6 8 1;
        6 3 7 8;
        1 3 6 8]);
elseif(mapping==6)
    hexmap=int32([6 7 2 8;
        2 7 3 8;
        2 4 8 3;
        5 6 2 8;
        5 2 1 8;
        1 4 8 2]);
end
nhexes=int32(size(hexes,1));
tets=nullcopy(zeros(mapping*nhexes,4,'int32'));
counter=int32(0);
%
isfield=true;
if(nargin<3)
    mapping=5;
    isfield=false;
    new_fields=[];
elseif(nargin<4)
    isfield=false;
    new_fields=[];
end
%
structfield=false;
if(isfield)
    if(isstruct(cell_fields))
        names = fieldnames(cell_fields);
        numfields=int32(size(names,1));
        structfield=true;
        for i=1:numfields
            dim1=size(cell_fields.(names{i}),1);
            dim2=size(cell_fields.(names{i}),2);
            new_fields.(names{i})=nullcopy(zeros(dim1*mapping,dim2));
        end
    else
        new_fields=nullcopy(zeros(nhexes*mapping,1));
    end
end
for i=1:nhexes
    for j=1:mapping
        counter=counter+1;
        tets(counter,:)=hexes(i,hexmap(j,:));
        if(isfield)
            if(structfield)
                for k=1:numfields
                    new_fields.(names{k})(counter,:)=...
                        cell_fields.(names{k})(i,:);
                end
            else
                new_fields(counter,:)=cell_fields(i,:); %#ok<AGROW>
            end
        end
    end
end
%END FUNCTION
end

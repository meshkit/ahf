function writegmv( fname_gmv, xs, elems, type, var_nodes, varlist_nodes, var_faces, varlist_faces)
% WRITEGMV   Write out mesh in GMV format.
%
% Example use:
% writegmv( 'fname.gmv', xs, elems)
% writegmv( 'fname.gmv', xs, elems, 'writegmv', var_nodes, 'varname_v')
% writegmv( 'fname.gmv', xs, elems, 'writegmv', var_nodes, 'varname_v', var_faces, 'varname_f')
% writegmv( 'fname.gmv', xs, elems, 'writegmv', [], '', var_faces, 'varname_f')
%
% Note: If the filename has suffix 'gmvb' or 'gmb', then it writes in binary 
% format. Otherwise, it writes in ASCII format. Note that in binary format, GMV
% uses only the first eight characters of variable names, and it would lead to
% an error if two variable names are the same for the first eight characters.
%
% See <a href="http://www-xdiv.lanl.gov/XCM/gmv/GMVHome.html">GMV's homepaeg</a>.

% Call the MEX version.
switch nargin
    case 0
        writegmv_unstr;
    case 3
        writegmv_unstr( fname_gmv, xs, elems);
    case 4
        writegmv_unstr( fname_gmv, xs, elems, type);
    case 6
        if( ~isempty(varlist_nodes) && size(var_nodes,1)~=size(xs,1));
            error('Wrong dimensions in nodal variables.');
        end
        writegmv_unstr( fname_gmv, xs, elems, type, ...
                        struct(varlist_nodes,var_nodes));
    case 8
        if( ~isempty(varlist_nodes) && size(var_nodes,1)~=size(xs,1));
            error('Wrong dimensions in nodal variables.');
        end
        if( ~isempty(varlist_faces) && size(var_faces,1)~=size(elems,1));
            error('Wrong dimensions in cell-centered variables.');
        end

        writegmv_unstr( fname_gmv, xs, elems, type, ...
                        struct(varlist_nodes,var_nodes), ...
                        struct(varlist_faces,var_faces));
    otherwise
        error('Incorrect number of arguments\n');
end

function [file_similarity] = compare_cgns(fname1, fname2)
%COMPARE_CGNS_NEW Determines if CGNS files are the same.
% COMPARE_CGNS_NEW(FILENAME1, FILENAME1) Reads both two CGNS files FILENAME1
% and FILENAME2 and determines if they are the same. Returns a 1 if they
% are the same and 0 if they are not.

% Open the CGNS file
[index_file1,ierr1] = cg_open(fname1, CG_MODE_READ);
[index_file2,ierr2] = cg_open(fname2, CG_MODE_READ);

if ierr1
    error( ['Could not open file ' fname1 ' for reading.']);
elseif ierr2
    error( ['Could not open file ' fname2 ' for reading.']);
end

% Get dimension of element(icelldim) and vertex(iphysdim)
index_base1=1;  %assume there is only one base
basename1 = char(zeros(1,32));
[basename1,icelldim1,iphysdim1,ierr1] = cg_base_read(index_file1,index_base1,...
    basename1); chk_error(ierr1);
assert(~isempty(deblank(basename1)))

% Get dimension of element(icelldim) and vertex(iphysdim)
index_base2=1;  %assume there is only one base
basename2 = char(zeros(1,32));
[basename2,icelldim2,iphysdim2,ierr2] = cg_base_read(index_file2,...
    index_base2,basename2); chk_error(ierr2);
assert(~isempty(deblank(basename2)))

% Get zone1 type */
index_zone1=1;  % assume there is only one zone
zonetype1 = char(zeros(1,32)); %#ok<NASGU>
[zonetype1,ierr1] = cg_zone_type(index_file1,index_base1,index_zone1);
chk_error(ierr1);

% Get zone2 type */
index_zone2=1;  % assume there is only one zone
zonetype2 = char(zeros(1,32)); %#ok<NASGU>
[zonetype2,ierr2] = cg_zone_type(index_file2,index_base2,index_zone2);
chk_error(ierr2);

% Check that zonetypes agree
if ~(zonetype1 == zonetype2)
    error('zonetypes do not agree');
end

% Read data
[ps1, elems1, typestr1, var_nodes1, var_cells1] = readcgns(fname1);
[ps2, elems2, typestr2, var_nodes2, var_cells2] = readcgns(fname2);

if ~isequal(size(ps1), size(ps2)) || ~isequal(size(elems1), size(elems2))
    error('Data in the input files have different sizes.');
end

% Check that ps are same
file_similarity_all = zeros(3,1);
if ((max(abs(ps1-ps2)))/max(max(max(max(abs(ps1))))) < 1e-10)
    file_similarity_all(1,1) = 1;
end

if (isempty(var_nodes1) && isempty(var_nodes2))
    file_similarity_all(2,1) = 1;
else
    % Obtain node field variables
    fieldlist_nodes1 = fieldnames(var_nodes1);
    fieldlist_nodes2 = fieldnames(var_nodes2);
    % Check that node variables are the same
    if (length(fieldlist_nodes1) == length(fieldlist_nodes2))
        fieldlist = fieldlist_nodes1;
        file_similarity_nodes = zeros(length(fieldlist),1);
        for ii =1:length(fieldlist)
            var = fieldlist{ii};
            if ((max(abs(var_nodes1.(var)-var_nodes2.(var))))/ ...
                    max(max(max(max(abs(var_nodes1.(var)))))) < 1e-10)
                file_similarity_nodes(ii,1) = 1;
            end
        end
        file_similarity_all(2,1) = min(file_similarity_nodes == 1);
    else
        error('node variable lists do not match');
    end
end

if (isempty(var_cells1) && isempty(var_cells2))
    file_similarity_all(3,1) = 1;
else
    % Obtain cell field variables
    fieldlist_cells1 = fieldnames(var_cells1);
    fieldlist_cells2 = fieldnames(var_cells2);
    % Check that cell variables are the same
    if (length(fieldlist_cells1) == length(fieldlist_cells2))
        fieldlist = fieldlist_cells1;
        file_similarity_cells = zeros(length(fieldlist),1);
        for ii =1:length(fieldlist)
            var = fieldlist{ii};
            if ((max(abs(var_cells1.(var)-var_cells2.(var))))/ ...
                    max(max(max(max(abs(var_cells1.(var)))))) < 1e-10)
                file_similarity_cells(ii,1) = 1;
            end
        end
        file_similarity_all(3,1) = min(file_similarity_cells == 1);
    else
        error('cell variable lists do not match');
    end
end

% If ps and node/cell variables are the same => file_similarity = 1
file_similarity = min(file_similarity_all);

if file_similarity
   fprintf(1, 'Files are similar.\n'); 
else
   fprintf(1, 'Files are NOT similar.\n'); 
end
end

function chk_error( ierr)
% Check whether CGNS returned an error code. If so, get error message
if ierr
    error( ['Error: ', cg_get_error()]);
end
end

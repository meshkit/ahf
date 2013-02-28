function variable=read_dyna_result(filename,nelem)
fid=fopen(filename);
variable=zeros(nelem,1);
get_nextline(fid);
get_nextline(fid);
while 1
    s = get_nextline(fid);
    if(strcmp(s,'*END'));
        break
    end
    tmp = sscanf(s, '%d %f');
    variable(tmp(1))=tmp(2);
end
fclose(fid);
%END FUNCTION
end


% Get nextline and skip empty-lines and comments
function s = get_nextline(fid)
s = fgetl(fid);
while ~feof(fid) && (isempty(s) || s(1)=='$' || s(1)==13)
    s = fgetl(fid);
end
%skip string of gaps
for i = 1 : length(s)
    if (s(i) ~= ' ')
        s = s(i:end);
        return
    end
end
s = get_nextline(fid);
end
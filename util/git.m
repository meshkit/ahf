function git( varargin)
% Wrapper function for calling git command.

% First, set default path for git. On Windows, we assume git is
% installed under CYGWIN. On UNIX, we assume git is in the path.

if ispc
    gitcom = 'c:/cygwin/bin/git';
else
    gitcom = 'git';
end

buf = char(zeros(1,1000));

n = length(gitcom) + 1;
buf(1:n) = [gitcom ' '];

for k= 1 : size(varargin,2)
    s = varargin{k};
    if k>1 && strcmp(varargin{k-1}, '-m') && s(1)~='''' && s(1)~='"'
        buf(n+1) = '"';
        n1 = n + length(varargin{k}) + 2;
        buf(n+2:n1-1) = varargin{k};
        buf(n1) = '"';
        n = n1+3;
    else
        n1 = n + length(varargin{k});

        buf(n+1:n1) = varargin{k};
        n = n1+1;
    end
    buf(n) = ' ';
end

system( buf(1:n));
end
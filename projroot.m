function dir = projroot
% Obtain root directory of AHF.

persistent buf;

if isempty(buf)
    buf = which('projroot');
    buf(end-10:end) = [];
end

dir = buf;

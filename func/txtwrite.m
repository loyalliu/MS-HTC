function txtwrite(varargin)
% This function is use for writing text files.

A = varargin{1};
filename = varargin{2};
if nargin<3
    fmt = '%d\n';
else
    fmt = varargin{3};
end

if exist(filename, 'file')&&nargin<3
    warning('File already exist, skip ...');
else
    fid = fopen(filename, 'w');
    fprintf(fid,fmt,A);
    fclose(fid);
end

end

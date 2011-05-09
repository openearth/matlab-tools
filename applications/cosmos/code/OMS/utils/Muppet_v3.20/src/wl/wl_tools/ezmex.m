function ezmex(filename,varargin),
% EZMEX Easy MEX interface
%       Compiles MEX-function consisting of one source file
%       anywhere on the path in place.
%
%       EZMEX filename ...options...
%
%       See also MEX

longfilename=which(filename);

if isempty(longfilename),
  if exist(filename)==0,
    error(sprintf('%s not found.',filename));
  end;
else,
  filename=longfilename;
end;

I=max(findstr(filename,'.'));
if isempty(I),
  error(sprintf('%s has no extension.',filename));
else,
  switch lower(filename(I:end)),
  case {'.c','.cpp','.for'},
    targetname=filename(1:(I-1));
  otherwise,
    error(sprintf('%s has unexpected extension.',filename));
  end;
end;
mex(filename,varargin{:},'-output',targetname);


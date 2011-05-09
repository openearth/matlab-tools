function h=paper(varargin);
% PAPER Use md_paper instead.

fprintf(1,'WARNING: The paper command has been replaced by md_paper.\nSame syntax, new user interface.\n');
if nargout>0,
  h=md_paper(varargin{:});
else,
  md_paper(varargin{:});
end;
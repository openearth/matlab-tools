function varargout = P061(varargin);
%P061   read/search BODC P061 parameter vocabulary
%
%    L = P061()
%    L = P061('read',1)
%
%  P061(...) = P011('listReference','P061',...) wrapper
%
%See also: P01

varargout = {P011('listReference',mfilename,varargin{:})};

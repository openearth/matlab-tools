function varargout=delete(Obj,varargin),

tp=type(Obj);
if (nargin==1) & ~strcmp(tp,'legenditem'),
  delete(handles(Obj));
else,
  if nargout>1,
    [varargout{:}]=delete(Obj.TypeInfo,varargin{:});
  elseif nargout>0,
    varargout={delete(Obj.TypeInfo,varargin{:})};
  else,
    delete(Obj.TypeInfo,varargin{:});
  end;
end;
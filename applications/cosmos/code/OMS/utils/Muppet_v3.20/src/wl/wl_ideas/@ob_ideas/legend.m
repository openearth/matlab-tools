function varargout=legend(Obj,varargin),

if nargout>1,
  [varargout{:}]=legend(Obj.TypeInfo,varargin{:});
elseif nargout>0,
  varargout={legend(Obj.TypeInfo,varargin{:})};
else,
  legend(Obj.TypeInfo,varargin{:});
end;
function varargout=addto(Obj,varargin),

try,
  if nargout>0,
    [varargout{:}]=addto(Obj.TypeInfo,varargin{:});
  else,
    addto(Obj.TypeInfo,varargin{:});
  end;
catch,
  ui_message('error',{sprintf('%s - %s:',mfilename,type(Obj)),lasterr});
end;
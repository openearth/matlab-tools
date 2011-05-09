function Obj = ob_ideas(arg1,arg2,arg3);
% OB_IDEAS is an interface for creating all IDEAS objects
%
%      Five different calls to this function can be expected:
% 
%      1. Possible=OB_IDEAS(Handle,'possible')
%         Returns a list of object types that can be created in the graphics object
%         specified by Handle.
%      2. Possible=OB_IDEAS('Type',Handle,'possible')
%         Returns 'Type' if a 'Type' object can be created in the graphics object
%         specified by Handle.
%      3. Obj=OB_IDEAS('Type',Handle)
%         To create a 'Type' object interactively.
%      4. Obj=OB_IDEAS('Type',Handle,CommandStruct)
%         To create the 'Type' object from a scriptfile
%      5. IdeasObj=OB_IDEAS(SubtypeObj)
%         To create an ideas object from a ideas subtype object.
%         Inverse of: SubtypeObj=subtype(IdeasObj).
%
%      Handle is the parent of the (handle) object to be created.

switch nargin,
case 0,
  Obj.Type='';
  Obj.Tag='';
  Obj.TypeInfo='';
  Obj=class(Obj,'ob_ideas');
case 1,
  if ~isobject(arg1),
    error('Incorrect argument.');
  else,
    arg1_class=class(arg1);
    if (length(arg1_class)<4) | (~strcmp(arg1_class(1:3),'ob_')),
      error('Incorrect argument.');
    end;
    if strcmp(arg1_class,'ob_ideas'),
      Obj=arg1;
      ui_message('warning',{'Unnecessary call to ob_ideas:',strstack});
      return;
    end;
    struct_arg1=struct(arg1);
    Obj.Type=arg1_class(4:end);
    Obj.Tag=struct_arg1.Tag;
    Obj.TypeInfo=arg1;
    Obj=class(Obj,'ob_ideas');
  end;
case 2,
  if ischar(arg2) & isequal(arg2,'possible'), % Possibility 1: Possible=OB_IDEAS(Handle,'possible')

    Obj=strvcat( ...
         ob_line(arg1,'possible'), ...
         ob_quiver(arg1,'possible'), ...
         ob_surface(arg1,'possible'), ...
         ob_trisurface(arg1,'possible'));

  elseif ischar(arg1), % Possibility 3: Obj=OB_IDEAS('Type',Handle)
    Obj.Type=arg1;
    Obj.Tag=ideastag;
    Obj.TypeInfo=call_subtype(Obj.Type,'createobject',Obj.Tag);
    if isempty(Obj.TypeInfo),
      Obj.Type='';
      Obj=class(Obj,'ob_ideas');
      return;
    end;
    Obj=class(Obj,'ob_ideas');
    H=call_subtype(Obj.Type,Obj,arg2);
    if isempty(H),
      Obj.Type='';
      Obj.TypeInfo=[];
    end;
  end;
case 3,
  if ischar(arg3) & isequal(arg3,'possible'), % Possibility 2: Possible=OB_IDEAS('Type',Handle,'possible')
    if ischar(arg1),
      Obj=char(call_subtype(Obj.Type,arg1,'possible'));
    else,
      error('Invalid first argument.');
    end;
  elseif ischar(arg1), % Possibility 4: Obj=OB_IDEAS('Type',Handle,CommandStruct)
    Obj.Type=arg1;
    Obj.Tag=ideastag;
    Obj.TypeInfo=call_subtype(Obj.Type,'createobject',Obj.Tag);
    if isempty(Obj.TypeInfo),
      Obj.Type='';
    end;
    Obj=class(Obj,'ob_ideas');
    H=call_subtype(Obj.Type,Obj,arg2,arg3);
  end;
end;


function TypeInfo=call_subtype(Type,varargin);
switch Type,
case 'surface',
  TypeInfo=ob_surface(varargin{:});
case 'trisurface',
  TypeInfo=ob_trisurface(varargin{:});
case 'quiver',
  TypeInfo=ob_quiver(varargin{:});
case 'line',
  TypeInfo=ob_line(varargin{:});
case 'axes',
  TypeInfo=ob_axes(varargin{:});
case 'legend',
  TypeInfo=ob_legend(varargin{:});
case 'legenditem',
  TypeInfo=ob_legenditem(varargin{:});
case 'counter',
  TypeInfo=ob_counter(varargin{:});
case 'dummy',
  TypeInfo=ob_dummy(varargin{:});
otherwise,
  TypeInfo=[];
  if ischar(Type),
    ui_message('error',['Unknown object type ID: ',Type]);
  else,
    ui_message('error',['Object type ID must be char, not of class: ',class(Type)]);
  end;
end;

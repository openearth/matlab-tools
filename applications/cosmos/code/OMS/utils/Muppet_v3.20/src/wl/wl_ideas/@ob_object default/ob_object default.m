function Obj=ob_<SPECIFY>(arg1,arg2,arg3);
% OB_<SPECIFY> is an interface for creating a <SPECIFY>
%
%      Five different calls to this function can be expected:
% 
%      1. Obj=OB_XXX(PHandle)
%         To create the object interactively; forwarded to ob_ideas.
%      2. Obj=OB_XXX(PHandle,CommandStruct)
%         To create the object from a scriptfile; forwarded to ob_ideas.
%      3. Possible=OB_XXX(PHandle,'possible')
%         Returns the object name if it can be created in the PHandle.
%      4. Obj=OB_XXX(IDEASTag,PHandle)
%         To create the object interactively.
%      5. Obj=OB_XXX(IDEASTag,PHandle,CommandStruct)
%         To create the object from a scriptfile
%
%      PHandle is the handle of the object in which to plot the object

Obj=[];
subtype='<SPECIFY>';

switch nargin,
case 0, % no argument 1: Obj=OB_XXX(gca)
  Obj=ob_ideas(subtype,gca);
case 1, % Possibility 1: Obj=OB_XXX(<PHandle>)
  Obj=ob_ideas(subtype,arg1);
case 2,
  if ischar(arg1), % Possibility 4: Obj=OB_XXX(IDEASTag,<PHandle>)
    Obj=Local_create(arg1,arg2);
    if ~edit(Obj),
      delete(Obj);
      Obj=[];
    end;
  elseif ischar(arg2) & isequal(arg2,'possible'), % Possibility 3: Possible=OB_XXX(<PHandle>,'possible')
    if ispossible(arg1),
      Obj=subtype;
    else,
      Obj='';
    end;
  else, % Possibility 2: Possible=OB_XXX(<PHandle>,CmdStruct)
    Obj=ob_ideas(subtype,arg1,arg2);
  end;
case 3, % Possibility 5: Possible=OB_XXX(IDEASTag,<PHandle>,CmdStruct)
  Obj=Local_create(arg1,arg2,arg3);
end;


function possible=ispossible(PHandle),
ParentOptions=get(PHandle,'userdata');
% check here the parent conditions which are required for the creation of the object
% e.g. AxesTypes={'undefined','2DH','3D'};
%      possible=~isempty(strmatch(ParentOptions.Type,AxesTypes,'exact'));
possible=0;


function Obj=Local_create(Tag,PHandle,CmdStruct),
Obj.Tag=Tag;
Obj=class(Obj,'ob_<SPECIFY>');

UD.PTag='main';
UD.Info.Version=1; % version number
UD.Info.Visible=1;
% ---------
% UD.Info.<other options>
% ---------
UD.Info.Name='<SPECIFY>';
UD.Name=UD.Info.Name;
UD.Object=Obj;

% ----------
% Create default item
% ----------
% S=surface('parent',PHandle, ...
%      'tag',Tag, ...
%      'visible','off');

% set to desired axes type
% e.g. Local_SetAx_2DH(PHandle);

if nargin>2, % CmdStruct
  if isfield(CmdStruct,'Type'),
    % select preset Type
    switch CmdStruct.Type,
    case '<SPECIFY>',
      UD.Name=CmdStruct.Name;
      UD.Info.Name=CmdStruct.Name;
      % UD.info.<other options>
      set(S,'userdata',UD);
      refresh(Obj)
    otherwise,
      uiwait(msgbox('Unknown object type specification.','modal'));
    end;
  else,
    uiwait(msgbox('Unknown object type specification.','modal'));   
  end;
end;

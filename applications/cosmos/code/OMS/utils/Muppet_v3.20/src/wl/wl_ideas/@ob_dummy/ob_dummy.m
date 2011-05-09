function Obj=ob_legend(arg1,arg2,arg3);
% OB_LEGEND is an interface for creating a legend area
%
%      Six different calls to this function can be expected:
% 
%      1. Obj=OB_XXX(PHandle)
%         To create the object interactively; forwarded to ob_ideas.
%      2. Obj=OB_XXX(PHandle,CommandStruct)
%         To create the object from a scriptfile; forwarded to ob_ideas.
%      3. Possible=OB_XXX(PHandle,'possible')
%         Returns the object name if it can be created in the PHandle.
%      4. Handles=OB_XXX(Obj,PHandle)
%         To create the object graphics interactively.
%      5. Handles=OB_XXX(Obj,PHandle,CommandStruct)
%         To create the object graphics from a scriptfile
%      6. Obj=OB_XXX('createobject',IDEASTag)
%         To create the object
%
%      PHandle is the handle of the axes object in which to plot the object

Obj=[];
subtype='dummy';

switch nargin,
case 0, % no argument 1: Obj=OB_XXX(gcf)
  Obj=ob_ideas(subtype,gcf);
case 1, % Possibility 1: Obj=OB_XXX(<PHandle>)
  Obj=ob_ideas(subtype,arg1);
case 2,
  if ischar(arg2) & isequal(arg2,'possible'), % Possibility 3: Possible=OB_XXX(<PHandle>,'possible')
    if ispossible(arg1),
      Obj=subtype;
    else,
      Obj='';
    end;
  elseif ischar(arg1) & isequal(arg1,'createobject'), % Possibility 6: Obj=OB_XXX('createobject',IDEASTag)
    Obj.Tag=arg2;
    Obj=class(Obj,['ob_' subtype]);
  elseif ishandle(arg1), % Possibility 2: Possible=OB_XXX(<PHandle>,CmdStruct)
    Obj=ob_ideas(subtype,arg1,arg2);
  else, % Possibility 4: Handles=OB_XXX(Obj,<PHandle>)
    Obj=Local_create(arg1,arg2);
    if ~edit(arg1),
      delete(arg1);
      Obj=[];
    end;
  end;
case 3, % Possibility 5: Handles=OB_XXX(Obj,<PHandle>,CmdStruct)
  Obj=Local_create(arg1,arg2,arg3);
end;


function possible=ispossible(PHandle),
ParentOptions=get(PHandle,'userdata');
% check here the parent conditions which are required for the creation of the object
% e.g. AxesTypes={'undefined','2DH','3D'};
%      possible=~isempty(strmatch(ParentOptions.Type,AxesTypes,'exact'));
if strcmp(get(PHandle,'type'),'figure'),
  possible=1;
else,
  possible=0;
end;


function Handles=Local_create(Obj,PHandle,CmdStruct),
Tag=tag(Obj);

UD.PTag='main';
UD.Info.Version=1; % version number
% ---------
% UD.Info.<other options>
% ---------
UD.Info.Name='dummy';
UD.Name=UD.Info.Name;
UD.Object=Obj;

% ----------
% Create default item
% ----------

% set to desired axes type
% e.g. Local_SetAx_2DH(PHandle);

if nargin>2, % CmdStruct
  UD.Name=CmdStruct.Name;
  UD.Info.Name=CmdStruct.Name;
  UD.Info.Info=CmdStruct.Info;
  % UD.info.<other options>

  Handles=CmdStruct.Handles;
else, % interactive
  UD.Info.Name='User defined object.';
  UD.Info.Info=[];
  Handles=[];
end;

if isempty(Handles),
  switch get(PHandle,'type'),
  case 'axes',
    Handles=line([0 1],[0 1],'visible','off','parent',PHandle);
    set(Handles,'xdata',[],'ydata',[]);
  case 'figure',
    Handles=axes('visible','off','parent',PHandle);
  end;
end;

set(Handles,'tag',Tag);
set(Handles(1),'userdata',UD);
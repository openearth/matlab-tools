function Obj=ob_line(arg1,arg2,arg3);
% OB_line is an interface for creating a line
%
%      Five different calls to this function can be expected:
%
%      1. Obj=OB_XXX(Axes)
%         To create the object interactively; forwarded to ob_ideas.
%      2. Obj=OB_XXX(Axes,CommandStruct)
%         To create the object from a scriptfile; forwarded to ob_ideas.
%      3. Possible=OB_XXX(Axes,'possible')
%         Returns the object name if it can be created in the Axes.
%      4. Handles=OB_XXX(Obj,Axes)
%         To create the object graphics interactively.
%      5. Handles=OB_XXX(Obj,Axes,CommandStruct)
%         To create the object graphics from a scriptfile
%      6. Obj=OB_XXX('createobject',IDEASTag)
%         To create the object
%
%      Axes is the handle of the axes object in which to plot the object

Obj=[];
subtype='line';

switch nargin,
case 0, % no argument 1: Obj=OB_XXX(gca)
  Obj=ob_ideas(subtype,gca);
case 1, % Possibility 1: Obj=OB_XXX(Axes)
  Obj=ob_ideas(subtype,arg1);
case 2,
  if ischar(arg2) & isequal(arg2,'possible'), % Possibility 3: Possible=OB_XXX(Axes,'possible')
    if ispossible(arg1),
      Obj=subtype;
    else,
      Obj='';
    end;
  elseif ischar(arg1) & isequal(arg1,'createobject'), % Possibility 6: Obj=OB_XXX('createobject',IDEASTag)
    Obj.Tag=arg2;
    Obj=class(Obj,['ob_' subtype]);
  elseif ishandle(arg1), % Possibility 2: Possible=OB_XXX(Axes,CmdStruct)
    Obj=ob_ideas(subtype,arg1,arg2);
  else, % Possibility 4: Handles=OB_XXX(Obj,Axes)
    Obj=Local_create(arg1,arg2);
    if ~edit(arg1),
      delete(arg1);
      Obj=[];
    end;
  end;
case 3, % Possibility 5: Handles=OB_XXX(Obj,Axes,CmdStruct)
  Obj=Local_create(arg1,arg2,arg3);
end;


function possible=ispossible(PHandle),
ParentOptions=get(PHandle,'userdata');
% check here the parent conditions which are required for the creation of the object
% e.g. AxesTypes={'undefined','2DH','3D'};
%      possible=~isempty(strmatch(ParentOptions.Type,AxesTypes,'exact'));
AxesTypes={'undefined','2DH','3D'};
possible=~isempty(strmatch(ParentOptions.Type,AxesTypes,'exact'));


function Handles=Local_create(Obj,Axes,CmdStruct),
Tag=tag(Obj);

UD.PTag='main';
UD.Info.Version=1; % version number
UD.Info.Visible=1;
UD.Info.Clipped=0;
UD.Info.LMode='xy line';
UD.Info.Name='empty line';
UD.Info.X0Stream=datastream;
UD.Info.Y0Stream=datastream;
UD.Info.Z0Stream=datastream;
UD.Info.XStream=datastream;
UD.Info.YStream=datastream;
UD.Info.ZStream=datastream;
UD.Info.CStream='copyz';
UD.Info.CMode='continuous';
UD.Info.CCLim='auto';
UD.Info.CCMap='jet';
UD.Info.CThresholds=[];
UD.Info.CClassColors=[1 1 1];
UD.Info.TStream=datastream;
UD.Info.TValues={};
UD.Info.TUnit='days';
UD.Info.TUnitNum=1;
UD.Info.ShowFrame=[];
UD.Info.ShowTime=[];
UD.Name=UD.Info.Name;
UD.Object=Obj;

% ----------
% Create default item
% ----------
Handles=line('parent',Axes, ...
     'tag',Tag, ...
     'xdata',[], ...
     'ydata',[], ...
     'zdata',[], ...
     'visible','off', ...
     'userdata',UD);

% set to desired axes type
% e.g. Local_SetAx_2DH(PHandle);

if nargin>2, % CmdStruct
  if isfield(CmdStruct,'Type'),
    % select preset Type
    switch CmdStruct.Type,
    case 'line',
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

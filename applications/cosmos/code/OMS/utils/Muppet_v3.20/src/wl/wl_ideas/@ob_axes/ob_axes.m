function Obj=ob_axes(arg1,arg2,arg3);
% OB_AXES is an interface for creating an axes
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
subtype='axes';

switch nargin,
case 0, % no argument 1: Obj=OB_XXX(gcf)
  Obj=ob_ideas(subtype,gcf);
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
if strcmp(get(PHandle,'type'),'figure'),
  possible=1;
else,
  possible=0;
end;


function Obj=Local_create(Tag,PHandle,CmdStruct),
Obj.Tag=Tag;
Obj=class(Obj,'ob_axes');

UD.PTag='main';
UD.Info.Version=1; % version number
UD.Info.Visible=1;
UD.Info.Type='undefined';
UD.Info.X.Lim='auto';
UD.Info.X.Lbl='';
UD.Info.X.LblAlignment='center';
UD.Info.X.Grid=0;
UD.Info.Y.Lim='auto';
UD.Info.Y.Lbl='';
UD.Info.Y.LblAlignment='center';
UD.Info.Y.Grid=0;
UD.Info.Z.Lim='auto';
UD.Info.Z.Lbl='';
UD.Info.Z.LblAlignment='center';
UD.Info.Z.Grid=0;
% ---------
% UD.Info.<other options>
% ---------
UD.Info.Name='axes';
UD.Name=UD.Info.Name;
UD.Object=Obj;

% ----------
% Create default item
% ----------
S=axes('parent',PHandle, ...
       'xlim',[0 1], ...
       'ylim',[0 1], ...
       'zlim',[0 1], ...
       'xtick',[], ...
       'ytick',[], ...
       'ztick',[], ...
       'box','on', ...
       'tag',Tag, ...
       'color','w', ...
       'userdata',UD, ...
       'visible','on');

% set to desired axes type
% e.g. xx_setax(PHandle,'2DH');

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

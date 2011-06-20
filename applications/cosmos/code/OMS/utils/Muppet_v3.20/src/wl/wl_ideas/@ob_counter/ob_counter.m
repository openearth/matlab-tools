function Obj=ob_counter(arg1,arg2,arg3);
% OB_COUNTER is an interface for creating a counter or clock
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
subtype='counter';

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
UD.Info.Visible=1;
UD.Info.CounterType='none';
% ---------
% UD.Info.<other options>
UD.Info.Value=0;
UD.Info.Reference=0;
UD.Info.Minimum=-inf;
UD.Info.Maximum=inf;

UD.Info.SHVis=1;
UD.Info.MHVis=1;
UD.Info.HHVis=1;
UD.Info.AMVis=1;

UD.Info.OldLink=[];
UD.Info.Link=[];
% ---------
UD.Info.Name='counter';
UD.Name=UD.Info.Name;
UD.CounterType=UD.Info.CounterType;
UD.Object=Obj;

% ----------
% Create default item
% ----------
Handles=axes('parent',PHandle, ...
       'xlim',[0 1], ...
       'ylim',[0 1], ...
       'zlim',[0 1], ...
       'units','normalized', ...
       'position',[0 0 1 1], ...
       'xtick',[], ...
       'ytick',[], ...
       'ztick',[], ...
       'dataaspectratio',[1 1 1], ...
       'box','on', ...
       'tag',Tag, ...
       'color','w', ...
       'userdata',UD, ...
       'visible','off');

if nargin>2, % CmdStruct
  if isfield(CmdStruct,'Type'),
    % select preset Type
    switch CmdStruct.Type,
    case 'interactive create',
      UD.Name=CmdStruct.Name;
      UD.Info.Name=CmdStruct.Name;
      UD.Info.Visible=CmdStruct.Visible;
      % UD.info.<other options>
      set(Handles,'position',CmdStruct.Pos,'userdata',UD);
      refresh(Obj)
      edit(Obj);
    otherwise,
      ui_message('error', ...
        {sprintf('Error in %s:',mfilename), ...
         sprintf('Unknown object type specification: %s.',CmdStruct.Type)} );
    end;
  else,
    ui_message('error', ...
      {sprintf('Error in %s:',mfilename), ...
       'No object type specified.'} );
  end;
end;
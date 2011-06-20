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
subtype='legend';

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
UD.Info.Border='line';
UD.Info.BorderText='legend';
UD.Info.Visible=0;
UD.Info.AutoFit=1;
UD.Info.Pos=[0 0 0 0];
UD.Info.Items=[];
% ---------
% UD.Info.<other options>
% ---------
UD.Info.Name='legend';
UD.CurrentPos=UD.Info.Pos;
UD.Name=UD.Info.Name;
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
       'box','on', ...
       'tag',Tag, ...
       'color','w', ...
       'userdata',UD, ...
       'visible','off');

pppos=get(PHandle,'paperposition');
if (pppos(3)<20.99) & (pppos(3)>20.98) & (pppos(4)<29.68) & (pppos(4)>29.67), % A4 portrait
  UD.Info.FontSize=0.013;
  UD.Info.yUnit=UD.Info.FontSize/2;
  UD.Info.xUnit=UD.Info.yUnit*pppos(4)/pppos(3);
elseif (pppos(4)<20.99) & (pppos(4)>20.98) & (pppos(3)<29.68) & (pppos(3)>29.67), % A4 landscape
  UD.Info.FontSize=0.013*29.7/21;
  UD.Info.yUnit=UD.Info.FontSize/2;
  UD.Info.xUnit=UD.Info.yUnit*pppos(4)/pppos(3);
else,
  TmpTxt=text(0,0,'','parent',Handles,'fontunits','points','fontsize',10);
  set(TmpTxt,'fontunits','normalized');
  UD.Info.FontSize=get(TmpTxt,'fontsize');
  delete(TmpTxt);
  pos=get(PHandle,'position');
  UD.Info.yUnit=UD.Info.FontSize/2;
  UD.Info.xUnit=UD.Info.yUnit*pos(4)/pos(3);
end;

Vrt=[ 0  0 -1; ...
      0  1 -1; ...
      1  1 -1; ...
      1  0 -1];
Handles(2)=patch('parent',Handles(1), ...
       'vertices',Vrt, ...
       'faces',[1 2 3 4], ...
       'tag',Tag, ...
       'facecolor','w', ...
       'edgecolor','k', ...
       'visible','off');

Handles(3)=text(0,0,'','parent',Handles(1), ...
       'horizontalalignment','left', ...
       'verticalalignment','top', ...
       'tag',Tag, ...
       'visible','off');

% set to desired axes type
% e.g. Local_SetAx_2DH(PHandle);

if nargin>2, % CmdStruct
  UD.Name=CmdStruct.Name;
  UD.Info.Name=CmdStruct.Name;
  UD.Info.Pos=CmdStruct.Pos;
  UD.Info.Visible=CmdStruct.Visible;
  % UD.info.<other options>
  set(Handles(1),'userdata',UD);
  refresh(Obj)
else, % interactive
  Pos=getnormpos(PHandle);
  UD.Info.Pos=Pos;
  UD.Info.Visible=1;
  set(Handles(1),'userdata',UD);
  refresh(Obj)
end;


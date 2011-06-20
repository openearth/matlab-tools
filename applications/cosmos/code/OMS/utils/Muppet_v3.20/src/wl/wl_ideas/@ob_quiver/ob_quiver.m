function Obj=ob_quiver(arg1,arg2,arg3);
% OB_SURFACE is an interface for creating a general vector plot
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
subtype='quiver';

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


function possible=ispossible(Axes),
axoptions=get(Axes,'userdata');
axtypes={'undefined','2DH','3D'};
possible=~isempty(strmatch(axoptions.Type,axtypes,'exact'));


function Handles=Local_create(Obj,Axes,CmdStruct),
Tag=tag(Obj);

UD.PTag='main';
UD.Info.Version=1; % version number
UD.Info.Visible=1;
UD.Info.Clipped=0;
UD.Info.LightMode='unlit vectors';
UD.Info.Name='empty quiver';
UD.Info.XStream=datastream;
UD.Info.YStream=datastream;
UD.Info.ZStream=datastream;
UD.Info.UStream=datastream;
UD.Info.VStream=datastream;
UD.Info.CStream='copyU';
UD.Info.Scale=10;
UD.Info.ArrowHead='arrowhead';
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
UD.Info.LinkedObjects=[];
UD.Name=UD.Info.Name;
UD.Object=Obj;

Handles=patch('parent',Axes, ...
       'tag',Tag, ...
       'faces',[], ...
       'vertices',[], ...
       'facevertexcdata',[], ...
       'userdata',UD, ...
       'cdatamapping','direct', ...
       'facecolor','flat', ...
       'facelighting','none', ...
       'edgecolor','none', ...
       'visible','on');
xx_setax(Axes,'2DH');

if nargin>2,
  if isfield(CmdStruct,'Type'),
    switch CmdStruct.Type,
    case {'flow field'},
      UD.Name=CmdStruct.Name;
      UD.Info.ArrowHead='arrowhead';
      UD.Info.Name=CmdStruct.Name;
      UD.Info.XStream=datastream(CmdStruct.X);
      UD.Info.YStream=datastream(CmdStruct.Y);
      UD.Info.ZStream=datastream(CmdStruct.Z);
      UD.Info.UStream=datastream(CmdStruct.U);
      UD.Info.VStream=datastream(CmdStruct.V);
      if isfield(CmdStruct,'T'),
        UD.Info.TStream=datastream(CmdStruct.T);
      end;
      if isfield(CmdStruct,'C'),
        UD.Info.CStream=datastream(CmdStruct.C);
      end;
      UD.Info.ShowFrame=CmdStruct.Frame;
      UD.Info.LightMode='unlit vectors';
      UD.Info.CMode='continuous';
      UD.Info.CCMap='jet';
      set(Handles,'userdata',UD);
      refresh(Obj)
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

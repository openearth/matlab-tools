function md_animate(ax),
%MD_ANIMATE animate some objects

if nargin<1,
  return;
end;

if ischar(ax),
  md_a0_cmd(ax);
  return;
end;

switch get(ax,'type'),
case 'figure',
  fig=ax;
case 'axes',
  fig=get(ax,'parent');
otherwise,
  return;
end;

axs=findobj(fig,'type','axes'); % find all axes
Its=axs; % get all items
for i=1:length(axs),
  Its=[Its; get(axs(i),'children')];
end;

itnoud=findobj(Its,'flat','userdata',[]); % find items without userdata
Its=setdiff(Its,itnoud); % keep those items with userdata
ItIDs=get(Its,'tag'); % get all tags
if iscell(ItIDs),
  ItIDs=str2mat(ItIDs{:});
end;

[ItIDs,i,j]=unique(ItIDs,'rows'); % get all unique tags
Its=Its(i);
for i=1:length(Its),
  AllParts=xx_getitem(Its(i));
  Its(i)=AllParts(1);
end;

ItOptions=get(Its,'userdata'); % get the options of all items
if ~iscell(ItOptions), % if Its contains obly one item, ItOptions is no cell
  ItOptions={ItOptions};
end;

itopt=zeros(size(ItOptions)); % get the items for which we have options
for i=1:length(ItOptions),
  itopt(i)=isstruct(ItOptions{i});
end;
i=find(itopt);
ItOptions=ItOptions(i);
Its=Its(i);
ItIDs=ItIDs(i,:);
animtypes={};
itanim=zeros(size(Its));
for i=1:length(Its), % get animation types
  if isfield(ItOptions{i},'Animation'),
    itanim(i)=length(ItOptions{i}.Animation);
    for j=1:itanim(i),
      if size(animtypes,1)==0,
        animtypes=ItOptions{i}.Animation(j).Type;
        animsteps=ItOptions{i}.Animation(j).Nsteps;
      else,
        animtypes=str2mat(animtypes, ItOptions{i}.Animation(j).Type);
        animsteps(size(animsteps,2)+1)=ItOptions{i}.Animation(j).Nsteps;
      end;
    end;
  else,
    itanim(i)=0;
%    fprintf(1,['Warning %s has no Animation field.'],num2hex(Its(i)));
  end;
end;

if isempty(itanim) | isequal(max(itanim),0),
  uiwait(msgbox('Nothing to animate.'));
  return;
end;

animations=unique([abs(animtypes) transpose(animsteps)],'rows'); % determine unique animation types and lengths
AnimTypes=char(animations(:,1:(end-1)));
AnimSteps=animations(:,end);
animations=[AnimTypes,ones(length(AnimSteps),1)*' (',num2str(AnimSteps),ones(length(AnimSteps),1)*' steps)'];

uifig = ui_md_animate;

Hseq=findobj(uifig,'tag','animation seq');
set(Hseq,'string',animations);

outputtypes={'No output','Write 8bit AVI mrle compressed.','Bitmaps to clipboard','Set of tiff files','Set of bmp files'};
Houtp=findobj(uifig,'tag','animation output');
set(Houtp,'string',outputtypes);

Htim=findobj(uifig,'tag','time steps');
Hnoan=findobj(uifig,'tag','noanim list');
Han=findobj(uifig,'tag','anim list');
set(uifig,'userdata',5);
anim=1;
animdone=0;
while ~animdone,
  if isempty(get(uifig,'userdata')),
    waitfor(uifig,'userdata');
  end;
  if ishandle(uifig),
    cmd=get(uifig,'userdata');
    set(uifig,'userdata',[]);
  else, % figure deleted equivalent with cancel
    % animdone=1; cmd=-1;
    return;
  end;
  
  switch cmd,
  case -1, % cancel
    if ishandle(uifig), delete(uifig); end;
    return;
  case 0, % continue
    i=get(Han,'userdata');
    output=get(Houtp,'value');
    if output==1,
      output='';
    else,
      output=outputtypes{output};
    end;
    animdone=1;
  case 1, % do animate
    nail=get(Hnoan,'string');
    nailh=get(Hnoan,'userdata');
    naisel=get(Hnoan,'value');
    if ~isempty(nailh),
      ail=get(Han,'string');
      ailh=get(Han,'userdata');
      ailh=[ailh, nailh(naisel)];
      if isempty(ail),
        ail=nail(naisel,:);
      else,
        ail=str2mat(ail,nail(naisel,:));
      end;
      set(Han,'string',ail,'userdata',ailh);
      naiseln=setdiff(1:length(nailh),naisel);
      nail=nail(naiseln,:);
      nailh=nailh(naiseln);
      set(Hnoan,'value',1,'string',nail,'userdata',nailh);
    end;
  case 2, % don't animate
    ail=get(Han,'string');
    ailh=get(Han,'userdata');
    aisel=get(Han,'value');
    if ~isempty(ailh),
      nail=get(Hnoan,'string');
      nailh=get(Hnoan,'userdata');
      nailh=[nailh, ailh(aisel)];
      if isempty(nail),
        nail=ail(aisel,:);
      else,
        nail=str2mat(nail,ail(aisel,:));
      end;
      set(Hnoan,'string',nail,'userdata',nailh);
      aiseln=setdiff(1:length(ailh),aisel);
      ail=ail(aiseln,:);
      ailh=ailh(aiseln);
      set(Han,'value',1,'string',ail,'userdata',ailh);
    end;
  case 3, % simsteps
   ANISteps=eval(get(Htim,'string'),vec2str(ANISteps));
   set(Htim,'string',vec2str(ANISteps));
  case 4, % output options
  case 5, % select animation type
    anim=get(Hseq,'value');
    ANISteps=1:AnimSteps(anim);
    set(Htim,'string',vec2str(ANISteps));
    animsteps=AnimSteps(anim);
    animtypes=deblank(AnimTypes(anim,:));
    its=Its;
    itids=ItIDs;
    itoptions=ItOptions;
    
    animit=zeros(length(its),1);
    for i=1:length(its), % get animation types
      j=1;
      while (j<=itanim(i)) & (animit(i)==0),
        if strmatch(itoptions{i}.Animation(j).Type,animtypes) & isequal(itoptions{i}.Animation(j).Nsteps,animsteps),
          animit(i)=1;
        end;
        j=j+1;
      end;
    end;
    i=find(animit);
    its=its(i); % get item that should be animated
    itids=itids(i,:);
    itoptions=itoptions(i);
    
    % select the items that should be animated
    itnames={};
    for i=1:length(itoptions),
      if isfield(itoptions{i},'Name'),
        itnames{i}=itoptions{i}.Name;
      else,
        itnames{i}=listnames(its(i));
      end;
    end;
    set(Han,'string',str2mat(itnames{:}),'userdata',1:length(its));
    set(Hnoan,'string','','userdata',[]);
  end;
end;
if ishandle(uifig), delete(uifig); end;

its=its(i);
itoptions=itoptions(i);
itids=itids(i);

itobj(1:length(its))=ob_ideas; % empty objects
for i=1:length(its),
  if isfield(itoptions{i},'Object'),
    itobj(i)=itoptions{i}.Object;
  end;
end;

if isempty(its), % any items remaining ?
  return;
end;

if length(ANISteps)==1,
  uiwait(msgbox('Entering online visualization mode ...','modal'));
end;

% create the actual animation
figname=get(fig,'name');

StopAnimation=uimenu('parent',fig,'label','stop animation','callback','set(gcbo,''userdata'',1);','userdata',0);

FirstFrame=1;    % FirstFrame and Rect are used for selective capturing of the image
Rect=[];         %

yesno='InitRun'; % First initialize, e.g. backup camera position before camera motion animation
steps=-inf;      % steps = -inf for initialization

lasterr('');
try,
while ~strcmp(yesno,'No'), % as long as the user wants to see the animation
  if strcmp(yesno,'Yes'), % create AVI file
    if isempty(output),
      AniTypes=str2mat(outputtypes{2:end});
      AniType=gui_select(1,AniTypes);
      if AniType<=size(AniTypes,1),
        AniType=deblank(AniTypes(AniType,:));
      end;
    else,
      AniType=output;
    end;
    switch AniType,
    case 'Write 8bit AVI mrle compressed.',
      if avi_active,
        create_avi=strcmp(questdlg('Interrupt other AVI creation process?','','Yes','No','No'),'Yes');
        if create_avi,
          avi_break;
        end;
      else,
        create_avi=1;
      end;
      if create_avi,
        [AVIname,AVIpath]=uiputfile('*.avi','Specify filename');
        if ~isstr(AVIname),
          yesno='No';
        else;
          AVIname=[AVIpath AVIname];
          if avi_init(AVIname)<0,
            uiwait(msgbox('A problem occured while creating the animation.'));
            yesno='No';
          end;
        end;
      else,
        yesno='No';
      end;
      if strcmp(yesno,'Yes'), % file opened, now select rectangle
        Scan=gui_select(1,str2mat('scan complete window for changes','scan only user specified rectangle'));
        FirstFrame=1;
        switch Scan,
        case 1,
          Rect=[];
        case 2, % get rectangle
          tmphvis=get(fig,'handlevisibility');
          tmpunit=get(fig,'units');
          set(fig,'handlevisibility','on','units','pixels');
          figure(fig);
          waitforbuttonpress;
          Pos=get(fig,'currentpoint');
          Rect=rbbox([Pos 0 0]);
          FigSize=get(fig,'position');
          set(fig,'handlevisibility',tmphvis,'units',tmpunit);
          % Restrict rectangle to figure
          if Rect(1)<1,
            Rect(3)=Rect(3)-(1-Rect(1));
            Rect(1)=1;
          end;
          if Rect(2)<1,
            Rect(4)=Rect(4)-(1-Rect(2));
            Rect(2)=1;
          end;
          if (Rect(1)+Rect(3))>(FigSize(3)-1),
            Rect(3)=(FigSize(3)-1)-Rect(1);
          end;
          if (Rect(2)+Rect(4))>(FigSize(4)-1),
            Rect(4)=(FigSize(4)-1)-Rect(2);
          end;
          if Rect(3)<0,
            Rect(3)=0;
          end;
          if Rect(4)<0,
            Rect(4)=0;
          end;
        otherwise,
          yesno='No';
          avi_break;
        end;
      end;
    case 'Bitmaps to clipboard',
      % No further input necessary
      % Make sure that the current backgroundcolor is used in the bitmaps
%      Children=get(fig,'children');
%      TMPAxoptions.Editable=1;
%      TMPAxoptions.Type='undefined';
%      TMPAxoptions.Name='[Figure color]';
%      TmpAx=axes('parent',fig,'units','normalized','position',[-0.1 -0.1 1.2 1.2],'xlim',[0 1],'ylim',[0 1],'userdata',TMPAxoptions,'visible','off');
%      TmpPatch=patch([0 0 1 1 0],[0 1 1 0 0],1,'facecolor',get(fig,'color'),'edgecolor','none','parent',TmpAx,'clipping','off');
%      set(fig,'children',[Children;TmpAx],'color',[1 1 1]); % move new axes to back and change figure color to make patch contrasting
    case 'Set of tiff files',
      [TIFname,TIFpath]=uiputfile('*.tif','Specify filename base');
      if ~isstr(TIFname),
        yesno='No';
      else;
        TIFname=[TIFpath TIFname];
        if strmatch(TIFname(max(1,length(TIFname)+(-1:0))),'.m'), % remove .m end if present
          TIFname=TIFname(1:(end-2)); % Matlab adds this extension somethimes automatically
        end;
        if strmatch(lower(TIFname(max(1,length(TIFname)+(-3:0)))),'.tif'), % remove .tif end if present
          TIFname=TIFname(1:(end-4));
        end;
        if strmatch(TIFname(max(1,length(TIFname)+(-2:0))),'000'), % remove 000 end if present
          TIFname=TIFname(1:(end-3));
        end;
        filebase=TIFname;

        % Make sure that the current backgroundcolor is used in the bitmaps
%        Children=get(fig,'children');
%        TMPAxoptions.Editable=1;
%        TMPAxoptions.Type='undefined';
%        TMPAxoptions.Name='[Figure color]';
%        TmpAx=axes('parent',fig,'units','normalized','position',[-0.1 -0.1 1.2 1.2],'xlim',[0 1],'ylim',[0 1],'userdata',TMPAxoptions,'visible','off');
%        TmpPatch=patch([0 0 1 1 0],[0 1 1 0 0],1,'facecolor',get(fig,'color'),'edgecolor','none','parent',TmpAx,'clipping','off');
%        set(fig,'children',[Children;TmpAx]); % move new axes to back

        % Make sure that the bitmaps will have exactly the same size
        TMPwindowProps=get(fig,{'units','paperunits','paperposition'});
        set(fig,'units','pixels','paperunits','inches');
        Pos=get(fig,'position');
        set(fig,'paperposition',[0 0 Pos(3:4)/100]); % output quality in 100 dpi
      end;
    case 'Set of bmp files',
      [TIFname,TIFpath]=uiputfile('*.bmp','Specify filename base');
      if ~isstr(TIFname),
        yesno='No';
      else;
        TIFname=[TIFpath TIFname];
        if strmatch(TIFname(max(1,length(TIFname)+(-1:0))),'.m'), % remove .m end if present
          TIFname=TIFname(1:(end-2)); % Matlab adds this extension sometimes automatically
        end;
        if strmatch(lower(TIFname(max(1,length(TIFname)+(-3:0)))),'.bmp'), % remove .bmp end if present
          TIFname=TIFname(1:(end-4));
        end;
        while isequal(TIFname(end),'0'), % remove zeros end if present
          TIFname=TIFname(1:(end-1));
        end;
        filebase=TIFname;
      end;
    end;
    N=md_clrmngr(fig); % optimize colour palette
  end;

  if ~strcmp(yesno,'No'), % skip if cancel was pressed in animation output selection process
    StepNumber=1;
    while StepNumber<=length(steps(:)); % for each step of the animation
      step=steps(StepNumber);
      for i=1:length(its), % for each element
        if ishandle(its(i)) & strcmp(get(its(i),'type'),'axes'), % currently only cameramotion
          if isfinite(step),
            AnimI=strmatch(animtypes,{itoptions{i}.Animation.Type},'exact');
            FrameProps=itoptions{i}.Animation(AnimI).Data;
            FrameData={FrameProps(2:4,step) FrameProps(5:7,step) FrameProps(8:10,step) FrameProps(11,step) FrameProps(12:14,step)};
            set(its(i),{'dataaspectratio', ...
              'cameraposition','cameratarget','cameraviewangle','cameraupvector'},FrameData);
          elseif step == -inf, % backup during initialization
            ViewBackup=get(its(i),{'projection','dataaspectratio', ...
              'cameraposition','cameratarget','cameraviewangle','cameraupvector'});
            itoptions{i}.ViewBackup=ViewBackup;
          elseif step == inf, % restore afterwards
            ViewBackup=itoptions{i}.ViewBackup;
            set(its(i),{'projection','dataaspectratio', ...
              'cameraposition','cameratarget','cameraviewangle','cameraupvector'},ViewBackup);
          end;
        else,
          if ~isempty(itobj(i)),
            animate(itobj(i),animtypes,step);
          else,
            allits=xx_getitem(its(i)); % its(i), the main item, must not change
            if ~isfield(itoptions{i},'ReproData') | ...
               ~isfield(itoptions{i}.ReproData,'FileType'),
              if (step==steps(1)) & isempty(strmatch(yesno,{'ResetRun','InitRun'})),
                Str=sprintf('File type missing for: %s.',itoptions{i}.Name);
                uiwait(msgbox(Str,'modal'));
              end;
            else,
              switch(itoptions{i}.ReproData.FileType)
              case 'GenItem',
                 di_genitem(allits,animtypes,step)
              case 'Delft3D-com',
                 di_comfile(allits,animtypes,step)
              case 'Delft3D-trim',
                 di_trimfile(allits,animtypes,step)
              case 'Delft3D-botm',
                 di_botmfile(allits,animtypes,step)
              case 'FLS mdf file',
                 di_fls(allits,animtypes,step)
              case 'incremental file',
                 di_inc(allits,animtypes,step)
              otherwise,
                if (step==steps(1)) & ~strcmp(yesno,'ResetRun'),
                  Str=sprintf('I don''t know how to animate: %s.\nFile type: %s.',itoptions{i}.Name,itoptions{i}.ReproData.FileType);
                  uiwait(msgbox(Str,'modal'));
                end;
              end;
            end;
          end;
        end;
      end;
      drawnow;
      if isfinite(step),
        set(fig,'name',[figname ':' gui_str(step) ' of ' gui_str(animsteps)]);
      elseif isequal(step,-inf),
        set(fig,'name',[figname ': preparing animation ...']);
      elseif isequal(step,inf),
        set(fig,'name',[figname ': resetting figure ...']);
      end;
      if strcmp(yesno,'Yes'),
        invhc=get(fig,'inverthardcopy');
        set(fig,'inverthardcopy','off');
        switch AniType,
        case 'Write 8bit AVI mrle compressed.',
          if isempty(Rect) | FirstFrame,
            avi_frame(fig);
            FirstFrame=0;
          else,
            avi_frame(fig,Rect);
          end;
        case 'Bitmaps to clipboard',
          hvis=get(fig,'handlevisibility');
          set(fig,'handlevisibility','on');
          figure(fig);
          print('-dbitmap');
          set(fig,'handlevisibility',hvis);
        case 'Set of tiff files',
          hvis=get(fig,'handlevisibility');
          set(fig,'handlevisibility','on');
          figure(fig);
          filename=sprintf('%s%3.3i.tif',filebase,StepNumber-1);
          print(filename,'-dtiff','-r100');
          set(fig,'handlevisibility',hvis);
        case 'Set of bmp files',
          figure(fig);
          BMP=getframe(fig);
          filename=sprintf('%s%4.4i.bmp',filebase,StepNumber-1);
          if get(0,'screendepth')==8
            imwrite(BMP.cdata,BMP.colormap,filename,'bmp');
          else
            imwrite(BMP.cdata,filename,'bmp');
          end
        end;
        set(fig,'inverthardcopy',invhc);
      end;
      StepNumber=StepNumber+1;
      if get(StopAnimation,'userdata') & ~strcmp(yesno,'ResetRun'),
        if strcmp('Stop',questdlg('Continue or stop?','Question','Continue','Stop','Continue')),
          StepNumber=length(steps(:))+1;
        else,
          set(StopAnimation,'userdata',0);
        end;
      end;
    end;
  end;

  if strcmp(yesno,'Yes'),
    switch AniType,
    case 'Write 8bit AVI mrle compressed.',
      avi_write;
    case 'Bitmaps to clipboard',
      % no finishing necessary within Matlab
    case 'Set of tiff files',
      % Remove the temporary axes and patch that act as the figure color
      % delete(TmpAx);
      % and reset figure and paper units and position
      set(fig,{'units','paperunits','paperposition'},TMPwindowProps);
    case 'Set of bmp files',
      % no finishing necessary within Matlab
    end;
    % reset figure to default
    yesno='ResetRun';
    steps=inf;
  elseif strcmp(yesno,'ResetRun'),
    yesno='No';
  elseif strcmp(yesno,'InitRun'),
    if ~isempty(output),
      yesno='Yes';
    else,
      if length(ANISteps)>1,
        yesno='Play again';
      else, % "Online visualization" if one step is selected
        yesno='Continuous';
      end;
    end;
    steps=ANISteps;
  elseif strcmp(yesno,'Continuous'),
    if get(StopAnimation,'userdata'),
      set(StopAnimation,'enable','off');
      yesno='ResetRun';
      steps=inf;
    else,
      pause(1);
    end;
  else,
    yesno=questdlg('Create AVI file?', ...
                   'Animation', ...
                   'Play again','Yes','No','No');
    if strcmp(yesno,'No'),
      % reset figure to default
      set(StopAnimation,'enable','off');
      yesno='ResetRun';
      steps=inf;
    else,
      set(StopAnimation,'userdata',0);
    end;
  end;
end;
%try,
catch,
  ui_message('error',sprintf('%s\n trapped in %s.',lasterr,mfilename));
end;
delete(StopAnimation);
set(fig,'name',figname);
if strcmp(yesno,'Yes'), % in case of crash
  switch AniType,
  case 'Write 8bit AVI mrle compressed.',
    % try finishing the AVI file correctly
    avi_write;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create user interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a=ui_md_animate()

ss=get(0,'screensize');

a = figure('Units','pixels', ...
	'Color',[0.8 0.8 0.8], ...
	'HandleVisibility','off', ...
	'IntegerHandle','off', ...
	'MenuBar','none', ...
	'Name','Specify animation parameters ...', ...
	'NumberTitle','off', ...
	'Position',[ss(3)/2-160 ss(4)/2-155 320 310], ...
	'Resize','off', ...
	'Tag','IDEAS animate items');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'FontSize',12, ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Position',[10 285 50 18], ...
	'HorizontalAlignment','left', ...
	'String','type:', ...
	'Style','text', ...
	'Tag','');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',12, ...
	'Position',[60 285 250 20], ...
	'HorizontalAlignment','right', ...
        'callback','set(gcbf,''userdata'',5)', ...
	'String','animation seq', ...
	'Style','popupmenu', ...
	'Tag','animation seq');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'FontSize',12, ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Position',[10 260 50 18], ...
	'HorizontalAlignment','left', ...
	'String','output:', ...
	'Style','text', ...
	'Tag','');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',12, ...
	'Position',[60 260 250 20], ...
	'HorizontalAlignment','right', ...
        'callback','set(gcbf,''userdata'',4)', ...
	'String','animation output', ...
	'Style','popupmenu', ...
	'Tag','animation output');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'FontSize',12, ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Position',[10 235 50 18], ...
	'HorizontalAlignment','left', ...
	'String','steps:', ...
	'Style','text', ...
	'Tag','');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',12, ...
	'Position',[60 235 250 20], ...
	'HorizontalAlignment','left', ...
        'callback','set(gcbf,''userdata'',3)', ...
	'String','[ ... ]', ...
	'Style','edit', ...
	'Tag','time steps');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',12, ...
	'Position',[10 35 300 80], ...
	'String',' ', ...
	'Style','listbox', ...
	'Tag','anim list', ...
	'Value',1);
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',12, ...
	'Position',[10 135 300 80], ...
	'String',' ', ...
	'Style','listbox', ...
	'Tag','noanim list', ...
	'Value',1);

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'Position',[10 215 150 15], ...
	'String','don''t animate', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'Position',[10 115 150 15], ...
	'String','animate', ...
	'Style','text', ...
	'Tag','StaticText2');

Arrow=repmat(.8,[16,16,3]);
Arrow(8:14,7:10,:)=0;
for i=1:6, Arrow(2+i,(9-i):(8+i),:)=0; end;
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
        'callback','set(gcbf,''userdata'',1)', ...
	'FontSize',12, ...
	'Position',[135 115 20 20], ...
	'String','', ...
	'CData',Arrow(16:-1:1,:,:), ...
	'Tag','anim');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
        'callback','set(gcbf,''userdata'',2)', ...
	'FontSize',12, ...
	'Position',[165 115 20 20], ...
	'String','', ...
	'CData',Arrow, ...
	'Tag','noanim');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
        'callback','set(gcbf,''userdata'',0)', ...
	'FontSize',12, ...
	'Position',[165 10 145 20], ...
	'String','continue', ...
	'Tag','continue');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
        'callback','set(gcbf,''userdata'',-1)', ...
	'FontSize',12, ...
	'Position',[10 10 145 20], ...
	'String','cancel', ...
	'Tag','cancel');

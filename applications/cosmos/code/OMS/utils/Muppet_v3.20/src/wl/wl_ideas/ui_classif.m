function [thresholds,colors]=ui_classif(thres_in,col_in),
% UI_CLASSIF
%          [Thresholds,Colors]
%             =UI_CLASSIF(ThresholdsIn,ColorsIn)
%             =UI_CLASSIF

thresholds=[];
colors=[1 1 1];

switch nargin,
case 2, % =UI_CLASSIF(ThresholdsIn,ColorsIn)
  thresholds=thres_in;
  colors=col_in;
case 1,
  warning('Incorrect number of input arguments.');
case 0, % =UI_CLASSIF
end;

EditThresh=thresholds;
EditColors=colors;

XX=xx_constants;

NRanges=10;
LimitWidth=80;
ColorPatch=XX.But.Height;
Fig_Width=2*LimitWidth+2*ColorPatch+4*XX.Margin+XX.Slider;
Fig_Height=8*XX.Margin+(2+NRanges)*XX.But.Height+XX.Txt.Height;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect);

Ax=axes( ...
   'units','pixels','position',[1 1 Fig_Width Fig_Height], ...
   'xlim',[0 Fig_Width-1],'ylim',[0 Fig_Height-1], ...
   'visible','off', ...
   'drawmode','fast', ...
   'parent',fig);

rect = [XX.Margin XX.Margin (Fig_Width-3*XX.Margin)/2 XX.But.Height];
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','cancel', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',-1)');

rect(1) = (Fig_Width+XX.Margin)/2;
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','accept', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',0)');

% ---
Border=xx_border3d(XX.Margin, ...
         2*XX.Margin+XX.But.Height, ...
         2*XX.Margin+2*LimitWidth+2*ColorPatch+XX.Slider, ...
         NRanges*XX.But.Height+2*XX.Margin+XX.Txt.Height, ...
         'parent',Ax);

set(Border(5),'zdata',-5*[1 1 1 1]);

rect(2) = rect(2)+2*XX.Margin;

Handle.Edit(NRanges,2)=0;
Handle.ColPatches(NRanges,5)=0;

Tmp=1-max(eye(16),fliplr(eye(16)));
Icon.Cross(1:16,1:16,3)=Tmp*XX.Clr.LightGray(3);
Icon.Cross(1:16,1:16,2)=Tmp*XX.Clr.LightGray(2);
Icon.Cross(1:16,1:16,1)=Tmp*XX.Clr.LightGray(1);

for i=NRanges:-1:1,
  rect(1) = 2*XX.Margin;
  rect(2) = rect(2)+rect(4);
  rect(3) = LimitWidth;
  Handle.Edit(i,1)=uicontrol('style','edit', ...
          'position',rect, ...
          'horizontalalignment','right', ...
          'string','', ...
          'parent',fig, ...
          'enable','off', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'callback',['set(gcbf,''userdata'',[' num2str(i) ' 1])']);

  rect(1) = rect(1)+rect(3);
  rect(3) = ColorPatch;
  Handle.ColPatches(i)=uicontrol('style','togglebutton', ...
          'position',rect, ...
          'string','', ...
          'parent',fig, ...
          'enable','off', ...
          'callback',['set(gcbf,''userdata'',[' num2str(i) ' 3])']);
  
  rect(1) = rect(1)+rect(3);
  rect(3) = ColorPatch;
  Handle.Cross(i)=uicontrol('style','togglebutton', ...
          'cdata',Icon.Cross, ...
          'position',rect, ...
          'string','', ...
          'parent',fig, ...
          'enable','off', ...
          'callback',['set(gcbf,''userdata'',[' num2str(i) ' 4])']);
  
  rect(1) = rect(1)+rect(3);
  rect(3) = LimitWidth;
  Handle.Edit(i,2)=uicontrol('style','edit', ...
          'position',rect, ...
          'horizontalalignment','right', ...
          'string','', ...
          'parent',fig, ...
          'enable','off', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'callback',['set(gcbf,''userdata'',[' num2str(i) ' 2])']);
end;

rect(1) = 2*XX.Margin;
rect(2) = rect(2)+rect(4);
rect(3) = (2*LimitWidth+2*ColorPatch)/3;
rect(4) = XX.Txt.Height;
uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','left', ...
          'string','min', ...
          'parent',fig, ...
          'backgroundcolor',XX.Clr.LightGray);

rect(1) = rect(1)+rect(3);
uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','center', ...
          'string','color', ...
          'parent',fig, ...
          'backgroundcolor',XX.Clr.LightGray);

rect(1) = rect(1)+rect(3);
uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','right', ...
          'string','max', ...
          'parent',fig, ...
          'backgroundcolor',XX.Clr.LightGray);

rect = [2*XX.Margin+2*LimitWidth+2*ColorPatch 3*XX.Margin+XX.But.Height XX.Slider NRanges*XX.But.Height];
Handle.Slider=uicontrol('style','slider', ...
          'position',rect, ...
          'min',0, ...
          'max',1, ...
          'value',0, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','set(gcbf,''userdata'',1)');
% ---

% ---
Border=xx_border3d(XX.Margin, ...
         5*XX.Margin+(1+NRanges)*XX.But.Height+XX.Txt.Height, ...
         2*XX.Margin+2*LimitWidth+2*ColorPatch+XX.Slider, ...
         XX.But.Height+2*XX.Margin, ...
         'parent',Ax);

rect = [2*XX.Margin 6*XX.Margin+(1+NRanges)*XX.But.Height+XX.Txt.Height LimitWidth+2*ColorPatch+XX.Slider-XX.Margin XX.But.Height];
Handle.New=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'enable','on', ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.White, ...
          'parent',fig);

rect(1)=rect(1)+rect(3)+XX.Margin;
rect(3)=LimitWidth;
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','add  threshold', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',2)');

% ---

BotIndex=Local_update(thresholds,colors,Handle);

set(fig,'visible','on');
while 1,
  if isempty(get(fig,'userdata')),
    waitfor(fig,'userdata');
  end;
  Cmd=get(fig,'userdata');
  set(fig,'userdata',[]);
  if length(Cmd)==1,
    switch Cmd,
    case -1, % cancel
      break;
    case 0, % accept
      thresholds=EditThresh;
      colors=EditColors;
      break;
    case 1, % slider
      BotIndex=round(get(Handle.Slider,'value'));
      BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
    case 2, % add threshold
      NewThreshold=getValues(Handle.New,NaN);
      if ~isequal(size(NewThreshold),[1 1]), % multiple thresholds
        for i=1:length(NewThreshold),
          Tindex=find(~(EditThresh-NewThreshold(i)));
          if ~isempty(Tindex),
%            uiwait(msgbox('threshold already exists.','modal'));
            BotIndex=Tindex-8;
          else,
            Tindex=max(find(EditThresh<NewThreshold(i)));
            if isempty(Tindex),
              Tindex=1;
            else,
              Tindex=Tindex+1;
            end;
            EditThresh((Tindex+1):(end+1))=EditThresh(Tindex:end); % shift all thresholds larger
            EditThresh(Tindex)=NewThreshold(i);
            EditColors((Tindex+1):(end+1),:)=EditColors(Tindex:end,:);
          end;
          BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
        end;
      elseif ~isnan(NewThreshold),
        Tindex=find(~(EditThresh-NewThreshold));
        if ~isempty(Tindex),
          uiwait(msgbox('threshold already exists.','modal'));
          BotIndex=Tindex-8;
        else,
          Tindex=max(find(EditThresh<NewThreshold));
          if isempty(Tindex),
            Tindex=1;
          else,
            Tindex=Tindex+1;
          end;
          EditThresh((Tindex+1):(end+1))=EditThresh(Tindex:end); % shift all thresholds larger
          EditThresh(Tindex)=NewThreshold;
          EditColors((Tindex+1):(end+1),:)=EditColors(Tindex:end,:);
        end;
        BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
      else,
        uiwait(msgbox('invalid threshold specified.','modal'));
      end;
    end;
  elseif length(Cmd)==2,
    i=Cmd(1);
    switch Cmd(2),
    case 1,
      Tindex=BotIndex+size(Handle.ColPatches,1)-i-1;
      NewThreshold=getValue(Handle.Edit(i,1),EditThresh(Tindex));
      if NewThreshold==inf,
        EditThresh(Tindex:end)=[];
        EditColors((Tindex+1):end,:)=[];
      elseif NewThreshold==-inf,
        EditThresh(1:Tindex)=[];
        EditColors(1:Tindex,:)=[];
      elseif NewThreshold>EditThresh(Tindex),
        EditThresh(Tindex)=NewThreshold;
        while (Tindex<length(EditThresh)) & (EditThresh(Tindex+1)<=NewThreshold),
          EditThresh(Tindex+1)=[];
          EditColors(Tindex+1,:)=[];
        end;
      else,
        EditThresh(Tindex)=NewThreshold;
        while (Tindex>1) & (EditThresh(Tindex-1)>=NewThreshold),
          EditThresh(Tindex-1)=[];
          EditColors(Tindex+1,:)=[];
          Tindex=Tindex-1;
        end;
      end;
      BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
    case 2,
      Tindex=BotIndex+size(Handle.ColPatches,1)-i;
      NewThreshold=getValue(Handle.Edit(i,2),EditThresh(Tindex));
      if NewThreshold==inf,
        EditThresh(Tindex:end)=[];
        EditColors((Tindex+1):end,:)=[];
      elseif NewThreshold==-inf,
        EditThresh(1:Tindex)=[];
        EditColors(1:Tindex,:)=[];
      elseif NewThreshold>EditThresh(Tindex),
        EditThresh(Tindex)=NewThreshold;
        while (Tindex<length(EditThresh)) & (EditThresh(Tindex+1)<=NewThreshold),
          EditThresh(Tindex+1)=[];
          EditColors(Tindex,:)=[];
        end;
      else,
        EditThresh(Tindex)=NewThreshold;
        while (Tindex>1) & (EditThresh(Tindex-1)>=NewThreshold),
          EditThresh(Tindex-1)=[];
          EditColors(Tindex,:)=[];
          Tindex=Tindex-1;
        end;
      end;
      BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
    case 3,
      Tindex=BotIndex+size(Handle.ColPatches,1)-i;
      if isnan(EditColors(Tindex,1)),
        Color=md_color;
        if length(Color)==1,
          Color=[NaN NaN NaN];
        end;
        EditColors(Tindex,:)=Color;
      else,
        EditColors(Tindex,:)=md_color(EditColors(Tindex,:));
      end;
      BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
    case 4,
      Tindex=BotIndex+size(Handle.ColPatches,1)-i;
      EditColors(Tindex,:)=NaN;
      BotIndex=Local_update(EditThresh,EditColors,Handle,BotIndex);
    end;
  end;
end;
delete(fig);


function N=getValue(H,Default),

N=eval(get(H,'string'),'NaN');
if ~isnumeric(N),
  N=Default;
elseif ~isequal(size(N),[1 1]),
  N=Default;
elseif ~isfinite(N),
  N=Default;
end;


function N=getValues(H,Default),

N=eval(get(H,'string'),'NaN');
if ~isnumeric(N),
  N=Default;
elseif isempty(N),
  N=Default;
elseif ~isequal(size(N),[1 1]),
  N=N(:);
  if any(~isfinite(N)),
    N=Default,
  else,
    N=unique(N);
  end;
elseif ~isfinite(N),
  N=Default;
end;


function BotIndex=Local_update(thresholds,colors,Handle,RequestBotIndex),

XX=xx_constants;

if nargin==3,
  RequestBotIndex=1;
end;
if size(colors,1)>size(Handle.ColPatches,1),
  TooLong=size(colors,1)-size(Handle.ColPatches,1)+1;
  BotIndex=max(min(RequestBotIndex,TooLong),1);
  MinStep=min(0.9,1/(TooLong-1)); % 0.9 added for the case where TooLong=2: MinStep<MaxStep
  MaxStep=min(10,TooLong)/TooLong; % maximum step 10
  set(Handle.Slider, ...
    'enable','on', ...
    'min', 1, ...
    'max', TooLong, ...
    'sliderstep',[MinStep MaxStep], ...
    'value', BotIndex);
else,
  set(Handle.Slider, ...
    'enable','off', ...
    'min', 0, ...
    'max', 1, ...
    'value', 1);
  BotIndex=-9+size(colors,1);
end;

for i=1:min(size(Handle.ColPatches,1),size(colors,1)),
  Tindex=BotIndex+size(Handle.ColPatches,1)-i;
  if isnan(colors(Tindex,1)),
    set(Handle.ColPatches(i),'cdata',[],'value',0,'enable','on');
    set(Handle.Cross(i),'value',1,'enable','on');
  else,
    ColPatch=reshape([colors(Tindex,1)*ones(16) colors(Tindex,2)*ones(16) colors(Tindex,3)*ones(16)],[16 16 3]);
    set(Handle.ColPatches(i),'cdata',ColPatch,'value',1,'enable','on');
    set(Handle.Cross(i),'value',0,'enable','on');
  end;
  set(Handle.Edit(i,:), ...
        'enable','on', ...
        'backgroundcolor',XX.Clr.White);
  if isequal(Tindex,1),
    set(Handle.Edit(i,1),'string','-inf','enable','inactive');
  else
    set(Handle.Edit(i,1),'string',lower(num2str(thresholds(Tindex-1))));
  end;
  if isequal(Tindex,length(thresholds)+1),
    set(Handle.Edit(i,2),'string','inf','enable','inactive');
  else
    set(Handle.Edit(i,2),'string',lower(num2str(thresholds(Tindex))));
  end;
end;
for i=(min(size(Handle.ColPatches,1),size(colors,1))+1):size(Handle.ColPatches,1),
  set(Handle.ColPatches(i),'enable','off','cdata',[],'value',0);
  set(Handle.Cross(i),'enable','off','value',0);
  set(Handle.Edit(i,:), ...
        'enable','off', ...
        'string','', ...
        'backgroundcolor',XX.Clr.LightGray);
end;
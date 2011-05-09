function Output=inquire(Matrix,Command);
%INQUIRE lets the user inspect and change the values in a matrix
%
%        ChangedMatrix=INQUIRE(OriginalMatrix)
%
%        The user may zoom in/out and scroll through the data
%        which is represented by coloured squares. One or more
%        polygons may be specified interactively and the contents
%        of cells within these polygons can be copied or changed.
%        The value of individual cells can be changed, or be
%        interpolated from other values along rows or columns.
%        For optimal contrast the color limits may be adjusted
%        using the sliders or by left (min) and right (max)
%        clicking on cells in 'color limit' mode.

% (c) 7 Feb. 2000, H.R.A. Jagers
%                  WL | Delft Hydraulics, Delft, The Netherlands

Scrollbar=15;

if nargin<1,
  error('Not enough input arguments.');
elseif (nargin==2),
  if ~isequal(Matrix,'window'),
    error('Too many input arguments.');
  else,
    UIFig=gcbf;
    UIAxes=findobj(gcbf,'type','axes');
    UD=get(UIAxes,'userdata');
    FigSize=get(UIFig,'position'); FigSize=FigSize(3:4);
    set(UD.UI(16),'position',[1 0 202 FigSize(2)+2]);
    set(UD.UI(15),'position',[1 FigSize(2)-1 FigSize(1) Scrollbar]);
    set(UD.UI(14),'position',[FigSize(1)-Scrollbar 1 Scrollbar+1 FigSize(2)]);
    set(UD.UI(13),'position',[1 1 FigSize(1) Scrollbar+1]);
    set(UD.UI(12),'position',[0 0 202 FigSize(2)+2]);
    set(UD.UI(6),'position',[FigSize(1)-Scrollbar+1 Scrollbar+2 Scrollbar max(1,FigSize(2)-Scrollbar-2)]);
    set(UD.UI(5),'position',[202 1 max(1,FigSize(1)-Scrollbar-202) Scrollbar]);
    set(UIAxes,'position',[202 2+Scrollbar max(1,FigSize(1)-Scrollbar-202) max(1,FigSize(2)-Scrollbar-2)]);
    return;
  end;
end;

MatrixName=inputname(1);
Matrix(end+1,end+1)=0;
Vertical=size(Matrix,1);
Horizontal=size(Matrix,2);

[X,Y]=meshgrid(1:size(Matrix,2),1:size(Matrix,1));

TmpUnits=get(0,'units');
set(0,'units','pixels');
Screen=get(0,'screensize');
set(0,'units',TmpUnits);

PatchSize=4;
WidthPatches=max(Horizontal*PatchSize,300);
HeightPatches=max(Vertical*PatchSize,300);
FigSize=min([WidthPatches+2+200+Scrollbar HeightPatches+2+Scrollbar],round(0.8*Screen(3:4)));
WidthPatches=FigSize(1)-2-200-Scrollbar;
HeightPatches=FigSize(2)-2-Scrollbar;
UIFig=figure('handlevisibility','off', ...
             'units','pixels', ...
             'position',[(Screen(3:4)-FigSize)/2 FigSize], ...
             'menu','none', ...
             'name','Inquire ...', ...
             'numbertitle','off', ...
             'integerhandle','off', ...
             'windowbuttonmotionfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');-1])'], ...
             'renderer','zbuffer', ...
             'resize','on', ...
             'resizefcn','inquire window resize');
%             'closerequestfcn','', ...
AxPosition=[202 2+Scrollbar WidthPatches HeightPatches];
UIAxes=axes('visible','off', ...
            'units','pixels', ...
            'position',AxPosition, ...
            'dataaspectratio',[1 1 1], ...
            'projection','orthographic', ...
            'xlim',[1 max(min(Horizontal,(WidthPatches/PatchSize)+1),2)], ...
            'ylim',[1 max(min(Vertical,(HeightPatches/PatchSize)+1),2)], ...
            'ydir','reverse', ...
            'parent',UIFig);

set(UIFig,'colormap',hot(100)); % default hsv has similar colors for both extremes

if all(size(Matrix)~=[1 1]),
  Str=[MatrixName,'(1,1) = ',num2str(Matrix(1,1))];
  set(UIFig,'name',Str);
%  UD.UISurf=surface('xdata',(1:(Horizontal+1)), ...
%          'ydata',(1:(Vertical+1)), ...
  UD.UISurf=surface('xdata',X, ...
          'ydata',Y, ...
          'zdata',-ones(size(Matrix)), ...
          'cdata',Matrix, ...
          'edgecolor',[0 0 0], ...
          'facecolor','flat', ...
          'parent',UIAxes, ...
          'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])'], ...
          'clipping','off');
else,
  Str=[MatrixName,' = [ ]'];
  set(UIFig,'name',Str);
  UD.UISurf=surface('xdata',[1 1], ...
          'ydata',[1 1], ...
          'zdata',-ones(2,2), ...
          'cdata',[NaN NaN; NaN NaN], ...
          'edgecolor',[0 0 0], ...
          'facecolor','flat', ...
          'parent',UIAxes, ...
          'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])'], ...
          'clipping','off');
end;
CLim=get(UIAxes,'clim');
set(UIAxes,'climmode','manual');
UD.UI(16)=uicontrol('style','frame', ...
          'units','pixels', ...
          'position',[1 0 202 FigSize(2)+2], ...
          'backgroundcolor',get(UIFig,'color'), ...
          'foregroundcolor',get(UIFig,'color'), ...
          'parent',UIFig);
UD.UI(15)=uicontrol('style','frame', ...
          'units','pixels', ...
          'position',[1 FigSize(2)-1 FigSize(1) Scrollbar], ...
          'backgroundcolor',get(UIFig,'color'), ...
          'foregroundcolor',get(UIFig,'color'), ...
          'parent',UIFig);
UD.UI(14)=uicontrol('style','frame', ...
          'units','pixels', ...
          'position',[FigSize(1)-Scrollbar 1 Scrollbar+1 FigSize(2)], ...
          'backgroundcolor',get(UIFig,'color'), ...
          'foregroundcolor',get(UIFig,'color'), ...
          'parent',UIFig);
UD.UI(13)=uicontrol('style','frame', ...
          'units','pixels', ...
          'position',[1 1 FigSize(1) Scrollbar+1], ...
          'backgroundcolor',get(UIFig,'color'), ...
          'foregroundcolor',get(UIFig,'color'), ...
          'parent',UIFig);
UD.UI(12)=uicontrol('style','frame', ...
          'units','pixels', ...
          'position',[0 0 202 FigSize(2)+2], ...
          'backgroundcolor',get(UIFig,'color'), ...
          'foregroundcolor','k', ...
          'parent',UIFig);
uicontrol('style','text', ...
          'units','pixels', ...
          'string','high', ...
          'horizontalalignment','right', ...
          'backgroundcolor',get(UIFig,'color'), ...
          'position',[110 80 80 20], ...
          'parent',UIFig);
UD.UI(11)=uicontrol('style','slider', ...
          'units','pixels', ...
          'min',CLim(1), ...
          'max',CLim(2), ...
          'value',CLim(2), ...
          'position',[110 60 80 20], ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');11])'], ...
          'parent',UIFig);
uicontrol('style','text', ...
          'units','pixels', ...
          'string','low', ...
          'horizontalalignment','left', ...
          'backgroundcolor',get(UIFig,'color'), ...
          'position',[110 30 80 20], ...
          'parent',UIFig);
UD.UI(10)=uicontrol('style','slider', ...
          'units','pixels', ...
          'min',CLim(1), ...
          'max',CLim(2), ...
          'value',CLim(1), ...
          'position',[110 10 80 20], ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');10])'], ...
          'parent',UIFig);
UD.UI(9)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 190 80 20], ...
          'string','clear poly', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');9])'], ...
          'parent',UIFig);
UD.UI(8)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 160 80 20], ...
          'string','edit', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');8])'], ...
          'parent',UIFig);
commands={'edit on click', ...
          'select point', ...
          'select polygon', ...
          'linear interpolate', ...
          'copy value', ...
          'copy polygon values', ...
          'color limit'};
UD.UI(7)=uicontrol('style','popupmenu', ...
          'units','pixels', ...
          'position',[10 130 180 20], ...
          'string',commands, ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');7])'], ...
          'parent',UIFig);
UD.UI(6)=uicontrol('style','slider', ...
          'units','pixels', ...
          'min',-max(Vertical,2), ...
          'max',-1, ...
          'value',-mean(get(UIAxes,'ylim')), ...
          'enable',logicalswitch(Vertical>1,'on','off'), ...
          'position',[WidthPatches+2+200+1 Scrollbar+2 Scrollbar HeightPatches], ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');6])'], ...
          'parent',UIFig);
UD.UI(5)=uicontrol('style','slider', ...
          'units','pixels', ...
          'min',1, ...
          'max',max(Horizontal,2), ...
          'enable',logicalswitch(Horizontal>1,'on','off'), ...
          'value',mean(get(UIAxes,'xlim')), ...
          'position',[202 1 WidthPatches Scrollbar], ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');5])'], ...
          'parent',UIFig);
UD.UI(4)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 100 80 20], ...
          'string','zoom out', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');4])'], ...
          'parent',UIFig);
UD.UI(3)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 70 80 20], ...
          'string','zoom', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');3])'], ...
          'parent',UIFig);
UD.UI(2)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 40 80 20], ...
          'string','reset', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');2])'], ...
          'parent',UIFig);
UD.UI(1)=uicontrol('style','pushbutton', ...
          'units','pixels', ...
          'position',[10 10 80 20], ...
          'string','accept', ...
          'callback',['set(gcbf,''userdata'',[get(gcbf,''userdata'');1])'], ...
          'parent',UIFig);

set(UIAxes,'userdata',UD);
%gelm_font(UD.UI);

%set(UIFig,'windowstyle','modal');
gui_quit=0;
BackupMatrix=Matrix;
while ~gui_quit,
  if ishandle(UIFig),
    if isempty(get(UIFig,'userdata')),
      waitfor(UIFig,'userdata');
    end;
  end;
  if ishandle(UIFig),
    stack=get(UIFig,'userdata');
    set(UIFig,'userdata',[]);
%    set(UIFig,'pointer','watch'); % don't show watch for every motion update
  else,
    uiwait(msgbox('Unexpected removal of window!','modal'));
    gui_quit=1;
  end;
  while ~isempty(stack),
    cmd=stack(1,:);
    stack=stack(2:size(stack,1),:);
    % process cmd
    switch cmd,
    case -1, % moved
      Point=get(UIAxes,'currentpoint');
      Point=floor(Point(1,1:2));
      if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),
        CP=Point;
        set(UIFig,'name',[MatrixName,'(',int2str(CP(2)),',',int2str(CP(1)),') = ',num2str(Matrix(CP(2),CP(1)))]);
      end;
    case 0, % clicked
      switch commands{get(UD.UI(7),'value')},
      case 'edit on click',
        Point=get(UIAxes,'currentpoint');
        Point=floor(Point(1,1:2));
        if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),

          answer=inputdlg('New value','Change value',1,{num2str(Matrix(Point(2),Point(1)))});
          if ~isempty(answer),
            lasterr('');
            answer=evalin('caller',answer{1},'NaN');
            if isempty(lasterr) & isequal(size(answer),[1 1]),
              Matrix(Point(2),Point(1))=answer;
              set(UD.UISurf,'cdata',Matrix);
              set(UIFig,'name',[MatrixName,'(',int2str(CP(2)),',',int2str(CP(1)),') = ',num2str(Matrix(CP(2),CP(1)))]);
            end;
          end;

        end;
      case 'select point',
        Point=get(UIAxes,'currentpoint');
        Point=floor(Point(1,1:2));
        if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),
          Polygon=line(Point(1)+[0 0 1 1 0],Point(2)+[0 1 1 0 0], ...
            'color','c', ...
            'parent',UIAxes, ...
            'marker','.', ...
            'tag','inquire polygon', ...
            'erasemode','normal', ...
            'clipping','on', ...
            'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])']);
        end;
      case 'select polygon',
        [CP,XData,YData]=LocalPolygonMovement(UIFig,UIAxes,Matrix,MatrixName,CP);
        if length(XData)>0,
          Polygon=line(XData,YData, ...
            'color','c', ...
            'parent',UIAxes, ...
            'marker','.', ...
            'linestyle','-', ...
            'tag','TMP polygon', ...
            'erasemode','normal', ...
            'clipping','on', ...
            'tag','inquire polygon', ...
            'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])']);
        end;
      case 'linear interpolate',
        [CP,XData,YData]=LocalLineMovement(UIFig,UIAxes,Matrix,MatrixName,1,CP); % 1 for FollowGrid
        if XData(1)==XData(2),
          if YData(1)==YData(2), % nothing to interpolate
          else,
            if YData(1)>YData(2),
              YData=fliplr(YData);
            end;
            MatVal(1)=Matrix(YData(1),XData(1));
            MatVal(2)=Matrix(YData(2),XData(1));
            Values=MatVal(1)+(MatVal(2)-MatVal(1))*(0:(YData(2)-YData(1)))/(YData(2)-YData(1));
            Matrix(YData(1):YData(2),XData(1))=transpose(Values);
            set(UD.UISurf,'cdata',Matrix);
          end;
        elseif YData(1)==YData(2),
          if XData(1)>XData(2),
            XData=fliplr(XData);
          end;
          MatVal(1)=Matrix(YData(1),XData(1));
          MatVal(2)=Matrix(YData(2),XData(2));
          Values=MatVal(1)+(MatVal(2)-MatVal(1))*(0:(XData(2)-XData(1)))/(XData(2)-XData(1));
          Matrix(YData(1),XData(1):XData(2))=Values;
          set(UD.UISurf,'cdata',Matrix);
        else,
          uiwait(msgbox('Oblique lines not yet supported.','modal'));
        end;
      case 'copy value',
        [CP,XData,YData]=LocalLineMovement(UIFig,UIAxes,Matrix,MatrixName,0,CP); % 0 for Don't have to FollowGrid
        Matrix(YData(2),XData(2))=Matrix(YData(1),XData(1));
        set(UD.UISurf,'cdata',Matrix);
      case 'copy polygon values',
        Polygon=findobj(UIFig,'tag','inquire polygon');
        if ~isempty(Polygon),
          [CP,XData,YData]=LocalLineMovement(UIFig,UIAxes,Matrix,MatrixName,0,CP); % 0 for Don't have to FollowGrid

          TMPpointer=get(UIFig,'pointer');
          set(UIFig,'pointer','watch');
          INSIDE=zeros(size(Matrix(:)));
          for i=1:length(Polygon),
            INSIDE=INSIDE|inpolygon(X(:),Y(:),get(Polygon(i),'xdata')-0.5,get(Polygon(i),'ydata')-0.5);
          end;
          set(UIFig,'pointer',TMPpointer);
          if any(INSIDE),
            INSIDE=reshape(INSIDE,size(X));
            Shift(1)=YData(2)-YData(1);
            Shift(2)=XData(2)-XData(1);
            Rows=intersect(1:size(INSIDE,1),(1:size(INSIDE,1))+Shift(1));
            Columns=intersect(1:size(INSIDE,2),(1:size(INSIDE,2))+Shift(2));
            To=logical(zeros(size(INSIDE)));
            To(Rows,Columns)=INSIDE(Rows-Shift(1),Columns-Shift(2));
            INSIDE(setdiff(1:size(INSIDE,1),Rows-Shift(1)),:)=0;
            INSIDE(:,setdiff(1:size(INSIDE,2),Columns-Shift(2)))=0;
            Matrix(To)=Matrix(INSIDE);
            set(UD.UISurf,'cdata',Matrix);
          end;
        end;
      case 'color limit',
        Point=get(UIAxes,'currentpoint');
        Point=floor(Point(1,1:2));
        if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),
          MatVal=Matrix(Point(2),Point(1));
          if strcmp(get(UIFig,'selectiontype'),'normal'),
            % update clim(1)
            Min=get(UD.UI(10),'min');
            Max=get(UD.UI(10),'max');
            if MatVal>Max,
              set(UD.UI(10:11),'max',MatVal);
            elseif MatVal<Min,
              set(UD.UI(10:11),'min',MatVal);
            end;
            set(UD.UI(10),'value',MatVal);
            stack=[10; stack];
          else,
            % update clim(2)
            Min=get(UD.UI(11),'min');
            Max=get(UD.UI(11),'max');
            if MatVal>Max,
              set(UD.UI(10:11),'max',MatVal);
            elseif MatVal<Min,
              set(UD.UI(10:11),'min',MatVal);
            end;
            set(UD.UI(11),'value',MatVal);
            stack=[11; stack];
          end;
        end;
      end;
    case 1, % accept
      gui_quit=1;
    case 2, % reset
      Matrix=BackupMatrix;
      set(UD.UISurf,'cdata',Matrix);
    case 3, % zoom
      XLim=get(UIAxes,'xlim');
      YLim=get(UIAxes,'ylim');
      set(UIAxes,'xlim',mean(XLim)+(XLim-mean(XLim))/2,'ylim',mean(YLim)+(YLim-mean(YLim))/2);
      if (2*(XLim(2)-XLim(1))>AxPosition(3)) | (2*(YLim(2)-YLim(1))>AxPosition(4)),
        set(UD.UISurf,'edgecolor','none');
      else,
        set(UD.UISurf,'edgecolor',[0 0 0]);
      end;
    case 4, % zoom out
      XLim=get(UIAxes,'xlim');
      YLim=get(UIAxes,'ylim');
      set(UIAxes,'xlim',mean(XLim)+(XLim-mean(XLim))*2,'ylim',mean(YLim)+(YLim-mean(YLim))*2);
      if (8*(XLim(2)-XLim(1))>AxPosition(3)) | (8*(YLim(2)-YLim(1))>AxPosition(4)),
        set(UD.UISurf,'edgecolor','none');
      else,
        set(UD.UISurf,'edgecolor',[0 0 0]);
      end;
    case 5, % horizontal scrollbar: row
      XMean=get(UD.UI(5),'value');
      XLim=get(UIAxes,'xlim');
      set(UIAxes,'xlim',XMean+(XLim-mean(XLim)));
    case 6, % vertical scrollbar: column
      YMean=-get(UD.UI(6),'value');
      YLim=get(UIAxes,'ylim');
      set(UIAxes,'ylim',YMean+(YLim-mean(YLim)));
    case 7, % popupmenu selection
    case 8, % change inside polygon
      TMPpointer=get(UIFig,'pointer');
      set(UIFig,'pointer','watch');
      Polygon=findobj(UIFig,'tag','inquire polygon');
      INSIDE=zeros(size(Matrix(:)));
      for i=1:length(Polygon),
        INSIDE=INSIDE|inpolygon(X(:),Y(:),get(Polygon(i),'xdata')-0.5,get(Polygon(i),'ydata')-0.5);
      end;
      set(UIFig,'pointer',TMPpointer);
      if any(INSIDE),
        answer=inputdlg('New value','Change value',1,{'NaN'});
        if ~isempty(answer),
          lasterr('');
          answer=evalin('caller',answer{1},'NaN');
          if isempty(lasterr) & isequal(size(answer),[1 1]),
            Matrix(INSIDE)=answer;
            set(UD.UISurf,'cdata',Matrix);
            set(UIFig,'name',[MatrixName,'(',int2str(CP(2)),',',int2str(CP(1)),') = ',num2str(Matrix(CP(2),CP(1)))]);
          end;
        end;
      end;
    case 9, % clear polygons
      delete(findobj(UIFig,'tag','inquire polygon'));
    case 10, % change clim(1)
      CLim=get(UIAxes,'clim');
      CLimNew(1)=get(UD.UI(10),'value'); % changed
      CLimNew(2)=get(UD.UI(11),'value');
      if CLim(2)<=CLimNew(1),
        CLimNew(1)=CLim(2)-(CLim(2)-CLim(1))/10;
        set(UD.UI(10),'value',CLimNew(1));
      end;
      set(UIAxes,'clim',CLimNew);
    case 11, % change clim(2)
      CLim=get(UIAxes,'clim');
      CLimNew(1)=get(UD.UI(10),'value');
      CLimNew(2)=get(UD.UI(11),'value'); % changed
      if CLimNew(2)<=CLim(1),
        CLimNew(2)=CLim(1)+(CLim(2)-CLim(1))/10;
        set(UD.UI(11),'value',CLimNew(2));
      end;
      set(UIAxes,'clim',CLimNew);
    end;
  end;
  if ishandle(UIFig),
    set(UIFig,'pointer','arrow');
  end;
end;
if ishandle(UIFig),
  delete(UIFig);
end;
if nargout>0,
  Output=Matrix(1:end-1,1:end-1); % remove last row and column, which were used for plotting
end;

function [CP,XData,YData]=LocalLineMovement(UIFig,UIAxes,Matrix,MatrixName,FollowGrid,CPin);
CP=CPin;
NumPoints=0;
while 1,
  Point=get(UIAxes,'currentpoint');
  XLim=get(UIAxes,'xlim');
  YLim=get(UIAxes,'ylim');
  Point=floor(Point(1,1:2));
  if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),
    if NumPoints==0,
      Line=line(Point(1)+0.5,Point(2)+0.5, ...
        'color','k', ...
        'parent',UIAxes, ...
        'marker','.', ...
        'linewidth',1, ...
        'tag','TMP line', ...
        'erasemode','xor', ...
        'clipping','off', ...
        'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])']);
    else,
      XData=floor(get(Line,'xdata')); % floor used because 0.5 was added
      YData=floor(get(Line,'ydata'));
      delete(Line);
      break;
    end;
    NumPoints=NumPoints+1;
  end;
  if ishandle(UIFig),
    TmpStack=get(UIFig,'userdata');
    set(UIFig,'userdata',[]);
  end;
  clicked=0;
  while ~clicked,
    if ishandle(UIFig),
      if isempty(get(UIFig,'userdata')),
        waitfor(UIFig,'userdata');
      end;
    end;
    if ishandle(UIFig),
      LocalStack=get(UIFig,'userdata');
      set(UIFig,'userdata',[]);
      if any(LocalStack==0), % clicked
        clicked=1;
      elseif any(LocalStack==-1), % motion
        Point=get(UIAxes,'currentpoint');
        Point=floor(Point(1,1:2));
        if (Point(1)<size(Matrix,2)) & (Point(2)<size(Matrix,1)) & (Point(1)>=1) & (Point(2)>=1),
          CP=Point;
          set(UIFig,'name',[MatrixName,'(',int2str(CP(2)),',',int2str(CP(1)),') = ',num2str(Matrix(CP(2),CP(1)))]);
          XData=get(Line,'xdata');
          YData=get(Line,'ydata');
          if FollowGrid,
            if abs(Point(1)+0.5-XData(1))>abs(Point(2)+0.5-YData(1)),
              Point(2)=YData(1)-0.5;
            else,
              Point(1)=XData(1)-0.5;
            end;
          end;
          set(Line,'xdata',[XData(1) Point(1)+0.5],'ydata',[YData(1) Point(2)+0.5]);
        end;
      end;
    end;
  end;
  if ishandle(UIFig),
    LocalStack=get(UIFig,'userdata');
    set(UIFig,'userdata',TmpStack);
  end;
%
end;

function [CP,XData,YData]=LocalPolygonMovement(UIFig,UIAxes,Matrix,MatrixName,CPin);
CP=CPin;
XData=[];
YData=[];
NumPoints=0;
Polygon=[];
while 1,
  Point=get(UIAxes,'currentpoint');
  XLim=get(UIAxes,'xlim');
  YLim=get(UIAxes,'ylim');
  Point=Point(1,1:2);
  if (Point(1)<=XLim(2)) & (Point(2)<=YLim(2)) & (Point(1)>=XLim(1)) & (Point(2)>=YLim(1)),
    if strcmp(get(UIFig,'selectiontype'),'normal'),
      if NumPoints==0,
        Polygon=line([Point(1) Point(1)],[Point(2) Point(2)], ...
          'color','k', ...
          'parent',UIAxes, ...
          'marker','.', ...
          'linewidth',1, ...
          'tag','TMP line', ...
          'erasemode','xor', ...
          'clipping','off', ...
          'buttondownfcn',['set(gcbf,''userdata'',[get(gcbf,''userdata'');0])']);
      else,
        XData=get(Polygon,'xdata');
        YData=get(Polygon,'ydata');
        set(Polygon,'xdata',[XData(1:end-1) Point(1) XData(1)],'ydata',[YData(1:end-1) Point(2) YData(1)]);
      end;
      NumPoints=NumPoints+1;
    else,
      if isempty(Polygon)
        break;
      else
        XData=get(Polygon,'xdata'); % floor used because 0.5 was added
        YData=get(Polygon,'ydata');
        delete(Polygon);
        break;
      end
    end;
  end;
  if ishandle(UIFig),
    TmpStack=get(UIFig,'userdata');
    set(UIFig,'userdata',[]);
  end;
  clicked=0;
  while ~clicked,
    if ishandle(UIFig),
      if isempty(get(UIFig,'userdata')),
        waitfor(UIFig,'userdata');
      end;
    end;
    if ishandle(UIFig),
      LocalStack=get(UIFig,'userdata');
      set(UIFig,'userdata',[]);
      if any(LocalStack==0), % clicked
        clicked=1;
      elseif any(LocalStack==-1), % motion
        Point=get(UIAxes,'currentpoint');
        XLim=get(UIAxes,'xlim');
        YLim=get(UIAxes,'ylim');
        Point=Point(1,1:2);
        if (Point(1)<=min(size(Matrix,2),XLim(2))) & (Point(2)<=min(size(Matrix,1),YLim(2))) & (Point(1)>=max(1,XLim(1))) & (Point(2)>=max(1,YLim(1))),
          CP=floor(Point);
          set(UIFig,'name',[MatrixName,'(',int2str(CP(2)),',',int2str(CP(1)),') = ',num2str(Matrix(CP(2),CP(1)))]);
%          XData=get(Polygon,'xdata');
%          YData=get(Polygon,'ydata');
%          set(Polygon,'xdata',[XData(1:end-2) Point(1) XData(1)],'ydata',[YData(1:end-2) Point(2) YData(1)]);
        end;
      end;
    end;
  end;
  if ishandle(UIFig),
    LocalStack=get(UIFig,'userdata');
    set(UIFig,'userdata',TmpStack);
  end;
%
end;


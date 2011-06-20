function fout = mwaitbar(varargin)
%MWAITBAR Display window with one or more wait bars.
%   H = MWAITBAR(X,'title') creates and displays a wait bar of 
%   fractional length X.  The handle to the waitbar figure is
%   returned in H.  X should be between 0 and 1.  Each 
%   subsequent call to waitbar, MWAITBAR(X), extends the length 
%   of the bar to the new position X.
%
%   MWAITBAR is typically used inside a FOR loop that performs a 
%   lengthy computation.  A sample usage is shown below:
%
%       h = mwaitbar({0 0},{'Please wait...','inner loop'});
%       for i=1:10,
%         mwaitbar(h,2,sprintf('loop %i',i))
%         for j=1:30,
%           % computation here %
%           mwaitbar(h,{i/10 j/30})
%         end
%       end
%       mwaitbar('close',h)

% Possible extension: conditional increments
%      relate a certain range of bar1 to full bar2, such that
%      when bar2 is updated bar1 is automatically updated as well.

persistent CurrentH

if ~ishandle(CurrentH), CurrentH=[]; end;

Create=0;
H=[];
SubH=[];
Value={};
Title={};
Opt={};
if nargout,
  fout=[];
end;

firstarg=1;
INP=varargin;
while length(INP)>=1,
  X=INP{1};
  if ischar(X),
    if strcmp(lower(X),'activate') & firstarg,
      if nargin<2,
        error('Insufficient arguments');
      elseif ishandle(INP{2}),
        CurrentH=INP{2};
        return;
      elseif isempty(INP{2}) & isnumeric(INP{2}),
        CurrentH=[];
        return;
      else,
        error('Unexpected second argument.');
      end;
    elseif (strcmp(lower(X),'delete') | strcmp(lower(X),'close')) & firstarg,
      if nargin<2,
        if ishandle(CurrentH),
          delete(CurrentH);
        end;
        CurrentH=[];
        return;
      elseif ishandle(INP{2}),
        delete(INP{2});
        if isequal(INP{2},CurrentH),
          CurrentH=[];
        end;
        return;
      elseif isnumeric(INP{2}), % handle of closed figure?
      else,
        error('Unexpected second argument.');
      end;
    elseif strcmp(lower(X),'new'),
      Create=1;
    elseif 2*round(length(INP)/2)==length(INP), % even number of arguments left
      if isempty(H),
        H=CurrentH;
      end;
      Opt=INP;
      break;
    elseif isempty(Title),
      Title={X};
    else,
      error(sprintf('Unable to interpret argument: %s.',X));
    end;
  elseif iscell(X),
    if isempty(H),
      H=CurrentH;
    end;
    if iscellstr(X),
      if isempty(Title),
        Title=X;
      else,
        error('Unexpected cell string.');
      end;
    else,
      if isempty(Value),
        Value=X;
      else,
        error('Unexpected cell data.');
      end;
    end;
  elseif ~isequal(size(X),[1 1]) | ~isnumeric(X),
    error('Scalar argument expected.');
  elseif ishandle(X) & strcmp(get(X,'tag'),'MWAITBAR') & isempty(H),
    H=X;
  elseif X>1,
    if X==round(X),
      SubH=X;
      if isempty(H),
        H=CurrentH;
      end;
    else, %deleted handle
      return;
    end;
  elseif X>=0, % bar display fraction
    Value={X};
    if isempty(H),
      H=CurrentH;
    end;
  else, % H<0
    error('Error interpreting first argument.');
  end;
  INP=INP(2:end);
  firstarg=0;
end;

if nargin==0,
  H=CurrentH;
end;

if isempty(H),
  if ~isempty(SubH),
    TmpT=Title;
    TmpV=Value;
    Value=cell([1 SubH]);
    Value(:)={0};
    Title=cell([1 SubH]);
    Title(:)={''};
    Title{end}=TmpT;
    Value{end}=TmpV;
    SubH=[];
  elseif isempty(Value) & isempty(Title),
    Value={0};
    Title={'Please wait ...'};
  elseif isempty(Value),
    Value=cell(size(Title));
    Value(:)={0};
  elseif isempty(Title),
    Title=cell(size(Value));
    Title(:)={''};
  end;
  Create=1;
end;

if ~isempty(Value) & ~isempty(Title),
  if length(Value)~=length(Title),
    error('Length of value and title cells don''t match');
  end;
end;
if iscell(Value),
  for i=1:length(Value),
    if ~isnumeric(Value{i}) | Value{i}<0 | Value{i}>1,
      error('Invalid waitbar value');
    end;
  end;
end;

if Create,
  if isempty(Value)~=isempty(Title),
    error('Number of values does not match number of titles.');
  end;
  
  NBars=length(Value);

  oldRootUnits = get(0,'Units');

  set(0, 'Units', 'pixels');
  pos = get(0,'ScreenSize');
  
  margin = 20;
  width = 300;
  height = 50;
  pos = [pos(3)/2-(width+2*margin)/2 pos(4)/2-(NBars*height+margin)/2 width+2*margin NBars*height+margin];

  H = figure(...
          'Units', 'pixels', ...
          'Position', pos, ...
          'Resize','off', ...
          'CreateFcn','', ...
          'NumberTitle','off', ...
          'IntegerHandle','off', ...
          'MenuBar', 'none', ...
          'Tag','MWAITBAR');
  colormap([]);
  
  for i=NBars:-1:1,
    ax = axes('XLim',[0 1], ...
                 'YLim',[0 1], ...
                 'Box','on', ...
                 'units','pixels', ...
                 'Position',[margin margin+(NBars-i)*height width 10],...
                 'XTickMode','manual',...
                 'YTickMode','manual',...
                 'XTick',[],...
                 'YTick',[],...
                 'XTickLabelMode','manual',...
                 'XTickLabel',[],...
                 'YTickLabelMode','manual',...
                 'YTickLabel',[]);

    Hnd.t(i)=get(ax,'title');

    a=0;
    xcoor = [0 a; a 1; a 1; 0 a];
    ycoor = [0 0; 0 0; 1 1; 1 1];
    Hnd.p(i) = patch(xcoor,ycoor,zeros(4,2),'k','facecolor','flat','edgecolor','k','facevertexcdata',[1 0 0;1 1 1]);
    % how to speed up drawing? erasemode none -> no colors!?
    %                          use image with erasemode none and clipping?
  end;
  
  set(H,'HandleVisibility','callback','userdata',Hnd);

  set(0, 'Units', oldRootUnits);
  
  CurrentH=H;
else,
  Hnd=get(H,'userdata');
end;

if isempty(SubH),
  for i=1:length(Value),
    xcoor = [0 Value{i}; Value{i} 1; Value{i} 1; 0 Value{i}];
    set(Hnd.p(i),'xdata',xcoor);
  end;
  for i=1:length(Title),
    set(Hnd.t(i),'string',Title{i});
  end;
else,
  if ~isempty(Value),
    xcoor = [0 Value{1}; Value{1} 1; Value{1} 1; 0 Value{1}];
    set(Hnd.p(SubH),'xdata',xcoor);
  end;
  if ~isempty(Title),
    set(Hnd.t(SubH),'string',Title{1});
  end;
end;

if ~isempty(Opt),
  Opt=reshape(Opt,[2 length(Opt)/2]);
  if ~iscellstr(Opt(1,:)),
    error('Invalid option.'),
  end;
  for i=1:size(Opt,2),
    switch Opt{1,i},
    case 'figurecolor',
      set(H,'color',Opt{2,i});
    case 'color',
      set(Hnd.p,'facecolor',Opt{2,i});
    case 'backgroundcolor',
      set(findall(H,'type','axes'),'color',Opt{2,i});
    case 'linecolor',
      set(findall(H,'type','axes'),'xcolor',Opt{2,i},'ycolor',Opt{2,i});
      set(Hnd.p,'edgecolor',Opt{2,i});
    case 'titlecolor',
      set(Hnd.t,'color',Opt{2,i});
    case 'fontangle',
      set(Hnd.t,'fontangle',Opt{2,i});
    case 'fontname',
      set(Hnd.t,'fontname',Opt{2,i});
    case 'fontsize',
      set(Hnd.t,'fontsize',Opt{2,i});
    case 'fontunits',
      set(Hnd.t,'fontunits',Opt{2,i});
    case 'fontweight',
      set(Hnd.t,'fontweight',Opt{2,i});
    otherwise,
      error(['Unknown option: ' Opt{2,i}]);
    end;
  end;
end;

drawnow;

if nargout==1,
  fout = H;
end



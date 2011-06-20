function refresh(Obj);

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);
Tag=get(MainItem,'tag');
PHandle=get(MainItem,'parent');

UD=get(MainItem,'userdata');
Info=UD.Info;

ErrorMsg='';
X=[]; Y=[]; Z=[]; C=[];
X0=[]; Y0=[]; Z0=[];

if isempty(Info.ShowTime),
  if isempty(Info.ShowFrame),
    Frame=[];
    ErrorMsg='No frame specified.';
  else,
    Frame=Info.ShowFrame;
  end;
else,
  % Frame=GetFrame(Info.ShowTime) from Info.TValues;
  if Info.ShowTime<=Info.TValues{1},
    Frame=1;
  elseif Info.ShowTime>=Info.TValues{end},
    Frame=length(Info.TValues);
  else,
    i=2;
    while (i<length(Info.TValues)),
      if isempty(Info.TValues{i}),
        [t,ErrorMsg]=ds_eval(Info.TStream,i);
        if ~isempty(ErrorMsg),
          break;
        else,
          Info.TValues{i}=t;
        end;
      end;
      if Info.ShowTime<=Info.TValues{i},
        break;
      else,
        i=i+1;
      end;
    end;
    if isempty(ErrorMsg),
      % Info.ShowTime between Info.TValues{i-1} and Info.TValues{i}
      Frame=i+(Info.ShowTime-Info.TValues{i-1})/(Info.TValues{i}-Info.TValues{i-1});
    end;
  end;
end;

NFrames=1;
switch Info.LMode,
case 'xy line',
  if isempty(ErrorMsg),
    [X0,ErrorMsg]=ds_eval(Info.X0Stream,Frame);
    NFrames=max(NFrames,Info.X0Stream.NumberOfFields);
  end;
  X0=reshape(X0,[1 prod(size(X0))]);
  if isempty(ErrorMsg),
    [Y0,ErrorMsg]=ds_eval(Info.Y0Stream,Frame);
    NFrames=max(NFrames,Info.Y0Stream.NumberOfFields);
  end;
  Y0=reshape(Y0,[1 prod(size(Y0))]);
  if isempty(ErrorMsg),
    if isa(Info.CStream,'datastream'),
      [C,ErrorMsg]=ds_eval(Info.CStream,Frame);
      NFrames=max(NFrames,Info.CStream.NumberOfFields);
    else,
      C=Y0;
    end;
    C=reshape(C,[1 prod(size(C))]);
  end;
  X0,Y0,C
  if ~isequal(size(X0),size(Y0),size(C)),
    ErrorMsg='Line sizes do not match.';
  end;

case 'xyz line',
  if isempty(ErrorMsg),
    [X0,ErrorMsg]=ds_eval(Info.X0Stream,Frame);
    NFrames=max(NFrames,Info.X0Stream.NumberOfFields);
  end;
  X0=reshape(X0,[1 prod(size(X0))]);
  if isempty(ErrorMsg),
    [Y0,ErrorMsg]=ds_eval(Info.Y0Stream,Frame);
    NFrames=max(NFrames,Info.Y0Stream.NumberOfFields);
  end;
  Y0=reshape(Y0,[1 prod(size(Y0))]);
  if isempty(ErrorMsg),
    [Z0,ErrorMsg]=ds_eval(Info.Z0Stream,Frame);
    NFrames=max(NFrames,Info.Z0Stream.NumberOfFields);
  end;
  Z0=reshape(Z0,[1 prod(size(Z0))]);
  if isempty(ErrorMsg),
    if isa(Info.CStream,'datastream'),
      [C,ErrorMsg]=ds_eval(Info.CStream,Frame);
      NFrames=max(NFrames,Info.CStream.NumberOfFields);
    else,
      C=Z0;
    end;
    C=reshape(C,[1 prod(size(C))]);
  end;
  if ~isequal(size(X0),size(Y0),size(Z0),size(C)),
    ErrorMsg='Line sizes do not match.';
  end;

case 's(x,y)z(x,y) cross',
  if isempty(ErrorMsg),
    [X0,ErrorMsg]=ds_eval(Info.X0Stream,Frame);
    NFrames=max(NFrames,Info.X0Stream.NumberOfFields);
  end;
  X0=reshape(X0,[1 prod(size(X0))]);
  if isempty(ErrorMsg),
    [Y0,ErrorMsg]=ds_eval(Info.Y0Stream,Frame);
    NFrames=max(NFrames,Info.Y0Stream.NumberOfFields);
  end;
  Y0=reshape(Y0,[1 prod(size(Y0))]);
  if isempty(ErrorMsg),
    [X,ErrorMsg]=ds_eval(Info.XStream,Frame);
    NFrames=max(NFrames,Info.XStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    [Y,ErrorMsg]=ds_eval(Info.YStream,Frame);
    NFrames=max(NFrames,Info.YStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    [Z,ErrorMsg]=ds_eval(Info.ZStream,Frame);
    NFrames=max(NFrames,Info.ZStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    if isa(Info.CStream,'datastream'),
      [C,ErrorMsg]=ds_eval(Info.CStream,Frame);
      NFrames=max(NFrames,Info.CStream.NumberOfFields);
    else,
      C=Z;
    end;
  end;
  if ~isequal(size(X0),size(Y0)),
    ErrorMsg='Line sizes do not match.';
  elseif ~isequal(size(X),size(Y),size(Z),size(C)),
    ErrorMsg='Data sizes do not match.';
  end;
  if isempty(ErrorMsg),
    Z0=griddata(X,Y,Z,X0,Y0);
    C=griddata(X,Y,C,X0,Y0);
    X0(2:end)=sqrt((X0(2:end)-X0(1:(end-1))).^2+(Y0(2:end)-Y0(1:(end-1))).^2);
    X0(1)=0; X0=cumsum(X0);
    Y0=Z0;
    Z0=[];
  end;

case 'xyz(x,y) cross',
  if isempty(ErrorMsg),
    [X0,ErrorMsg]=ds_eval(Info.X0Stream,Frame);
    NFrames=max(NFrames,Info.X0Stream.NumberOfFields);
  end;
  X0=reshape(X0,[1 prod(size(X0))]);
  if isempty(ErrorMsg),
    [Y0,ErrorMsg]=ds_eval(Info.Y0Stream,Frame);
    NFrames=max(NFrames,Info.Y0Stream.NumberOfFields);
  end;
  Y0=reshape(Y0,[1 prod(size(Y0))]);
  if isempty(ErrorMsg),
    [X,ErrorMsg]=ds_eval(Info.XStream,Frame);
    NFrames=max(NFrames,Info.XStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    [Y,ErrorMsg]=ds_eval(Info.YStream,Frame);
    NFrames=max(NFrames,Info.YStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    [Z,ErrorMsg]=ds_eval(Info.ZStream,Frame);
    NFrames=max(NFrames,Info.ZStream.NumberOfFields);
  end;
  if isempty(ErrorMsg),
    if isa(Info.CStream,'datastream'),
      [C,ErrorMsg]=ds_eval(Info.CStream,Frame);
      NFrames=max(NFrames,Info.CStream.NumberOfFields);
    else,
      C=Z;
    end;
  end;
  if ~isequal(size(X0),size(Y0)),
    ErrorMsg='Line sizes do not match.';
  elseif ~isequal(size(X),size(Y),size(Z),size(C)),
    ErrorMsg='Data sizes do not match.';
  end;
  if isempty(ErrorMsg),
    Z0=griddata(X,Y,Z,X0,Y0);
    C=griddata(X,Y,C,X0,Y0);
  end;
end;

delete(AllItems);
if isempty(ErrorMsg),
  if isempty(C), % constant colour
    MainItem=line('parent',PHandle, ...
     'tag',Tag, ...
     'xdata',[], ...
     'ydata',[], ...
     'zdata',[], ...
     'clipping',OnOff(Info.Clipped), ...
     'visible',OnOff(Info.Visible));
  else, % shaded colour
    MainItem=patch('parent',PHandle, ...
     'tag',Tag, ...
     'xdata',[], ...
     'ydata',[], ...
     'zdata',[], ...
     'cdata',[], ...
     'clipping',OnOff(Info.Clipped), ...
     'visible',OnOff(Info.Visible));
    % process color information
    if strcmp(Info.CMode,'continuous'),
      CRange=md_clrmngr(Obj.Tag,xx_colormap(Info.CCMap)); % reserve and get range
      if strcmp(Info.CCLim,'auto'),
        CLim=[min(C(:)) max(C(:))];
      else,
        CLim=Info.CCLim;
      end;
      CLimDiff=CLim(2)-CLim(1);
      if CLimDiff==0,
        CLimDiff=1;
      end;
      C=CRange(1)+(CRange(2)-CRange(1))* ...
          min(max((C-CLim(1))/CLimDiff,0),1);
    else, % classified,
      ClassColors=Info.CClassColors;
      C=cont2class(C,Info.CThresholds)+1;
      NaNs=find(isnan(ClassColors(:,1)));
      ClassColors(NaNs,:)=1;
      Indices=1:(length(Info.CThresholds)+1);
      Indices(NaNs)=NaN;
      CRange=md_clrmngr(Obj.Tag,ClassColors); % reserve and get range
      C=CRange(1)-1+Indices(C);
    end;
    % <---------------- Colormap
    set(MainItem, ...
      'xdata',[X0 NaN], ...
      'ydata',[Y0 NaN], ...
      'zdata',[Z0 NaN], ...
      'cdata',[C NaN], ...
      'facecolor','none', ...
      'edgecolor','interp');
    % <---------------- Animation options
    UD.Animation.Type='Datastream';
    UD.Animation.Nsteps=NFrames;
  end;
else,
  MainItem=line('parent',PHandle, ...
     'tag',Tag, ...
     'xdata',[], ...
     'ydata',[], ...
     'zdata',[]);
  uiwait(msgbox(ErrorMsg,'modal'));
end;

UD.Name=UD.Info.Name;
set(MainItem,'userdata',UD);


function Str=OnOff(L),
if L,
  Str='on';
else,
  Str='off';
end;

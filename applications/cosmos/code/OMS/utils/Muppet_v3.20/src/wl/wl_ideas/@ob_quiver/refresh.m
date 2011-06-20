function refresh(Obj);

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

ErrorMsg='';
X=[]; Y=[]; Z=[]; C=[];

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

switch Info.LightMode,
case 'unlit vectors',
  LOpt={'edgecolor','none', ...
        'facecolor','flat', ...
        'facelighting','none', ...
        'linestyle','-', ...
        'marker','none'};
case 'dull lit vectors',
  LOpt={'edgecolor','none', ...
        'facecolor','flat', ...
        'facelighting','phong', ...
        'BackFaceLighting','lit', ...
        'AmbientStrength',0.6, ...
        'DiffuseStrength',0.9, ...
        'SpecularStrength',0, ...
        'linestyle','-', ...
        'marker','none'};
case 'shiny lit vectors',
  LOpt={'edgecolor','none', ...
        'facecolor','flat', ...
        'facelighting','phong', ...
        'BackFaceLighting','lit', ...
        'AmbientStrength',0.3, ...
        'DiffuseStrength',0.6, ...
        'SpecularStrength',0.9, ...
        'SpecularExponent',10, ...
        'SpecularColorReflectance',1, ...
        'linestyle','-', ...
        'marker','none'};
otherwise,
  LOpt={};
end;

set(MainItem, ...
    LOpt{:}, ...
    'clipping',OnOff(Info.Clipped), ...
    'visible',OnOff(Info.Visible));


if isempty(ErrorMsg), [X,ErrorMsg]=ds_eval(Info.XStream,Frame); end;
if isempty(ErrorMsg), [Y,ErrorMsg]=ds_eval(Info.YStream,Frame); end;
if isempty(ErrorMsg), [Z,ErrorMsg]=ds_eval(Info.ZStream,Frame); end;
if isempty(ErrorMsg), [U,ErrorMsg]=ds_eval(Info.UStream,Frame); end;
if isempty(ErrorMsg), [V,ErrorMsg]=ds_eval(Info.VStream,Frame); end;
if isempty(ErrorMsg),
  if isa(Info.CStream,'datastream'),
    [C,ErrorMsg]=ds_eval(Info.CStream,Frame);
  else,
    C=sqrt(U.^2+V.^2);
  end;
end;

if isempty(ErrorMsg) & isequal(size(X),size(Y),size(Z),size(C),size(U),size(V)),
  % process color information
  if strcmp(Info.CMode,'continuous'),
    CRange=md_clrmngr(Obj.Tag,xx_colormap(Info.CCMap)); % reserve and get range
    if strcmp(Info.CCLim,'auto'),
      CLim=[min(C(:)) max(C(:))];
    else,
      CLim=Info.CCLim;
    end;
    UD.CLim=CLim;
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
    Indices=transpose(1:(length(Info.CThresholds)+1));
    Indices(NaNs)=NaN;
    CRange=md_clrmngr(Obj.Tag,ClassColors); % reserve and get range
    C=CRange(1)-1+Indices(C);
    UD.CLim=[1 length(Info.CThresholds)+1];
  end;
  % <---------------- Colormap
  Prnt=get(MainItem,'parent');
  TempItem=xx_quiver(Prnt,Info.Scale,X,Y,U,V,C,'zdata',Z);
  Props={'faces','vertices','facevertexcdata'};
  set(MainItem,Props,get(TempItem,Props));
  delete(TempItem);
  % <---------------- Animation options
  UD.Animation.Type='Datastream';
  UD.Animation.Nsteps=nframes(Info);
else,
  set(MainItem, ...
      'faces',[], ...
      'vertices',[], ...
      'facevertexcdata',[]);
  % <---------------- No animation options
  UD.Animation=[];
end;

if ~isempty(ErrorMsg),
  uiwait(msgbox(ErrorMsg,'modal'));
end;

UD.Name=UD.Info.Name;
set(MainItem,'userdata',UD); % set option only to it(1) and keep the other ones empty
%if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;


function Str=OnOff(L),
if L,
  Str='on';
else,
  Str='off';
end;

function NewValue=ui_param(ParamOpt,DefValue),
% UI_PARAM
%          NewValue=
%             UI_PARAM(ParamOpt)
%             UI_PARAM(ParamOpt,DefValue)

NewValue={};

switch nargin,
case 1, % =UI_PARAM(ParamOpt)
  DefValue={};
case {0},
  warning('Incorrect number of input arguments.');
  return;
case 2, % =UI_PARAM(ParamOpt,DefValue)
  if length(ParamOpt)~=length(DefValue),
    warning('Number of default values should match number of parameters.');
    NewValue=DefValue;
    return;
  end;
end;

if isempty(ParamOpt), % no parameters
  return;
elseif ~isstruct(ParamOpt), % ParamOpt should be a struct
  warning('Invalid parameter options.');
  NewValue=DefValue;
  return;
end;

XX=xx_constants;

EditWidth=200;
Fig_Width=EditWidth+2*XX.Margin;
Fig_Height=2*XX.Margin+XX.But.Height+length(ParamOpt)*(XX.Margin+XX.Txt.Height+XX.But.Height);

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect);

rect = [XX.Margin XX.Margin (Fig_Width-3*XX.Margin)/2 XX.But.Height];
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','cancel', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',-1)');

rect(1) = (Fig_Width+XX.Margin)/2;
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','continue', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',0)');

rect(1) = XX.Margin;
rect(2) = rect(2)+rect(4)+XX.Margin;
rect(3) = EditWidth;
rect(4) = XX.But.Height;

for i=length(ParamOpt):-1:1,
  if isempty(DefValue),
    [StrRange,StrValue]=val2str(ParamOpt(i),{});
  else,
    [StrRange,StrValue]=val2str(ParamOpt(i),DefValue(i));
  end;
  h(i,2)=uicontrol('style','edit', ...
          'position',rect, ...
          'backgroundcolor',XX.Clr.White, ...
          'horizontalalignment','right', ...
          'string',StrValue, ...
          'parent',fig, ...
          'callback',['set(gcbf,''userdata'',' num2str(i) ')']);
  rect(2) = rect(2)+rect(4);
  rect(4) = XX.Txt.Height;
  h(i,1)=uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','left', ...
          'string',[ParamOpt(i).Name ' (' StrRange ')'], ...
          'parent',fig);
  rect(2) = rect(2)+rect(4)+XX.Margin;
  rect(4) = XX.But.Height;
  NewValue{i}=eval(StrValue);
end;


set(fig,'visible','on');
while 1,
  waitfor(fig,'userdata');
  Cmd=get(fig,'userdata');
  set(fig,'userdata',[]);
  switch Cmd,
  case -1, % cancel
    NewValue={};
    break;
  case 0, % continue
    break;
  otherwise, % edit
    i=Cmd;
    Val=eval(get(h(i,2),'string'),'NaN');
    switch ParamOpt(i).Type
    case 'INT',
      if isequal(size(Val),[1 1]) & all(isint(Val(:))) & ...
          all(Val(:)>=ParamOpt(i).Value(1)) & ...
          all(Val(:)<=ParamOpt(i).Value(2)),
        NewValue{i}=Val;
      end;
      set(h(i,2),'string',num2str(NewValue{i}));
    case 'INTARR',
      if isequal(sort(size(Val)),[1 length(Val)]) & all(isint(Val(:))) & ...
          all(Val(:)>=ParamOpt(i).Value(1)) & ...
          all(Val(:)<=ParamOpt(i).Value(2)),
        NewValue{i}=Val;
      end;
      set(h(i,2),'string',vec2str(NewValue{i}));
    case 'REAL',
      if isequal(size(Val),[1 1]) & ...
          all(Val(:)>=ParamOpt(i).Value(1)) & ...
          all(Val(:)<=ParamOpt(i).Value(2)),
        NewValue{i}=Val;
      end;
      set(h(i,2),'string',num2str(NewValue{i}));
    end;
  end;
end;
delete(fig);


function [StrRange,StrValue]=val2str(P,DefV);

switch P.Type,
case {'INT','INTARR','REAL'},
  if isinf(P.Value(1)),
    if isinf(P.Value(2)), % [-inf inf]
      StrRange=P.Type;
    else, % [-inf m]
      StrRange=[P.Type ' <= ' num2str(P.Value(2))];
    end;
  else,
    if isinf(P.Value(2)), % [k inf]
      StrRange=[P.Type ' >= ' num2str(P.Value(1))];
    else, % [k m]
      StrRange=[num2str(P.Value(1)) ' <= ' P.Type ' <= ' num2str(P.Value(2))];
    end;
  end;
end;

switch P.Type,
case 'INT',
  if isempty(DefV),
    if isinf(P.Value(1)),
      if isinf(P.Value(2)), % [-inf inf]
        StrValue='0';
      else, % [-inf m]
        StrValue=num2str(P.Value(2));
      end;
    else,
      StrValue=num2str(P.Value(1));
    end;
  else,
    StrValue=num2str(DefV{1});
  end;
case 'INTARR',
  if isempty(DefV),
    if isinf(P.Value(1)),
      if isinf(P.Value(2)), % [-inf inf]
        StrValue='[]';
      else, % [-inf m]
        StrValue='[]';
      end;
    else,
      if isinf(P.Value(2)), % [k inf]
        StrValue='[]';
      else, % [k m]
        StrValue=['[' num2str(P.Value(1)) ':' num2str(P.Value(2)) ']'];
      end;
    end;
  else,
    StrValue=vec2str(DefV{1});
  end;
case 'REAL',
  if isempty(DefV),
    if isinf(P.Value(1)),
      if isinf(P.Value(2)), % [-inf inf]
        StrValue='0';
      else, % [-inf m]
        StrValue=num2str(P.Value(2));
      end;
    else,
      StrValue=num2str(P.Value(1));
    end;
  else,
    StrValue=num2str(DefV{1});
  end;
end;

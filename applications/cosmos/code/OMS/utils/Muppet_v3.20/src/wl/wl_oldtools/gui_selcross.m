function [Indices,Values]=gui_selcross(List,AllEnable,Default),
% GUI_SELCROSS Select a cross section or grid point from a GUI.
%      {iSelected jSelected kSelected}=
%        GUI_SELCROSS({iList jList kList},{iInitial jInitial kInitial},AllOption);
%      AllOption = 'All', 'OneAll', 'NoAll'

if (nargin<1),
  help gui_selcross
  return;
elseif nargin==1,
  AllEnable='NoAll';
  ndim=length(List);
  Default=mat2cell(ones(1,ndim),1,ones(1,ndim));
else,
  ndim=length(List);
  if isempty(strmatch(AllEnable,{'All','OneAll','NoAll'})),
    AllEnable='NoAll';
  end;
  if nargin==2,
    Default=mat2cell(ones(1,ndim),1,ones(1,ndim));
  end;
end;

% Check Default
switch AllEnable,
case 'NoAll',
  for dim=1:length(Default),
    if strcmp(Default{dim},':'),
      Default{dim}=1;
    end;
  end;
case 'OneAll'
  NumAll=0;
  for dim=1:length(Default),
    if strcmp(Default{dim},':'),
      NumAll=NumAll+1;
      if NumAll>1,
        Default{dim}=1;
      end;
    end;
  end;
  if NumAll==0, % None set to ':'
    Default{1}=':';
  end;
end;

Fig_Width=280;
Field_Height=22;
Margin=10;
Fig_Height=(2+ndim)*Margin+(1+ndim*2)*Field_Height;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=figure('menu','none');
set(fig,'units','pixels', ...
        'position',rect, ...
        'inverthardcopy','off', ...
        'resize','off', ...
        'color',get(0,'DefaultUicontrolBackgroundcolor'), ...
        'numbertitle','off', ...
        'handlevisibility','off', ...
        'name','Select grid index ...', ...
        'tag','Select Window');
%        'closerequestfcn','', ...
%        'windowstyle','modal', ...

if ndim<3,
  Str={'M','N','K'};
else,
  Str=char(64+(1:ndim));
  Str=mat2cell(Str,1,ones(1,length(Str)));
end;

for dim=ndim:-1:1,
  if strcmp(Default{dim},':'),
    initIndex=1;
  else,
    initIndex=max(min(length(List{dim}),Default{dim}),1);
  end;
  txt(dim)=uicontrol('style','text', ...
            'position',[Margin (2+ndim-dim)*Margin+(1+ndim-dim)*2*Field_Height Fig_Width/3-Margin Field_Height-4], ...
            'string',[Str{dim},'=',gui_str(List{dim}(initIndex))], ...
            'horizontalalignment','left', ...
            'value',initIndex, ...
            'parent',fig);
  pum(dim)=uicontrol('style','popupmenu', ...
            'position',[Fig_Width/3 (2+ndim-dim)*Margin+(1+ndim-dim)*2*Field_Height Fig_Width*2/3-Margin Field_Height], ...
            'string',List{dim}, ...
            'value',initIndex, ...
            'enable','on', ...
            'parent',fig, ...
            'callback',['set(gcbf,''userdata'',[',num2str(dim),' 1])']);
  rad(dim)=uicontrol('style','radiobutton', ...
            'position',[Margin (2+ndim-dim)*Margin+((1+ndim-dim)*2-1)*Field_Height Fig_Width/3-Margin Field_Height-4], ...
            'string','All', ...
            'horizontalalignment','left', ...
            'enable','on', ...
            'value',0, ...
            'parent',fig, ...
            'callback',['set(gcbf,''userdata'',[',num2str(dim),' 2])']);
  sld(dim)=uicontrol('style','slider', ...
            'position',[Fig_Width/3 (2+ndim-dim)*Margin+((1+ndim-dim)*2-1)*Field_Height Fig_Width*2/3-Margin Field_Height], ...
            'min',1, ...
            'max',max(length(List{dim}),2), ...
            'value',initIndex, ...
            'enable','on', ...
            'sliderstep',min([1 10]/length(List{dim}),[0.5 1]), ...
            'parent',fig, ...
            'callback',['set(gcbf,''userdata'',[',num2str(dim),' 3])']);
  if strcmp(Default{dim},':'),
    set(rad(dim),'value',1);
    set([pum(dim) sld(dim)],'enable','off');
    set(txt(dim),'string',['All ',Str{dim}]);
  end;
end;
if strcmp(AllEnable,'NoAll'),
  set(rad,'enable','off');
end;
con=uicontrol('style','pushbutton', ...
          'position',[Margin Margin Fig_Width-2*Margin Field_Height], ...
          'string','continue', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',[0 0])');
gelm_font([txt rad pum sld con]);


done=0;
while ~done,
  waitfor(fig,'userdata');
  cmd=get(fig,'userdata');
  set(fig,'userdata',[]);
  switch cmd(2),
  case 0, %continue
    isel={};
    for dim=ndim:-1:1,
      isel{dim}=logicalswitch(get(rad(dim),'value'),':',get(pum(dim),'value'));
    end;
    done=1;
  case 1, %popupmenu changed
    dim=cmd(1);
    isel=get(pum(dim),'value');
    set(sld(dim),'value',isel);
    set(txt(dim),'string',[Str(dim,:),'=',gui_str(List{dim}(isel))]);
  case 2,  %radiobutton pressed
    dim=cmd(1);
    if strcmp(AllEnable,'OneAll'),
      if get(rad(dim),'value'),
        set(sld(dim),'enable','off');
        set(pum(dim),'enable','off');
        Other=setdiff(1:ndim,dim);
        for odim=Other,
          set(sld(odim),'enable',logicalswitch(length(List{odim})>1,'on','off'));
          isel=get(pum(odim),'value');
          set(txt(odim),'string',[Str{odim},'=',gui_str(List{odim}(isel))]);
        end;
        set(pum(Other),'enable','on');
        set(rad(Other),'value',0);
      else, % Turn All back on
        set(rad(dim),'value',1);
      end;
      set(txt(dim),'string',['All ',Str{dim}]);
    else,
      if get(rad(dim),'value')==1, % All turned on
        set([sld(dim) pum(dim)],'enable','off');
        set(txt(dim),'string',['All ',Str{dim}]);
      else, % All turned off
        set([sld(dim) pum(dim)],'enable','on');
        isel=get(pum(dim),'value');
        set(txt(dim),'string',[Str{dim},'=',gui_str(List{dim}(isel))]);
      end;
    end;
  case 3, %slider moved
    dim=cmd(1);
    isel=round(get(sld(dim),'value'));
    set(pum(dim),'value',isel);
    set(sld(dim),'value',isel);
    set(txt(dim),'string',[Str{dim},'=',gui_str(List{dim}(isel))]);
  end;
end;
delete(fig);
Indices=isel;
for dim=ndim:-1:1,
  if ischar(Indices{dim}),
    Values{dim}=List{dim};
  else,
    Values{dim}=List{dim}(Indices{dim});
  end;
end;
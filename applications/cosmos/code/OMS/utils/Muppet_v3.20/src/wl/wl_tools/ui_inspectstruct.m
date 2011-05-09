function ui_inspectstruct(Struct,Title),
% UI_INSPECTSTRUCT inspect a structure
%
%           UI_INSPECTSTRUCT(Structure,Title)
%           

% (c) 1999-2001 H.R.A. Jagers
%               University of Twente / WL | Delft Hydraulics
%               bert.jagers@wldelft.nl

% V1.00.00 (22/ 4/1999): created
% V1.01.00 (14/ 6/2001): rewritten
% V1.01.01 (16/ 7/2001): small error with cell string corrected


% Specify the selectiontypes on which the edit boxes react.
SelectionTypes={'open','normal'};
Inactive=[.8 .8 .8];
Active=[1 1 1];
Subs_Width=50;  % Width of the left pane
Field_Width=50; % Width of the right pane
List_Height=20; % Number of lines in the list boxes

% valid input argument?
if nargin==0,
  error('One argument expected.');
else,
  if ~ischar(Struct) & ~isstruct(Struct),
    error('Structure expected as argument.');
  end;
  StructName='';
  if ~isstandalone
    StructName=inputname(1);
  end
  if isempty(StructName), % function result
    StructName='[root]';
  end;
end;

fig=gcbf;
if ~ischar(Struct)
  Button_Width=floor((Subs_Width-8)/2);
  XX.Margin=1;
  XX.Txt.Height=1.4;
  XX.But.Height=1.5;
  
  Fig_Width=3*XX.Margin+Subs_Width+Field_Width;
  Fig_Height=3*XX.Margin+XX.But.Height+List_Height;
  
  Units=get(0,'units');
  set(0,'units','characters');
  ss = get(0,'ScreenSize');
  set(0,'units',Units);
  swidth = ss(3);
  sheight = ss(4);
  left = (swidth-Fig_Width)/2;
  bottom = (sheight-Fig_Height)/2;
  rect = [left bottom Fig_Width Fig_Height];
  
  if nargin<2
    Title='Structure tree';
  end
  fig=figure('visible','off', ...
             'menu','none', ...
             'resize','off', ...
             'integerhandle','off', ...
             'numbertitle','off', ...
             'handlevisibility','off', ...
             'color',Inactive, ...
             'units','characters','position',rect,'name',Title);
  
  rect = [XX.Margin XX.Margin Subs_Width-2*Button_Width-2*XX.Margin XX.Txt.Height];
  H.ITxt=uicontrol('style','text', ...
            'units','character', ...
            'position',rect, ...
            'string','index', ...
            'horizontalalignment','left', ...
            'backgroundcolor',Inactive, ...
            'parent',fig);
  
  rect(1) = rect(1)+rect(3)+XX.Margin;
  rect(3) = Button_Width;
  rect(4) = XX.But.Height;
  H.Index=uicontrol('style','edit', ...
            'units','character', ...
            'position',rect, ...
            'string','1', ...
            'backgroundcolor',[1 1 1], ...
            'horizontalalignment','right', ...
            'parent',fig, ...
            'callback','ui_inspectstruct index');
  
  rect(1) = rect(1)+rect(3)+XX.Margin;
  rect(3) = Button_Width;
  rect(4) = XX.But.Height;
  H.ISld=uicontrol('style','slider', ...
            'units','character', ...
            'position',rect, ...
            'min',1, ...
            'value',1, ...
            'max',2, ...
            'userdata',[1 2], ...
            'parent',fig, ...
            'callback','ui_inspectstruct slider');
  
  rect(1) = rect(1)+rect(3)+XX.Margin;
  rect(3) = Field_Width;
  H.Done=uicontrol('style','pushbutton', ...
            'units','character', ...
            'position',rect, ...
            'string','done', ...
            'parent',fig, ...
            'callback','ui_inspectstruct done');
  
  rect(1) = XX.Margin;
  rect(2) = rect(2)+rect(4)+XX.Margin;
  rect(3) = Subs_Width;
  rect(4) = List_Height;
  H.Subs=uicontrol('style','listbox', ...
            'units','character', ...
            'position',rect, ...
            'string','', ...
            'backgroundcolor',[1 1 1], ...
            'horizontalalignment','left', ...
            'parent',fig, ...
            'fontname','Courier', ...
            'callback','ui_inspectstruct up');
  
  rect(1) = rect(1)+rect(3)+XX.Margin;
  rect(3) = Field_Width;
  H.Fields=uicontrol('style','listbox', ...
            'units','character', ...
            'position',rect, ...
            'string','', ...
            'backgroundcolor',[1 1 1], ...
            'horizontalalignment','left', ...
            'parent',fig, ...
            'enable','on', ...
            'fontname','Courier', ...
            'callback','ui_inspectstruct down');

  UD.Struct=Struct;
  UD.StructName=StructName;
  UD.Index=[];
  UD.H=H;
  set(fig,'visible','on','userdata',UD);
  if isempty(Struct)
    LocalTree(Struct,StructName,UD.Index,0,0,H,fig)
  else
    LocalTree(Struct,StructName,UD.Index,1,1,H,fig)
  end
  return
end

UD=get(fig,'userdata');
H=UD.H;
Tmp=get(H.ISld,'userdata');
IndexVal=Tmp(1);
IndexMax=Tmp(2);
Index=UD.Index;

switch Struct,
case 'done',
  if ishandle(fig),
    delete(fig);
    return
  end;
case 'index',
  i=str2num(get(H.Index,'string'));
  if ~isnumeric(i) | ~isequal(size(i),[1 1]) | i~=round(i) | isnan(i) | ~isfinite(i),
    % IndexVal=IndexVal;
  elseif i<1,
    IndexVal=1;
  elseif i>IndexMax,
    IndexVal=IndexMax;
  else,
    IndexVal=i;
  end;
  set(H.Index,'string',num2str(IndexVal));
  set(H.ISld,'value',IndexVal,'userdata',[IndexVal IndexMax]);
  i=get(H.Subs,'value');
  LocalTree(UD.Struct,UD.StructName,Index,IndexVal,i-(length(Index))/2-1,H,fig)
case 'slider', % index slider
  dI=get(H.ISld,'value')-IndexVal;
  IndexVal=IndexVal+sign(dI)*ceil(abs(dI));
  set(H.Index,'string',num2str(IndexVal));
  set(H.ISld,'value',IndexVal,'userdata',[IndexVal IndexMax]);
  i=get(H.Subs,'value');
  LocalTree(UD.Struct,UD.StructName,Index,IndexVal,i-(length(Index))/2-1,H,fig)
case 'up',
  switch get(fig,'selectiontype'),
  case 'normal',
    i=get(H.Subs,'value');
    LocalTree(UD.Struct,UD.StructName,Index,IndexVal,i-(length(Index))/2-1,H,fig)
  case 'open',
    i=get(H.Subs,'value');
    if (2*i-1)<length(Index),
      IndexVal=Index(2*i-1).subs{1};
      Index((2*i-1):end)=[];
      LocalTree(UD.Struct,UD.StructName,Index,IndexVal,1,H,fig)
    elseif (2*i-2)==length(Index)
      LocalTree(UD.Struct,UD.StructName,Index,IndexVal,i-(length(Index))/2-1,H,fig)
    elseif (2*i-1)>length(Index),
      Str2=get(H.Subs,'string');
      Index(end+1).type='()';
      Index(end).subs={IndexVal};
      Index(end+1).type='.';
      Index(end).subs=strtok(Str2{i});
      SubStruct=subsref(UD.Struct,Index);
      if isstruct(SubStruct) & ~isempty(SubStruct)
        IndexVal=1;
        LocalTree(UD.Struct,UD.StructName,Index,IndexVal,1,H,fig)
      else
        Index(end-1:end)=[];
        LocalTree(UD.Struct,UD.StructName,Index,IndexVal,i-(length(Index))/2-1,H,fig)
      end
    end;
  end;
end;
UD.Index=Index;
set(fig,'userdata',UD);


function LocalTree(Struct,StructName,Index,IndexVal,Fld,H,fig),
Inactive=[.8 .8 .8];
Active=[1 1 1];
Str2='';
ValIsData=0;
if IndexVal==0, % can only occur if the function is called with an empty structure
  Str1={['  ' StructName]};
  StartFields=0;
  Fld=1;
  SubStruct=Struct;
  Val=1;
else
  if isempty(Index),
    Str1={['+ ' StructName '(' num2str(IndexVal) ') >']};
    SubStruct=Struct;
    i=0;
  else,
    Str1={['- ' StructName '(' num2str(Index(1).subs{1}) ')']};
    for i=2:2:length(Index)-1,
      Str1{end+1}=[repmat(' ',1,i) '- ' Index(i).subs '(' num2str(Index(i+1).subs{1}) ')'];
    end;
    i=length(Index);
    Str1{end+1}=[repmat(' ',1,i) '+ ' Index(i).subs '(' num2str(IndexVal) ') >'];
    SubStruct=subsref(Struct,Index);
  end
  StartFields=length(Str1);
  Str2=fieldnames(SubStruct);
  for j=1:length(Str2)
    Str1{end+1}=[repmat(' ',1,i+4) Str2{j}];
  end
  Val=prod(size(SubStruct));
end;
if Fld<=0
  Str2='';
else
  if IndexVal>0
    SubStruct=getfield(SubStruct,{IndexVal},Str2{Fld});
    ValIsData=1;
  end
  switch class(SubStruct),
  case 'struct',
    Str2=cat(1,{[LocalSize(SubStruct) ' struct array with fields:']},fieldnames(SubStruct));
  case 'char',
    if ndims(SubStruct)<=2,
      Str2=SubStruct;
    else,
      Str2=[LocalSize(SubStruct) ' char array'];
    end;
  case 'double',
    if ndims(SubStruct)<=2 & ~isempty(SubStruct),
      Str2=num2str(SubStruct);
    else,
      Str2=[LocalSize(SubStruct) ' double array'];
    end;
  case 'cell',
    Str2=[LocalSize(SubStruct) ' cell array'];
    if iscellstr(SubStruct) & sum(size(SubStruct)>1)<2 & ~isempty(SubStruct),
      Str2={[Str2 ' containing']};
      Str2{2}=sprintf('''\n''%s',SubStruct{:});
      Str2{2}=Str2{2}([3:end 1:2]);
    end;
  otherwise,
    Str2=[LocalSize(SubStruct) ' ' class(SubStruct) ' array'];
  end;
end
set(H.Subs,'string',Str1,'value',StartFields+Fld);
if IndexVal==0
  set(H.Subs,'callback','');
end
if isempty(Str2) & ~ValIsData,
  set(H.Fields,'string','','max',2,'value',[],'style','edit','callback','','enable','off','backgroundcolor',Inactive);
  set(H.Index,'string','','enable','off','backgroundcolor',Inactive);
  set(H.ITxt,'enable','off');
  set(H.ISld,'enable','off');
else,
  set(H.Fields,'string',Str2,'max',2,'enable','on','style','edit','backgroundcolor',Active);
  set(H.ITxt,'enable','on');
  %
  indact='on';
  indclr=Active;
  if Val==1 | IndexVal==0, indact='off'; indclr=Inactive; end
  Tmp=get(H.ISld,'userdata');
  if isempty(IndexVal)
    IndexVal=Tmp(1);
  end
  set(H.ITxt,'enable',indact);
  set(H.Index,'string',num2str(IndexVal),'enable',indact,'backgroundcolor',indclr);
  set(H.ISld,'enable',indact,'value',max(1,IndexVal),'max',max(2,Val),'sliderstep',[min(0.1,1/max(1,Val)) min(1,10/max(1,Val))], ...
  'userdata',[IndexVal Val]);
end;


function Str=LocalSize(SubStruct),
Sz=size(SubStruct);
Str=[sprintf('%i',Sz(1)) sprintf('x%i',Sz(2:end))];
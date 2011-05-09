function objectname=listnames(handle);
% LISTNAMES name graphics objects
%
%    Names=LISTNAMES(Handles)
%    returns a cell array containing the names
%    of graphics objects

% (c) Copyright 2000
%     H.R.A. Jagers, WL | Delft Hydraulics, The Netherlands

handle=handle(:);
if isempty(handle),
  objectname={};
  return;
elseif any(~isnumeric(handle)) | any(~ishandle(handle)),
  objectname={};
  warning('Invalid handle passed to function LISTNAMES.');
  return;
end;
if ~isempty(handle),
  for i=1:length(handle),
    TagStr=get(handle(i),'tag');
    if ~isempty(TagStr),
      TagStr=[': ' TagStr];
    end;
    TypeStr=get(handle(i),'type');
    HandleStr=[' ' num2str(handle(i))];
    switch TypeStr,
    case 'figure',
      StringStr=get(handle(i),'name');
      if strcmp(get(handle(i),'numbertitle'),'on'),
        if isempty(StringStr),
          StringStr=[TypeStr ' No.' HandleStr];
        else,
          StringStr=[TypeStr ' No.' HandleStr ':' StringStr];
        end;
        StringStr(1)=upper(StringStr(1));
      end;
    case 'axes',
      StringStr=get(get(handle(i),'title'),'string');
    case 'uicontrol',
      StringStr=get(handle(i),'string');
      if iscell(StringStr),
        StringStr=StringStr{1};
      end;
    case 'uimenu',
      StringStr=get(handle(i),'label');
    case 'text',
      parenthandle=get(handle(i),'parent');
      specobj=[get(parenthandle,'xlabel') get(parenthandle,'ylabel') get(parenthandle,'zlabel') get(parenthandle,'title')];
      specobjtype={'xlabel','ylabel','zlabel','title'};
      if ismember(handle(i),specobj), % label or title
        TypeStr=specobjtype{min(find(specobj==handle(i)))};
      end;
      StringStr=get(handle(i),'string');
    otherwise,
      StringStr='';
    end;
    if iscell(StringStr),
      if isempty(StringStr),
        StringStr='';
      else,
        StringStr=StringStr{1};
      end;
    end;
    if ~isempty(StringStr), StringStr=[StringStr(1,:) ' ']; end;
    if strcmp(get(handle(i),'handlevisibility'),'off'),
      TypeStr=['*' TypeStr];
    end;
    objectname{i}=[StringStr '[' TypeStr HandleStr TagStr ']'];
  end;
else,
  objectname={};
end;

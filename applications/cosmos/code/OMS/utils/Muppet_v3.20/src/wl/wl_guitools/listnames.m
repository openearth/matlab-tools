function objectname=listnames(handle);
% LISTNAMES returns a cell array containing the objectname of graphics objects
%    Names=LISTNAMES(Handles)
%
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
    if strcmp(get(handle(i),'handlevisibility'),'off'),
      VisStr='*';
    else,
      VisStr='';
    end;
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
    if ~isempty(StringStr),
      if iscell(StringStr),
        StringStr=[StringStr{1}(1,:) ' '];
      else,
        StringStr=[StringStr(1,:) ' '];
      end;
    end;
    objectname{i}=[StringStr '[' VisStr TypeStr HandleStr TagStr ']'];
  end;
else,
  objectname={};
end;

function Out=lighten(Hmain,amount),
% LIGHTEN lightens all colours in a figure.
%         LIGHTEN(HFIG,amount) lightens all colors in the indicated
%         figure by the specified amount.

% (c) Copyright 1998 H.R.A. Jagers
%     University of Twente, The Netherlands

if nargin==0,
  Hmain=gcf;
  amount=0.9;
elseif nargin==1,
  amount=1-Hmain;
  Hmain=gcf;
else,
  amount=1-amount;
end;

if (ndims(Hmain)==3) & (size(Hmain,3)==3),
  Out=1-amount*(1-Hmain);
  return;
elseif (ndims(Hmain)==2) & (size(Hmain,2)==3),
  Out=1-amount*(1-Hmain);
  return;
elseif ~ishandle(Hmain),
  fprintf(1,'First argument is not a valid object handle.\n');
  return;
end;

Handles=findobj(Hmain);
for i=1:length(Handles),
  Type=get(Handles(i),'type');
  switch Type
  case 'figure',
    set(Handles(i),'color',1-amount*(1-get(Handles(i),'color')));
    set(Handles(i),'colormap',1-amount*(1-get(Handles(i),'colormap')));
  case 'axes',
    set(Handles(i),'xcolor',1-amount*(1-get(Handles(i),'xcolor')));
    set(Handles(i),'ycolor',1-amount*(1-get(Handles(i),'ycolor')));
    set(Handles(i),'zcolor',1-amount*(1-get(Handles(i),'zcolor')));
    if size(get(Handles(i),'color'))==[1 3],
      set(Handles(i),'color',1-amount*(1-get(Handles(i),'color')));
    end;
  case {'line','text'},
    set(Handles(i),'color',1-amount*(1-get(Handles(i),'color')));
  case 'patch',
    if size(get(Handles(i),'edgecolor'))==[1 3],
      set(Handles(i),'edgecolor',1-amount*(1-get(Handles(i),'edgecolor')));
    end;
    if size(get(Handles(i),'facecolor'))==[1 3],
      set(Handles(i),'facecolor',1-amount*(1-get(Handles(i),'facecolor')));
    end;
    if ndims(get(Handles(i),'facevertexcdata'))==3, % true color
      set(Handles(i),'facevertexcdata',1-amount*(1-get(Handles(i),'facevertexcdata')));
    end;
  case 'surface',
    if size(get(Handles(i),'edgecolor'))==[1 3],
      set(Handles(i),'edgecolor',1-amount*(1-get(Handles(i),'edgecolor')));
    end;
    if size(get(Handles(i),'facecolor'))==[1 3],
      set(Handles(i),'facecolor',1-amount*(1-get(Handles(i),'facecolor')));
    end;
    if ndims(get(Handles(i),'cdata'))==3, % true color
      set(Handles(i),'cdata',1-amount*(1-get(Handles(i),'cdata')));
    end;
  case 'image',
    if ndims(get(Handles(i),'cdata'))==3, % true color
      set(Handles(i),'cdata',1-amount*(1-get(Handles(i),'cdata')));
    end;
  case 'rectangle',
    if size(get(Handles(i),'edgecolor'))==[1 3],
      set(Handles(i),'edgecolor',1-amount*(1-get(Handles(i),'edgecolor')));
    end;
    if size(get(Handles(i),'facecolor'))==[1 3],
      set(Handles(i),'facecolor',1-amount*(1-get(Handles(i),'facecolor')));
    end;
  end;
end;
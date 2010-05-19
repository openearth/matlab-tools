function SetUIBackgroundColors(varargin)

if ~isempty(varargin)
    fig=varargin{1};
else
    fig=gcf;
end

bgc=get(fig,'Color');

% h=findobj(fig,'Tag','UIControl','type','uipanel');
% set(h,'BackgroundColor',bgc);
% h=findobj(fig,'Tag','UIControl','Style','text');
% set(h,'BackgroundColor',bgc);
% h=findobj(fig,'Tag','UIControl','Style','radiobutton');
% set(h,'BackgroundColor',bgc);
% h=findobj(fig,'Tag','UIControl','Style','checkbox');
% set(h,'BackgroundColor',bgc);

h=findobj(fig,'type','uipanel');
set(h,'BackgroundColor',bgc);
h=findobj(fig,'type','UIControl','Style','text','Tag','UIControl');
set(h,'BackgroundColor',bgc);
h=findobj(fig,'type','UIControl','Style','radiobutton','Tag','UIControl');
set(h,'BackgroundColor',bgc);
h=findobj(fig,'type','UIControl','Style','checkbox','Tag','UIControl');
set(h,'BackgroundColor',bgc);
h=findobj(fig,'type','UIControl','Style','pushbutton','Tag','UIControl');
set(h,'BackgroundColor',bgc);

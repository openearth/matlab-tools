function buttons(sw)
%BUTTONS Toggle visibility of uicontrols
%    BUTTONS ON   : Show uicontrols
%    BUTTONS OFF  : Hide uicontrols
%    BUTTONS      : Toggle visibility

Fig=gcf;
uic=findall(Fig,'type','uicontrol');
if nargin==0, sw=''; end
sw=lower(sw);
if isequal(sw,'off') | (isempty(sw) & ~isempty(strmatch('on',get(uic(1),'vis'))))
  set(uic,'visible','off')
elseif isequal(sw,'on') | isempty(sw)
  set(uic,'visible','on')
else
  error(['Unknown switch option: ',sw])
end
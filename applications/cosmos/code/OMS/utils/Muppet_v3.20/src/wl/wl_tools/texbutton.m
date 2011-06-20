function hout = texbutton(varargin)
%TEXBUTTON Create button with more flexible labeling than uicontrol.
% usage: texbutton(<same as uicontrol>) except 'String' property
%        can be a cell array of strings, one cell per line, and can
%        contain TeX formatting commands.  Also accepts the
%        'Interpreter' property to control TeX interpretation.
% arguments: <same as uicontrol> + 'Interpreter' = {'tex' | 'none'} 

% original name UIBUTTON
% subordinate functions: <none>
%
% author: Doug Schwarz
% email: douglas.schwarz@kodak.com
% date: 25 August 1999
 
 
% Look for 'Interpreter' property, set it properly for the text function % and then remove it from varargin.
properties = varargin(1:2:end);
for i = 1:length(properties)
    properties{i} = lower(properties{i});
end
interp_property = 2*strmatch('interp',properties) - 1;
if ~isempty(interp_property)
    interp_value = varargin{interp_property + 1};
    varargin(interp_property + [0 1]) = [];
else
    interp_value = get(0,'DefaultTextInterpreter');
end
 
% Create button then hide it.
h = uicontrol(varargin{:});
s = get(h);
set(h,'Visible','off')
 
% Create axes and text label, capture the appearance in a matrix, then
% delete axes.
ax = axes('Units',s.Units,...
        'Position',s.Position,...
        'XTick',[],'YTick',[],...
        'Color',s.BackgroundColor);
text('Position',[0.5,0.5],...
        'String',s.String,...
        'Interpreter',interp_value,...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'FontName',s.FontName,...
        'FontSize',s.FontSize,...
        'FontAngle',s.FontAngle,...
        'FontWeight',s.FontWeight,...
        'Color',s.ForegroundColor)
set(ax,'Units','pixels')
pos = round(get(ax,'Position') + [2 2 -4 -4]);
[g,map] = getframe(gcf,pos);
delete(ax)
 
% Build RGB image and put it in 'CData' for the button.
c = reshape(map(g,:),[pos([4,3]),3]);
set(h,'CData',c,'Visible',s.Visible)
 
% Assign output argument if necessary.
if nargout
    hout = h;
end
function [l,h]=ProcessButton(ProcessInfo,varargin),
% PROCESSBUTTON
%   Handles=PROCESSBUTTON(ProcessInfo,'option1',value1,...)
%   [Width,Height]=PROCESSBUTTON(ProcessInfo)

GridCell=20;
dx=GridCell*max([ceil(7*length(ProcessInfo.Name)/GridCell), ...
     length(ProcessInfo.Stream.InputType), ...
     length(ProcessInfo.Stream.OutputType)]);
dy=GridCell;

if nargout==2,
  l=dx;
  h=dy;
  return;
end;

x=ProcessInfo.PlotLocation(1)+2;
y=ProcessInfo.PlotLocation(2)+1;
HShift=-1;
VShift=-1;
DarkGray=[1 1 1]*128/255;
White=[1 1 1];
Black=[0 0 0];
LightGray=[1 1 1]*223/255;
MidGray=[1 1 1]*192/255;
l=patch(HShift+[x+dx-1 x x x+dx-1],VShift+[y+dy-1 y+dy-1 y y],-[1 1 1 1],1,'facecolor',MidGray,'edgecolor','none',varargin{:});
line(HShift+[x+dx-1 x x],VShift+[y+dy-1 y+dy-1 y],-0.5*[1 1 1],'color',White,varargin{:});
line(HShift+[x+dx-2 x+1 x+1],VShift+[y+dy-2 y+dy-2 y+1],-0.5*[1 1 1],'color',LightGray,varargin{:});
line(HShift+[x+1 x+dx-2 x+dx-2],VShift+[y+1 y+1 y+dy-2],-0.5*[1 1 1],'color',DarkGray,varargin{:});
line(HShift+[x x+dx-1 x+dx-1],VShift+[y y y+dy-1],-0.5*[1 1 1],'color',Black,varargin{:});
text( ...
     'position',[x+dx/2-1 y+dy/2-1], ...
     'string',ProcessInfo.Name, ...
     'color',Black, ...
     'fontname','Helvetica', ...
     'fontunits','pixels', ...
     'fontsize',12, ...
     'horizontalalignment','center', ...
     'verticalalignment','middle', ...
     varargin{:});
for i=1:length(ProcessInfo.Stream.InputType),
  line(HShift+x+[i-0.75 i-0.25]*GridCell,VShift+(y+dy)*[1 1],-0.25*[1 1],'color','r','linewidth',2,varargin{:});
end;
for i=1:length(ProcessInfo.Stream.OutputType),
  line(HShift+x+[i-0.75 i-0.25]*GridCell,VShift+y*[1 1],-0.25*[1 1],'color','r','linewidth',2,varargin{:});
end;

function l=HorzLine3D(x,y,dx,varargin),
DarkGray=[.502 .502 .502];
White=[1 1 1];
l(1)=line([x x+dx],[y y],[0 0],'color',DarkGray,varargin{:});
l(2)=line([x x+dx],[y-1 y-1],[0 0],'color',White,varargin{:});

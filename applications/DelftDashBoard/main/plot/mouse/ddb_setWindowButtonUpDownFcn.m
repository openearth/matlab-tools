function ddb_setWindowButtonUpDownFcn(varargin)

dwncallback=[];
upcallback=[];

if ~isempty(varargin)
    dwncallback=varargin{1};
    upcallback=varargin{2};
end

set(gcf,'WindowButtonDownFcn',dwncallback);
set(gcf,'WindowButtonUpFcn',upcallback);

function ddb_setWindowButtonFcn(varargin)

dwncallback=[];
upcallback=[];
motioncallback=[];

if ~isempty(varargin)
    dwncallback=varargin{1};
    upcallback=varargin{2};
    motioncallback=varargin{3};
end

set(gcf,'WindowButtonDownFcn',dwncallback);
set(gcf,'WindowButtonUpFcn',upcallback);

if isempty(motioncallback)
    set(gcf,'WindowButtonMotionFcn',@ddb_moveMouseDefault);
end

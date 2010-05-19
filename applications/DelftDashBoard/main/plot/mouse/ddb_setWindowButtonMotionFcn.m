function ddb_setWindowButtonMotionFcn(varargin)

motioncallback=@ddb_moveMouseDefault;
ptr='arrow';

if ~isempty(varargin)
    if length(varargin)==1
        ptr=varargin{1};
    else
        motioncallback=varargin{1};
        ptr=varargin{2};
    end
end

set(gcf,'WindowButtonMotionFcn',{motioncallback,ptr});

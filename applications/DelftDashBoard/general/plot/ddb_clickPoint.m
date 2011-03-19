function ddb_clickPoint(opt,varargin)
% Click point on map. Opt can be xy, gridcell or corner point

xg=[];
yg=[];
callback=[];
multi=0;

if ~isempty(varargin)
    for i=1:length(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case{'grid'}
                    xg=varargin{i+1};
                    yg=varargin{i+2};
                case{'callback'}
                    callback=varargin{i+1};
                case{'multiple'}
                    multi=1;
                case{'single'}
                    multi=0;
            end
        end
    end
end

ddb_setWindowButtonMotionFcn;
set(gcf,'windowbuttondownfcn',{@click,opt,xg,yg,callback,multi});
set(gcf,'windowbuttonupfcn',[]);

%%
function click(src,eventdata,opt,xg,yg,callback,multi)

mouseclick=get(gcf,'SelectionType');

x=NaN;
y=NaN;

if strcmpi(mouseclick,'normal')
    pos = get(gca, 'CurrentPoint');
    x0=pos(1,1);
    y0=pos(1,2);
    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');
    if x0<=xlim(1) || x0>=xlim(2) || y0<=ylim(1) || y0>=ylim(2)
        x0=NaN;
        y0=NaN;
    end
    if ~isnan(x0)
        switch lower(opt)
            case{'xy'}
                x=x0;
                y=y0;
            case{'cell'}
                [x,y]=FindGridCell(x0,y0,xg,yg);
                if x==0 || y==0
                    x=NaN;
                    y=NaN;
                end
            case{'cornerpoint'}
                [x,y]=FindCornerPoint(x0,y0,xg,yg);
                if x==0 || y==0
                    x=NaN;
                    y=NaN;
                end
        end
        if ~multi
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
        feval(callback,x,y);
    end
else
    ddb_setWindowButtonUpDownFcn;
    ddb_setWindowButtonMotionFcn;
end



function ddb_dragLine(fcn,varargin)

x=[];
y=[];
method='free';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'method'}
                method=lower(varargin{i+1});
            case{'x'}
                x=varargin{i+1};
            case{'y'}
                y=varargin{i+1};
        end
    end
end

set(gcf, 'windowbuttondownfcn',{@dragLine,fcn,method,x,y});
set(gcf, 'windowbuttonmotionfcn',[]);

%%
function dragLine(src,eventdata,fcn,method,xg,yg)

set(gcf, 'windowbuttonmotionfcn', {@followTrack});
set(gcf, 'windowbuttonupfcn',     {@stopTrack});

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

if strcmp(method,'alonggridline')
    [m1,n1]=FindCornerPoint(posx,posy,xg,yg);
    posx=xg(m1,n1);
    posy=yg(m1,n1);
end

% usd.opt=opt;

usd.x=[posx posx];
usd.y=[posy posy];
usd.z=[9000 9000];
usd.Line=plot3(usd.x,usd.y,usd.z);

usd.LineColor='g';
usd.LineWidth=2;
usd.LineStyle='-';

set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findobj(gcf,'Tag','DraggedLine');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
    fcn(x,y);
end

%%
function followTrack(imagefig, varargins) 
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x(2)=posx;
usd.y(2)=posy;
usd.z(2)=9000;
set(usd.Line,'XData',usd.x);
set(usd.Line,'YData',usd.y);
set(usd.Line,'ZData',usd.z);
set(0,'UserData',usd);
%ddb_updateCoordinateText('arrow');

%%
function stopTrack(imagefig, varargins)
ddb_setWindowButtonMotionFcn;
set(gcf, 'windowbuttonupfcn',[]);
usd=get(0,'UserData');
set(usd.Line,'UserData',usd);
set(usd.Line,'Tag','DraggedLine');
set(0,'UserData',[]);

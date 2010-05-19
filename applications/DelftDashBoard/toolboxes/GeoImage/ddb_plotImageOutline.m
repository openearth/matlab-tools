function ddb_plotImageOutline(c)

handles=getHandles;

x1=handles.Toolbox(tb).Input.XLim(1);
y1=handles.Toolbox(tb).Input.YLim(1);
x2=handles.Toolbox(tb).Input.XLim(2);
y2=handles.Toolbox(tb).Input.YLim(2);

x(1)=x1;
x(2)=x2;
x(3)=x2;
x(4)=x1;
x(5)=x1;

y(1)=y1;
y(2)=y1;
y(3)=y2;
y(4)=y2;
y(5)=y1;

z=zeros(size(x))+100;
plt=plot3(x,y,z);
set(plt,'LineWidth',1.5,'Color',c);
set(plt,'Tag','ImageOutline');
hold on;

for i=1:4
    sh(i)=plot3(x(i),y(i),200,'ko');hold on;
    set(sh(i),'Tag','SelectionHighlight','MarkerSize',4);
    set(sh(i),'MarkerEdgeColor','k');
    set(sh(i),'MarkerFaceColor','r');
    usdsh.Parent=plt(1);
    usdsh.nr=i;
    set(sh(i),'UserData',usdsh);
    set(sh(i),'ButtonDownFcn',{@SelectObject});
end
set(sh(1),'MarkerFaceColor','y','MarkerSize',5);


usd.SelectionHighlights=sh;
usd.x=x;
usd.y=y;
set(plt,'userdata',usd);


%%
function SelectObject(imagefig, varargins)

    if strcmp(get(gcf,'SelectionType'),'open')
        %    GiveWarning('txt','Isn''t this fun?!');
    else
        if strcmp(get(gco,'Tag'),'SelectionHighlight')
            ud=get(gco,'userdata');
            usd=get(ud.Parent,'userdata');
            usd.nr=ud.nr;
            if strcmp(get(gcf,'SelectionType'),'normal')
                pos = get(gca, 'CurrentPoint');
                usd.x0=pos(1,1);
                usd.y0=pos(1,2);
                set(gcf, 'windowbuttonmotionfcn', {@MoveCornerPoint});
            else
                if usd.nr==1
                    set(gcf, 'windowbuttonmotionfcn', {@MoveGrid});
                end
            end
        end
        set(0,'userdata',usd);
        set(gcf, 'windowbuttonupfcn', {@StopTrack});
    end
%end

%%
function MoveCornerPoint(imagefig, varargins)

usd=get(0,'userdata');

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

handles=getHandles;

switch usd.nr,
    case 1

            x0=[posx posy];

            x1=[usd.x(3) usd.y(3)];
            x2=[usd.x(2) usd.y(2)];
            pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
            distx=det([x2-x1 ; x1-x0])/pt;

            x1=[usd.x(4) usd.y(4)];
            x2=[usd.x(3) usd.y(3)];
            pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
            disty=det([x2-x1 ; x1-x0])/pt;

            if distx>0 && disty>0
                handles.Toolbox(tb).Input.XLim(1)=posx;
                handles.Toolbox(tb).Input.YLim(1)=posy;
                set(handles.GUIHandles.EditX1,'String',num2str(handles.Toolbox(tb).Input.XLim(1)));
                set(handles.GUIHandles.EditY1,'String',num2str(handles.Toolbox(tb).Input.YLim(1)));
                set(handles.GUIHandles.EditX2,'String',num2str(handles.Toolbox(tb).Input.XLim(2)));
                set(handles.GUIHandles.EditY2,'String',num2str(handles.Toolbox(tb).Input.YLim(2)));
            end
            
     case 2
         
         x0=[posx posy];

         x1=[usd.x(1) usd.y(1)];
         x2=[usd.x(4) usd.y(4)];
         pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
         distx=det([x2-x1 ; x1-x0])/pt;

         x1=[usd.x(4) usd.y(4)];
         x2=[usd.x(3) usd.y(3)];
         pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
         disty=det([x2-x1 ; x1-x0])/pt;

         if distx>0 && disty>0
             handles.Toolbox(tb).Input.XLim(2)=posx;
             handles.Toolbox(tb).Input.YLim(1)=posy;
             set(handles.GUIHandles.EditX1,'String',num2str(handles.Toolbox(tb).Input.XLim(1)));
             set(handles.GUIHandles.EditY1,'String',num2str(handles.Toolbox(tb).Input.YLim(1)));
             set(handles.GUIHandles.EditX2,'String',num2str(handles.Toolbox(tb).Input.XLim(2)));
             set(handles.GUIHandles.EditY2,'String',num2str(handles.Toolbox(tb).Input.YLim(2)));
         end

    case 3
        x0=[posx posy];

        x1=[usd.x(1) usd.y(1)];
        x2=[usd.x(4) usd.y(4)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;

        x1=[usd.x(2) usd.y(2)];
        x2=[usd.x(1) usd.y(1)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;
        
        if distx>0 && disty>0
             handles.Toolbox(tb).Input.XLim(2)=posx;
             handles.Toolbox(tb).Input.YLim(2)=posy;
             set(handles.GUIHandles.EditX1,'String',num2str(handles.Toolbox(tb).Input.XLim(1)));
             set(handles.GUIHandles.EditY1,'String',num2str(handles.Toolbox(tb).Input.YLim(1)));
             set(handles.GUIHandles.EditX2,'String',num2str(handles.Toolbox(tb).Input.XLim(2)));
             set(handles.GUIHandles.EditY2,'String',num2str(handles.Toolbox(tb).Input.YLim(2)));
        end

    case 4
        x0=[posx posy];

        x1=[usd.x(3) usd.y(3)];
        x2=[usd.x(2) usd.y(2)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;

        x1=[usd.x(2) usd.y(2)];
        x2=[usd.x(1) usd.y(1)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;

        if distx>0 && disty>0
             handles.Toolbox(tb).Input.XLim(1)=posx;
             handles.Toolbox(tb).Input.YLim(2)=posy;
             set(handles.GUIHandles.EditX1,'String',num2str(handles.Toolbox(tb).Input.XLim(1)));
             set(handles.GUIHandles.EditY1,'String',num2str(handles.Toolbox(tb).Input.YLim(1)));
             set(handles.GUIHandles.EditX2,'String',num2str(handles.Toolbox(tb).Input.XLim(2)));
             set(handles.GUIHandles.EditY2,'String',num2str(handles.Toolbox(tb).Input.YLim(2)));
        end
end
ddb_refreshZoomLevels(handles);
setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');

%%
function MoveGrid(imagefig, varargins)

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

handles=getHandles;

handles.Toolbox(tb).Input.XLim(1)=posx;
handles.Toolbox(tb).Input.YLim(1)=posy;
set(handles.GUIHandles.EditX1,'String',num2str(posx));
set(handles.GUIHandles.EditY1,'String',num2str(posy));

setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');

%%
function StopTrack(imagefig, varargins)

set(gcf, 'windowbuttonmotionfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'Pointer','arrow');
set(gcf, 'Units', 'pixels');
set(0,'userdata',[]);

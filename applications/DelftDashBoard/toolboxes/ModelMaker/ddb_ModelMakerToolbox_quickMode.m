function ddb_ModelMakerToolbox_quickMode(varargin)

handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setUIElements('modelmakerpanel.quickmode');
    setHandles(handles);
%    ddb_plotDredgePlume(handles,'activate');
else
    
    %Options selected

    opt=lower(varargin{1});
    
    switch opt
        case{'drawgridoutline'}
            drawGridOutline;
        case{'addtrack'}
        case{'deletetrack'}
    end
    
end

%%
function drawGridOutline
handles=getHandles;
f1=@ddb_deleteGridOutline;
f2=@UpdateGridOutline;
f3=@UpdateGridOutline;
DrawRectangle('GridOutline',f1,f2,f3,'dx',handles.Toolbox(tb).Input.dX,'dy',handles.Toolbox(tb).Input.dY,'Color','g','Marker','o','MarkerColor','r','LineWidth',1.5,'Rotation','off');

%%
function UpdateGridOutline(x0,y0,lenx,leny,rotation)

handles=getHandles;

handles.Toolbox(tb).Input.XOri=x0;
handles.Toolbox(tb).Input.YOri=y0;
handles.Toolbox(tb).Input.Rotation=rotation;
handles.Toolbox(tb).Input.nX=round(lenx/handles.Toolbox(tb).Input.dX);
handles.Toolbox(tb).Input.nY=round(leny/handles.Toolbox(tb).Input.dY);

setHandles(handles);

setUIElement('modelmakerpanel.editx0');
% set(handles.GUIHandles.EditXOri,'String',num2str(handles.Toolbox(tb).Input.XOri));
% set(handles.GUIHandles.EditYOri,'String',num2str(handles.Toolbox(tb).Input.YOri));
% set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
% set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
% set(handles.GUIHandles.EditRotation,'String',num2str(handles.Toolbox(tb).Input.Rotation));



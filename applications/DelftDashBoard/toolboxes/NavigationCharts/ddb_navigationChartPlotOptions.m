function ddb_navigationChartPlotOptions

h=getHandles;

handles=h.Toolbox(tb);

MakeNewWindow('Plot Options',[800 650],'modal',[h.SettingsDir '\icons\deltares.gif']);

s=handles.Layers;
layers=fieldnames(s);
k=0;
posx=30;
posy=620;

nrows=30;

w=100;
x0=30;
y0=620;

posx=x0;
posy=y0;

for i=1:length(layers)
    layer=layers{i};
    if ~strcmpi(layer(1:4),'doll')
        handles.(layer).Text    =uicontrol(gcf,'Style','text','String',layer,'Position',   [posx posy 60 20]);
        handles.(layer).CheckBox=uicontrol(gcf,'Style','checkbox','String','','Position',   [posx+60 posy+5 60 20],'Tag',layer);
        lyr=layer;
        if ~isempty(handles.Layers.(lyr))
            if handles.Layers.(lyr)(1).Plot
                set(handles.(layer).CheckBox,'Value',1);
            end
        else
            set(handles.(layer).Text,'Enable','off');
            set(handles.(layer).CheckBox,'Enable','off');
        end
        posy=posy-20;
        if i/nrows==floor(i/nrows)
            posx=posx+w;
            posy=y0;
        end
        set(handles.(layer).CheckBox,  'Callback',{@CheckBox_Callback});
    end
end

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK','Position',[700 30 70 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[620 30 70 20]);

set(handles.PushOK,  'Callback',{@PushOK_Callback});
set(handles.PushCancel,  'Callback',{@PushCancel_Callback});

guidata(gcf,handles);

%%
function PushOK_Callback(hObject,eventdata)
h=getHandles;
handles=guidata(gcf);
h.Toolbox(tb).Layers=handles.Layers;
setHandles(h);
close(gcf);

%%
function PushCancel_Callback(hObject,eventdata)
close(gcf);

%%
function CheckBox_Callback(hObject,eventdata)
handles=guidata(gcf);
layer=get(hObject,'Tag');
for i=1:length(handles.(layer))
    handles.(layer)(i).Plot=get(hObject,'Value');
%    bbb=handles.(layer)(i).Plot;
end
guidata(gcf,handles);

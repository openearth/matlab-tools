function EditSwanNesting

ddb_refreshScreen('Grids','Nesting');
handles=getHandles;

handles.TextGridNested       = uicontrol(gcf,'Style','text','String','Computational grid nested in : ','Position',[360 100 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditGridNested       = uicontrol(gcf,'Style','edit', 'Position',[520 100 130 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.textGridname         = uicontrol(gcf,'Style','text', 'String',['Grid filename : ' handles.SwanInput(handles.ActiveDomain).GrdFile],'Position',[360 80 300 15],'HorizontalAlignment','left','Tag','UIControl');
handles.textAssosGrid        = uicontrol(gcf,'Style','text', 'String',['Associated bathymetry grid : ' handles.SwanInput(handles.ActiveDomain).GrdFile],'Position',[360 60 300 15],'HorizontalAlignment','left','Tag','UIControl');
handles.textAssosData        = uicontrol(gcf,'Style','text', 'String',['Associated bathymetry data : ' handles.SwanInput(handles.ActiveDomain).DepFile],'Position',[360 40 300 15],'HorizontalAlignment','left','Tag','UIControl');

handles.textNestedIn         = uicontrol(gcf,'Style','text', 'String',['Nested in : ' handles.SwanInput(handles.ActiveDomain).NstFile],'Position',[670 80 300 15],'HorizontalAlignment','left','Tag','UIControl');
handles.textXYOrigin         = uicontrol(gcf,'Style','text', 'String',['X, Y Origin : ' ],'Position',[670 60 300 15],'HorizontalAlignment','left','Tag','UIControl');
handles.textNbMNpoints       = uicontrol(gcf,'Style','text', 'String',['Number of M, N points : ' ],'Position',[670 40 300 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.EditGridNested,'Max',1);
set(handles.EditGridNested,'String',handles.SwanInput(handles.ActiveDomain).GridNested);
set(handles.EditGridNested,'CallBack',{@EditGridNested_CallBack}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditGridNested_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).GridNested=get(hObject,'String');
setHandles(handles);

function EditSwanComputationalgrid

ddb_refreshScreen('Grids','Computational grid');
handles=getHandles;

handles.TextBathymetryGrid     = uicontrol(gcf,'Style','text','String',['Associated bathymetry grid : ' handles.SwanInput(handles.ActiveDomain).GrdFile],'Position',[360 90 310 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextBathymetryDep      = uicontrol(gcf,'Style','text','String',['Associated bathymetry data : ' handles.SwanInput(handles.ActiveDomain).DepFile],'Position',[360 70 310 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextNestedIn           = uicontrol(gcf,'Style','text','String',['Nested in : '                  handles.SwanInput(handles.ActiveDomain).NstFile],'Position',[360 50 310 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextGridSpecifications = uicontrol(gcf,'Style','text','String','Grid specifications : ',                                                               'Position',[680 90  100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextMMax               = uicontrol(gcf,'Style','text','String',['Grid points in M direction : ' num2str(handles.SwanInput(handles.ActiveDomain).MMax)],'Position',[680 70  250 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextNMax               = uicontrol(gcf,'Style','text','String',['Grid points in N direction : ' num2str(handles.SwanInput(handles.ActiveDomain).NMax)],'Position',[680 50  250 15],'HorizontalAlignment','left','Tag','UIControl');

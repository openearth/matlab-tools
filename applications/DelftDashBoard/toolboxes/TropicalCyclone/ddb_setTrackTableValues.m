function handles=ddb_setTrackTableValues(handles)

iq=handles.Toolbox(tb).Input.quadrant;
handles.Toolbox(tb).Input.tableVMax=squeeze(handles.Toolbox(tb).Input.trackVMax(:,iq));
handles.Toolbox(tb).Input.tableRMax=squeeze(handles.Toolbox(tb).Input.trackRMax(:,iq));
handles.Toolbox(tb).Input.tablePDrop=squeeze(handles.Toolbox(tb).Input.trackPDrop(:,iq));
handles.Toolbox(tb).Input.tableR100=squeeze(handles.Toolbox(tb).Input.trackR100(:,iq));
handles.Toolbox(tb).Input.tableR65=squeeze(handles.Toolbox(tb).Input.trackR65(:,iq));
handles.Toolbox(tb).Input.tableR50=squeeze(handles.Toolbox(tb).Input.trackR50(:,iq));
handles.Toolbox(tb).Input.tableR35=squeeze(handles.Toolbox(tb).Input.trackR35(:,iq));
handles.Toolbox(tb).Input.tableA=squeeze(handles.Toolbox(tb).Input.trackA(:,iq));
handles.Toolbox(tb).Input.tableB=squeeze(handles.Toolbox(tb).Input.trackB(:,iq));

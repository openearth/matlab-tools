function handles=ddb_coordConvertBathymetry(handles)

ii=strmatch('Bathymetry',{handles.Toolbox(:).name},'exact');

ddb_plotBathymetry('delete');
handles.Toolbox(ii).Input.polyLength=0;

function handles=ddb_initializeXBeach(handles,varargin)


handles.model.xbeach.domain=[];
runid='tst';

handles.GUIData.nrXBeachDomains=1;
handles.GUIData.nrXBeachObservationPoints=1;
handles.GUIData.nrXBeachObservationCrossSections=1;
handles.GUIData.nrXBeachOpenBoundaries=1;

handles=ddb_initializeXBeachInput(handles,1,runid);

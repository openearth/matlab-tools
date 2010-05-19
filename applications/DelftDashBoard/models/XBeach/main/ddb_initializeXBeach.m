function handles=ddb_initializeXBeach(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('XBeach',{handles.Model.Name},'exact');
            handles.Model(ii).LongName='X-Beach';
            return
    end
end

ii=strmatch('XBeach',{handles.Model.Name},'exact');

handles.Model(ii).Input=[];
runid='tst';

handles.GUIData.NrXBeachDomains=1;
handles.GUIData.NrXBeachObservationPoints=1;
handles.GUIData.NrXBeachObservationCrossSections=1;
handles.GUIData.NrXBeachOpenBoundaries=1;

handles=ddb_initializeXBeachInput(handles,1,runid);

set(handles.GUIHandles.Menu.Model.XBeach,'Enable','on');

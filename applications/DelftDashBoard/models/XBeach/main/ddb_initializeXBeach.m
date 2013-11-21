function handles=ddb_initializeXBeach(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('XBeach',{handles.Model.name},'exact');
            handles.Model(ii).LongName='X-Beach';
            return
    end
end

ii=strmatch('XBeach',{handles.Model.name},'exact');

handles.Model(ii).Input=[];
runid='tst';

handles.GUIData.nrXBeachDomains=1;
handles.GUIData.nrXBeachObservationPoints=1;
handles.GUIData.nrXBeachObservationCrossSections=1;
handles.GUIData.nrXBeachOpenBoundaries=1;

handles=ddb_initializeXBeachInput(handles,1,runid);

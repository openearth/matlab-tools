function handles=ddb_initializeDelft3DFLOW(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');
            handles.Model(ii).longName='Delft3D-FLOW';
            return
    end
end

% handles.GUIData.activeDryPoint=1;
% handles.GUIData.activeThinDam=1;
% handles.GUIData.activeCrossSection=1;
% handles.GUIData.activeDischarge=1;
% handles.GUIData.activeDrogue=1;
% handles.GUIData.activeObservationPoint=1;
% handles.GUIData.activeOpenBoundary=1;

ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');


handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeFlowDomain(handles,'all',1,runid);

handles.Model(ii).ddFile='test.ddb';
handles.Model(ii).DDBoundaries=[];

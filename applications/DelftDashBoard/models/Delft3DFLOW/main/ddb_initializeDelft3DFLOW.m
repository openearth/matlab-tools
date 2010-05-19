function handles=ddb_initializeDelft3DFLOW(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');
            handles.Model(ii).LongName='Delft3D-FLOW';
            return
    end
end

handles.GUIData.ActiveDryPoint=1;
handles.GUIData.ActiveThinDam=1;
handles.GUIData.ActiveCrossSection=1;
handles.GUIData.ActiveDischarge=1;
handles.GUIData.ActiveDrogue=1;
handles.GUIData.ActiveObservationPoint=1;
handles.GUIData.ActiveOpenBoundary=1;

handles.ActiveDomain=1;
handles.GUIData.NrFlowDomains=1;

handles.Model(md).Input=[];

runid='tst';

handles=ddb_initializeFlowDomain(handles,'all',1,runid);

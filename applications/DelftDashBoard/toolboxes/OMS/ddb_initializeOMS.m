function handles=ddb_initializeOMS(handles,varargin)

ii=strmatch('OMS',{handles.Toolbox(:).name},'exact');
if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Operational Model System';
            return
    end
end

% set(handles.GUIHandles.Menu.Toolbox.OMS,'Enable','off');

handles.Toolbox(ii).stations=[];
handles.Toolbox(ii).nrStations=0;

handles.Toolbox(ii).modelType='Delft3DFLOWWAVE';
handles.Toolbox(ii).shortName='ddb_test';
handles.Toolbox(ii).longName='ddb_testje';
handles.Toolbox(ii).runid='tst';
handles.Toolbox(ii).directory=pwd;

handles.Toolbox(ii).location=[0 0];
handles.Toolbox(ii).xLim=[0 0];
handles.Toolbox(ii).yLim=[0 0];
handles.Toolbox(ii).continent='europe';

handles.Toolbox(ii).flowNested='none';
handles.Toolbox(ii).waveNested='none';

handles.Toolbox(ii).size=4;
handles.Toolbox(ii).priority=5;

handles.Toolbox(ii).flowSpinUp=72;
handles.Toolbox(ii).waveSpinUp=24;
handles.Toolbox(ii).timeStep=1;
handles.Toolbox(ii).mapTimeStep=60;
handles.Toolbox(ii).hisTimeStep=10;
handles.Toolbox(ii).comTimeStep=30;
handles.Toolbox(ii).runTime=999;

handles.Toolbox(ii).useMeteo='gfs1p0';
handles.Toolbox(ii).dxMeteo=5000;

handles.Toolbox(ii).morFac=10;

handles.Toolbox(ii).nrMaps=0;
handles.Toolbox(ii).nrStations=0;
handles.Toolbox(ii).nrProfiles=0;

handles.Toolbox(ii).webSite='SoCalCoastalHazards';

handles.Toolbox(ii).continents{1}='northamerica';
handles.Toolbox(ii).continents{2}='centralamerica';
handles.Toolbox(ii).continents{3}='southamerica';
handles.Toolbox(ii).continents{4}='asia';
handles.Toolbox(ii).continents{5}='europe';
handles.Toolbox(ii).continents{6}='africa';
handles.Toolbox(ii).continents{7}='australia';
handles.Toolbox(ii).continents{8}='world';

handles.Toolbox(ii).activeStation=1;
handles.Toolbox(ii).nrStation=0;
handles.Toolbox(ii).stations=[];

handles.Toolbox(ii).nrMaps=5;
handles.Toolbox(ii).activeMap=1;

handles.Toolbox(ii).mapPlot=[1 1 1 1 1];
handles.Toolbox(ii).mapParameter={'hs','tp','wl','vel','windvel'};
handles.Toolbox(ii).mapColorMap={'jet','jet','jet','jet','jet'};
handles.Toolbox(ii).mapLongName={'Significant wave height','Peak wave period','Water level','Current velocity','Wind speed'};
handles.Toolbox(ii).mapShortName={'wave height','wave period','water level','current','wind'};
handles.Toolbox(ii).mapUnit={'m','s','m','m/s','m/s'};
handles.Toolbox(ii).mapBarLabel={'wave height (m)','wave period (s)','water level (m)','current velocity (m/s)','wind speed (m/s)'};
handles.Toolbox(ii).mapDtAnim=[3600 3600 3600 3600 3600];
handles.Toolbox(ii).mapDtCurVec=[3600 3600 3600 3600 3600];
handles.Toolbox(ii).mapDxCurVec=[0.5 0.5 0.5 0.5 0.5];
handles.Toolbox(ii).mapType={'2dscalar','2dscalar','2dscalar','2dvector','2dvector'};
handles.Toolbox(ii).mapPlotRoutine={'PlotPatches','PlotPatches','PlotPatches','PlotColoredCurvedArrows','PlotColoredCurvedArrows'};



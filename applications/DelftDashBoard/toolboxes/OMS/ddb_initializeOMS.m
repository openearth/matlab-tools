function handles=ddb_initializeOMS(handles,varargin)

ii=strmatch('OMS',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Operational Model System';
            return
    end
end

% set(handles.GUIHandles.Menu.Toolbox.OMS,'Enable','off');

handles.Toolbox(ii).Stations=[];
handles.Toolbox(ii).NrStations=0;

handles.Toolbox(ii).ModelType='Delft3DFLOWWAVE';
handles.Toolbox(ii).ShortName='ddb_test';
handles.Toolbox(ii).LongName='ddb_testje';
handles.Toolbox(ii).Runid='tst';
handles.Toolbox(ii).Directory=pwd;

handles.Toolbox(ii).Location=[0 0];
handles.Toolbox(ii).XLim=[0 0];
handles.Toolbox(ii).YLim=[0 0];
handles.Toolbox(ii).Continent='europe';

handles.Toolbox(ii).FlowNested='none';
handles.Toolbox(ii).WaveNested='none';

handles.Toolbox(ii).Size=4;
handles.Toolbox(ii).Priority=5;

handles.Toolbox(ii).FlowSpinUp=72;
handles.Toolbox(ii).WaveSpinUp=24;
handles.Toolbox(ii).TimeStep=1;
handles.Toolbox(ii).MapTimeStep=60;
handles.Toolbox(ii).HisTimeStep=10;
handles.Toolbox(ii).ComTimeStep=30;
handles.Toolbox(ii).RunTime=999;

handles.Toolbox(ii).UseMeteo='gfs1p0';
handles.Toolbox(ii).DxMeteo=5000;

handles.Toolbox(ii).MorFac=10;

handles.Toolbox(ii).NrMaps=0;
handles.Toolbox(ii).NrStations=0;
handles.Toolbox(ii).NrProfiles=0;

handles.Toolbox(ii).WebSite='SoCalCoastalHazards';

handles.Toolbox(ii).Continents{1}='northamerica';
handles.Toolbox(ii).Continents{2}='centralamerica';
handles.Toolbox(ii).Continents{3}='southamerica';
handles.Toolbox(ii).Continents{4}='asia';
handles.Toolbox(ii).Continents{5}='europe';
handles.Toolbox(ii).Continents{6}='africa';
handles.Toolbox(ii).Continents{7}='australia';
handles.Toolbox(ii).Continents{8}='world';

handles.Toolbox(ii).ActiveStation=1;
handles.Toolbox(ii).NrStation=0;
handles.Toolbox(ii).Stations=[];

handles.Toolbox(ii).NrMaps=5;
handles.Toolbox(ii).ActiveMap=1;

handles.Toolbox(ii).MapPlot=[1 1 1 1 1];
handles.Toolbox(ii).MapParameter={'hs','tp','wl','vel','windvel'};
handles.Toolbox(ii).MapColorMap={'jet','jet','jet','jet','jet'};
handles.Toolbox(ii).MapLongName={'Significant wave height','Peak wave period','Water level','Current velocity','Wind speed'};
handles.Toolbox(ii).MapShortName={'wave height','wave period','water level','current','wind'};
handles.Toolbox(ii).MapUnit={'m','s','m','m/s','m/s'};
handles.Toolbox(ii).MapBarLabel={'wave height (m)','wave period (s)','water level (m)','current velocity (m/s)','wind speed (m/s)'};
handles.Toolbox(ii).MapDtAnim=[3600 3600 3600 3600 3600];
handles.Toolbox(ii).MapDtCurVec=[3600 3600 3600 3600 3600];
handles.Toolbox(ii).MapDxCurVec=[0.5 0.5 0.5 0.5 0.5];
handles.Toolbox(ii).MapType={'2dscalar','2dscalar','2dscalar','2dvector','2dvector'};
handles.Toolbox(ii).MapPlotRoutine={'PlotPatches','PlotPatches','PlotPatches','PlotColoredCurvedArrows','PlotColoredCurvedArrows'};



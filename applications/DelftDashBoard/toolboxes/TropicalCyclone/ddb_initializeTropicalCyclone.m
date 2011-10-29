function handles=ddb_initializeTropicalCyclone(handles,varargin)

ii=strmatch('TropicalCyclone',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.nrTrackPoints   = 0;
handles.Toolbox(ii).Input.name      = '';
handles.Toolbox(ii).Input.initSpeed = 0;
handles.Toolbox(ii).Input.initDir   = 0;
handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.timeStep=6;

handles.Toolbox(ii).Input.quadrantOption='uniform';
handles.Toolbox(ii).Input.quadrant=1;

handles.Toolbox(ii).Input.vMax=120;
handles.Toolbox(ii).Input.rMax=20;
handles.Toolbox(ii).Input.pDrop=5000;
handles.Toolbox(ii).Input.parA=1;
handles.Toolbox(ii).Input.parB=1;
handles.Toolbox(ii).Input.r100=0;
handles.Toolbox(ii).Input.r65=0;
handles.Toolbox(ii).Input.r50=0;
handles.Toolbox(ii).Input.r35=0;

% Track
handles.Toolbox(ii).Input.trackT=floor(now);
handles.Toolbox(ii).Input.trackX=0;
handles.Toolbox(ii).Input.trackY=0;
handles.Toolbox(ii).Input.trackVMax=0;
handles.Toolbox(ii).Input.trackPDrop=0;
handles.Toolbox(ii).Input.trackRMax=0;
handles.Toolbox(ii).Input.trackR100=0;
handles.Toolbox(ii).Input.trackR65=0;
handles.Toolbox(ii).Input.trackR50=0;
handles.Toolbox(ii).Input.trackR35=0;
handles.Toolbox(ii).Input.trackA=0;
handles.Toolbox(ii).Input.trackB=0;

% Table
handles.Toolbox(ii).Input.tableVMax=0;
handles.Toolbox(ii).Input.tablePDrop=0;
handles.Toolbox(ii).Input.tableRMax=0;
handles.Toolbox(ii).Input.tableR100=0;
handles.Toolbox(ii).Input.tableR65=0;
handles.Toolbox(ii).Input.tableR50=0;
handles.Toolbox(ii).Input.tableR35=0;
handles.Toolbox(ii).Input.tableA=0;
handles.Toolbox(ii).Input.tableB=0;

handles.Toolbox(ii).Input.showDetails=1;
handles.Toolbox(ii).Input.name='TC Deepak';
handles.Toolbox(ii).Input.radius=1000;
handles.Toolbox(ii).Input.nrRadialBins=500;
handles.Toolbox(ii).Input.nrDirectionalBins=36;
handles.Toolbox(ii).Input.method=5;

handles.Toolbox(ii).Input.deleteTemporaryFiles=1;

handles.Toolbox(ii).Input.importFormat='JTWCBestTrack';
handles.Toolbox(ii).Input.importFormats={'JTWCBestTrack','UnisysBestTrack'};
handles.Toolbox(ii).Input.importFormatNames={'JTWC Best Track','Unisys Best Track'};

handles.Toolbox(ii).Input.downloadLocation='UnisysBestTracks';
handles.Toolbox(ii).Input.downloadLocations={'UnisysBestTracks','JTWCBestTracks','JTWCCurrentCyclones'};
handles.Toolbox(ii).Input.downloadLocationNames={'UNISYS Track Archive','JTWC Track Archive','JTWC Current Cyclones'};


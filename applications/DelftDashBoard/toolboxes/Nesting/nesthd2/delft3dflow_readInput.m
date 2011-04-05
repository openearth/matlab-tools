function Flow=delft3dflow_readInput(inpdir,runid)
% Returns Flow structure with required Delft3D-FLOW input

%% Read MDF file

MDF=ddb_readMDFText([inpdir runid '.mdf']);

% Dimensions
Flow.MMax=MDF.mnkmax(1);
Flow.NMax=MDF.mnkmax(2);
Flow.KMax=MDF.mnkmax(3);

% Constituents
if ~isempty(find(MDF.sub1=='S', 1));
    Flow.salinity.include=1;    % Salinity will be included
else
    Flow.salinity.include=0;    % Salinity will not be included
end
if ~isempty(find(MDF.sub1=='T', 1));
    Flow.temperature.include=1; % Temperature will be included
else
    Flow.temperature.include=0;    % Salinity will not be included
end

Flow.nrSediments=0;        % No sediments
Flow.nrTracers=0;          % One tracer
Flow.nrConstituents=0;     % One tracer
% Flow.Tracer(1).Name='dye';
% Flow.Tracer(2).Name='dye decay';

% TODO sediments and tracers
if ~isempty(MDF.sub2)
    if MDF.sub2(2)=='C'
        Flow.constituents=1;
    end
    if MDF.sub2(3)=='W'
        Flow.waves=1;
    end
end
for i=1:5
    if isfield(MDF,['namc' num2str(i)])
        fld=deblank(getfield(MDF,['namc' num2str(i)]));
        if ~isempty(fld)
            if strcmpi(fld(1:min(8,length(fld))),'sediment')
                Flow.sediments.include=1;
                Flow.nrSediments=Flow.nrSediments+1;
                Flow.nrConstituents=Flow.nrConstituents+1;
                k=Flow.nrSediments;
                Flow.sediment(k).name=deblank(fld);
            else
                Flow.tracers.include=1;
                Flow.nrConstituents=Flow.nrConstituents+1;
                Flow.nrTracers=Flow.nrTracers+1;
                k=Flow.nrTracers;
                Flow.tracer(k).name=deblank(fld);
            end
        end
    end
end

% Layers
Flow.thick=MDF.thick;
Flow.vertCoord='sigma';
if isfield(MDF,'zmodel')
    if strcmpi(MDF.zmodel(1),'y')
        Flow.vertCoord='z';
        Flow.zBot=MDF.zbot;
        Flow.zTop=MDF.ztop;
    end
end

% Times
Flow.itDate=datenum(MDF.itdate,'yyyy-mm-dd');

if ~isfield(Flow,'StartTime')
    Flow.startTime=Flow.itDate+MDF.tstart/1440;
    Flow.stopTime =Flow.itDate+MDF.tstop/1440;
end
if ~isfield(Flow,'BccTimeStep')
    Flow.bccTimeStep=60;
end
if ~isfield(Flow,'BctTimeStep')
    Flow.bctTimeStep=10;
end

Flow.bctTimes=Flow.startTime:Flow.bctTimeStep/1440:Flow.stopTime;

% Files
Flow.gridFile=MDF.filcco;
Flow.encFile=MDF.filgrd;

Flow.depFile=MDF.fildep;

if isfield(MDF,'filbnd')
    Flow.bndFile=MDF.filbnd;
end

if isfield(MDF,'filbct')
    Flow.bctFile=MDF.filbct;
end

if isfield(MDF,'filbcc')
    Flow.bccFile=MDF.filbcc;
else
    Flow.bccFile='';
end
if isfield(MDF,'filic')
    Flow.iniFile=MDF.filic;
else
    Flow.iniFile='';
end

% Numerics
Flow.dpsOpt=MDF.dpsopt;


%% Read grid
[Flow.gridX,Flow.gridY,enc]=wlgrid('read',[inpdir Flow.gridFile]);

if isfield(Flow,'coordSysType')
    if ~strcmpi(Flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [Flow.gridX,Flow.gridY]=convertCoordinates(Flow.gridX,Flow.gridY,'CS1.name',Flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    end
    Flow.gridX=mod(Flow.gridX,360);
end

[Flow.gridXZ,Flow.gridYZ]=GetXZYZ(Flow.gridX,Flow.gridY);
mn=enclosure('read',[inpdir Flow.encFile]);
[Flow.gridX,Flow.gridY]=enclosure('apply',mn,Flow.gridX,Flow.gridY);
Flow.kcs=determineKCS(Flow.gridX,Flow.gridY);

%% Read bathy
dp=wldep('read',[inpdir Flow.depFile],[Flow.MMax Flow.NMax]);
Flow.depth=-dp(1:end-1,1:end-1);
Flow.depthZ=GetDepthZ(Flow.depth,Flow.dpsOpt);

if isfield(Flow,'bndFile')
    %% Read boundary
    
    % Set some values for initializing (Dashboard specific)
    t0=Flow.startTime;
    t1=Flow.stopTime;
    nrsed=Flow.nrSediments;
    nrtrac=Flow.nrTracers;
    nrharmo=Flow.nrHarmonicComponents;
    x=Flow.gridX;
    y=Flow.gridY;
    z=Flow.depthZ;
    kcs=Flow.kcs;
    
    % Read boundaries into structure
    openBoundaries=delft3dflow_readBndFile(Flow.bndFile);
    
    % Initialize individual boundary sections
    for i=1:length(openBoundaries)
        openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,i,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs);
    end
    
    % Copy open boundaries to Dashboard structure
    Flow.openBoundaries=openBoundaries;
    Flow.nrOpenBoundaries=length(openBoundaries);
    
end


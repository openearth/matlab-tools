function [flow,openBoundaries]=delft3dflow_readInput(inpdir,runid,varargin)
% Returns flow structure with required Delft3D-FLOW input as well as boundary structure for nesting

%% Read MDF file

MDF=delft3dflow_readMDFText([inpdir runid '.mdf']);

% Dimensions
flow.MMax=MDF.mnkmax(1);
flow.NMax=MDF.mnkmax(2);
flow.KMax=MDF.mnkmax(3);

% Constituents
if ~isempty(find(MDF.sub1=='S', 1));
    flow.salinity.include=1;    % Salinity will be included
else
    flow.salinity.include=0;    % Salinity will not be included
end
if ~isempty(find(MDF.sub1=='T', 1));
    flow.temperature.include=1; % Temperature will be included
else
    flow.temperature.include=0;    % Salinity will not be included
end

flow.nrSediments=0;        % No sediments
flow.sediments.include=0;

flow.nrTracers=0;          % No Tracers
flow.tracers=0;

flow.nrConstituents=0;     % One tracer
% flow.Tracer(1).Name='dye';
% flow.Tracer(2).Name='dye decay';

% TODO sediments and tracers
if ~isempty(MDF.sub2)
    if MDF.sub2(2)=='C'
        flow.constituents=1;
    end
    if MDF.sub2(3)=='W'
        flow.waves=1;
    end
end
for i=1:5
    if isfield(MDF,['namc' num2str(i)])
        fld=deblank(getfield(MDF,['namc' num2str(i)]));
        if ~isempty(fld)
            if strcmpi(fld(1:min(8,length(fld))),'sediment')
                flow.sediments.include=1;
                flow.nrSediments=flow.nrSediments+1;
                flow.nrConstituents=flow.nrConstituents+1;
                k=flow.nrSediments;
                flow.sediment(k).name=deblank(fld);
            else
                flow.tracers=1;
                flow.nrConstituents=flow.nrConstituents+1;
                flow.nrTracers=flow.nrTracers+1;
                k=flow.nrTracers;
                flow.tracer(k).name=deblank(fld);
            end
        end
    end
end

% Layers
flow.thick=MDF.thick;
flow.vertCoord='sigma';
if isfield(MDF,'zmodel')
    if strcmpi(MDF.zmodel(1),'y')
        flow.vertCoord='z';
        flow.zBot=MDF.zbot;
        flow.zTop=MDF.ztop;
    end
end

% Times
flow.itDate=datenum(MDF.itdate,'yyyy-mm-dd');

if ~isfield(flow,'StartTime')
    flow.startTime=flow.itDate+MDF.tstart/1440;
    flow.stopTime =flow.itDate+MDF.tstop/1440;
end
if ~isfield(flow,'BccTimeStep')
    flow.bccTimeStep=60;
end
if ~isfield(flow,'BctTimeStep')
    flow.bctTimeStep=10;
end

flow.bctTimes=flow.startTime:flow.bctTimeStep/1440:flow.stopTime;

% Files
flow.gridFile=MDF.filcco;
flow.encFile=MDF.filgrd;

flow.depFile=MDF.fildep;

if isfield(MDF,'filbnd')
    flow.bndFile=MDF.filbnd;
end

if isfield(MDF,'filbct')
    flow.bctFile=MDF.filbct;
end

if isfield(MDF,'filbcc')
    flow.bccFile=MDF.filbcc;
else
    flow.bccFile='';
end
if isfield(MDF,'filic')
    flow.iniFile=MDF.filic;
else
    flow.iniFile='';
end

% Numerics
flow.dpsOpt=MDF.dpsopt;


%% Read grid
[flow.gridX,flow.gridY,enc]=ddb_wlgrid('read',[inpdir flow.gridFile]);

% if isfield(flow,'coordSysType')
%     if ~strcmpi(flow.coordSysType,'geographic')
%         % First convert grid to WGS 84
%         [flow.gridX,flow.gridY]=convertCoordinates(flow.gridX,flow.gridY,'CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
%     end
%     flow.gridX=mod(flow.gridX,360);
% end

[flow.gridXZ,flow.gridYZ]=getXZYZ(flow.gridX,flow.gridY);
mn=ddb_enclosure('read',[inpdir flow.encFile]);
[flow.gridX,flow.gridY]=ddb_enclosure('apply',mn,flow.gridX,flow.gridY);
flow.kcs=determineKCS(flow.gridX,flow.gridY);

%% Read bathy
dp=ddb_wldep('read',[inpdir flow.depFile],[flow.MMax flow.NMax]);
flow.depth=-dp(1:end-1,1:end-1);
flow.depthZ=getDepthZ(flow.depth,flow.dpsOpt);

if isfield(flow,'bndFile')

    %% Read boundary
    
    % Set some values for initializing (Dashboard specific)
    t0=flow.startTime;
    t1=flow.stopTime;
    nrsed=flow.nrSediments;
    nrtrac=flow.nrTracers;
    nrharmo=2;
    x=flow.gridX;
    y=flow.gridY;
    z=flow.depthZ;
    kcs=flow.kcs;
    
    % Read boundaries into structure
    openBoundaries=delft3dflow_readBndFile([inpdir flow.bndFile]);
    
    % Initialize individual boundary sections
    for i=1:length(openBoundaries)
        openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,i,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs);
    end
    
end

function Flow=nest_readDelft3DInput(inpdir,runid)
% Returns Flow structure with required Delft3D-FLOW input

%% Read MDF file

MDF=nest_readMDFText([inpdir runid '.mdf']);

% Dimensions
Flow.MMax=MDF.MNKmax(1);
Flow.NMax=MDF.MNKmax(2);
Flow.KMax=MDF.MNKmax(3);

% Constituents
if ~isempty(find(MDF.Sub1=='S', 1));
    Flow.Salinity.Include=1;    % Salinity will be included
else
    Flow.Salinity.Include=0;    % Salinity will not be included
end
if ~isempty(find(MDF.Sub1=='T', 1));
    Flow.Temperature.Include=1; % Temperature will be included
else
    Flow.Temperature.Include=0;    % Salinity will not be included
end

Flow.NrSediments=0;        % No sediments
Flow.NrTracers=0;          % One tracer
Flow.NrConstituents=0;     % One tracer
% Flow.Tracer(1).Name='dye';
% Flow.Tracer(2).Name='dye decay';

% TODO sediments and tracers
if ~isempty(MDF.Sub2)
    if MDF.Sub2(2)=='C'
        Flow.Constituents=1;
    end
    if MDF.Sub2(3)=='W'
        Flow.Waves=1;
    end
end
for i=1:5
    if isfield(MDF,['Namc' num2str(i)])
        fld=deblank(getfield(MDF,['Namc' num2str(i)]));
        if ~isempty(fld)
            if strcmpi(fld(1:min(8,length(fld))),'sediment')
                Flow.Sediments=1;
                Flow.NrSediments=Flow.NrSediments+1;
                Flow.NrConstituents=Flow.NrConstituents+1;
                k=Flow.NrSediments;
                Flow.Sediment(k).Name=deblank(fld);
            else
                Flow.Tracers=1;
                Flow.NrConstituents=Flow.NrConstituents+1;
                Flow.NrTracers=Flow.NrTracers+1;
                k=Flow.NrTracers;
                Flow.Tracer(k).Name=deblank(fld);
            end
        end
    end
end

% Layers
Flow.Thick=MDF.Thick;
Flow.VertCoord='sigma';
if isfield(MDF,'Zmodel')
    if strcmpi(MDF.Zmodel(1),'y')
        Flow.VertCoord='z';
        Flow.ZBot=MDF.Zbot;
        Flow.ZTop=MDF.Ztop;
    end
end

% Times
Flow.ItDate=datenum(MDF.Itdate,'yyyy-mm-dd');

if ~isfield(Flow,'StartTime')
    Flow.StartTime=Flow.ItDate+MDF.Tstart/1440;
    Flow.StopTime =Flow.ItDate+MDF.Tstop/1440;
end
if ~isfield(Flow,'BccTimeStep')
    Flow.BccTimeStep=60;
end
if ~isfield(Flow,'BctTimeStep')
    Flow.BctTimeStep=10;
end

Flow.BctTimes=[Flow.StartTime Flow.StopTime];
Flow.BctTimes=Flow.StartTime:Flow.BctTimeStep/1440:Flow.StopTime;

% Files
Flow.GridFile=MDF.Filcco;
Flow.EncFile=MDF.Filgrd;

Flow.DepFile=MDF.Fildep;

if isfield(MDF,'Filbnd')
    Flow.BndFile=MDF.Filbnd;
end

if isfield(MDF,'FilbcT')
    Flow.BctFile=MDF.FilbcT;
end

if isfield(MDF,'FilbcC')
    Flow.BccFile=MDF.FilbcC;
else
    Flow.BccFile='';
end
if isfield(MDF,'Filic')
    Flow.IniFile=MDF.Filic;
else
    Flow.IniFile='';
end

% Numerics
Flow.DpsOpt=MDF.Dpsopt;


%% Read grid
[Flow.GridX,Flow.GridY,enc]=wlgrid_mvo('read',[inpdir Flow.GridFile]);

if isfield(Flow,'CoordSysType')
    if ~strcmpi(Flow.CoordSysType,'geographic')
        % First convert grid to WGS 84
        [Flow.GridX,Flow.GridY]=convertCoordinates(Flow.GridX,Flow.GridY,'CS1.name',Flow.CoordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    end
    Flow.GridX=mod(Flow.GridX,360);
end

[Flow.GridXZ,Flow.GridYZ]=GetXZYZ(Flow.GridX,Flow.GridY);
mn=enclosure('read',[inpdir Flow.EncFile]);
[Flow.GridX,Flow.GridY]=enclosure('apply',mn,Flow.GridX,Flow.GridY);
Flow.kcs=DetermineKCS(Flow.GridX,Flow.GridY);

%% Read bathy
dp=wldep_mvo('read',[inpdir Flow.DepFile],[Flow.MMax Flow.NMax]);
Flow.Depth=-dp(1:end-1,1:end-1);
Flow.DepthZ=GetDepthZ(Flow.Depth,Flow.DpsOpt);

if isfield(Flow,'BndFile')
    %% Read boundary
    Flow=ReadBndFile(Flow);
end


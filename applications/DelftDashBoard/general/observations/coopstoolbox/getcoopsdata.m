function varargout=getcoopsdata(opt,varargin)

units='0';    % metres
timezone='0'; % UTC
subset='verified6minutes';
epoch='A';
datum='MSL';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id','stationid'}
                id=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'subset'}
                subset=varargin{ii+1};
            case{'starttime','t0','tstart'}
                t0=datestr(varargin{ii+1},'yyyymmdd HH:MM');
            case{'stoptime','t1','tstop'}
                t1=datestr(varargin{ii+1},'yyyymmdd HH:MM');
            case{'datum'}
                datum=varargin{ii+1};
            case{'epoch'}
                switch lower(varargin{ii+1})
                    case{'superseded'}
                    otherwise
                        epoch='A';
                end                
            case{'units','unit'}
                if strcmpi(varargin{ii+1}(1),'m')
                    units='0';
                else
                    units='1';
                end
            case{'timezone'}
                switch lower(varargin{ii+1})
                    case{'u','g'}
                        % UTC
                        timezone='0';
                    otherwise
                        % Local
                       timezone='1';
                end
        end
    end
end

switch lower(opt)
    case{'getactivestations'}
        varargout{1}=getActiveStations;
    case{'gethistoricstations'}
        varargout{1}=getHistoricCoopsStations;
    case{'getdatums'}
        [varargout{1} varargout{2}]=getDatum(id,units,epoch);
    case{'getobservations'}
        data=getData(id,parameter,subset,t0,t1,timezone,datum,units);
        varargout{1}=data;
    case{'getdatainventory'}
        varargout{1}=getDataInventory(id);
end

%%
function stations=getActiveStations

s = getActiveStationsV2(ActiveStationsService);

for ii=1:length(s.stationsV2.stationV2)
    station=s.stationsV2.stationV2(ii).stationV2;
    stations(ii).name=station.ATTRIBUTES.name;
    stations(ii).id=station.ATTRIBUTES.ID;
    metadata=station.metadataV2.metadataV2;
    stations(ii).lon=str2double(metadata.location.location.long.long);
    stations(ii).lat=str2double(metadata.location.location.lat.lat);
    stations(ii).state=metadata.location.location.state.state;
    stations(ii).date_established=metadata.date_established.date_established;
    stations(ii).shed_id=metadata.shef_id.shef_id;
    stations(ii).deployment_designation=metadata.deployment_designation.deployment_designation;
    for ipar=1:length(station.parameter)
        stations(ii).parameters(ipar).name=station.parameter(ipar).parameter.ATTRIBUTES.name;
        stations(ii).parameters(ipar).dcp=str2double(station.parameter(ipar).parameter.ATTRIBUTES.DCP);
        stations(ii).parameters(ipar).sensorid=station.parameter(ipar).parameter.ATTRIBUTES.sensorID;
        stations(ii).parameters(ipar).status=str2double(station.parameter(ipar).parameter.ATTRIBUTES.status);
    end
end

function stations=getHistoricCoopsStations

s = getHistoricStations(HistoricStationsService);

% for ii=1:length(s.stationsV2.stationV2)
%     station=s.stationsV2.stationV2(ii).stationV2;
%     stations(ii).name=station.ATTRIBUTES.name;
%     stations(ii).id=station.ATTRIBUTES.ID;
%     metadata=station.metadataV2.metadataV2;
%     stations(ii).lon=str2double(metadata.location.location.long.long);
%     stations(ii).lat=str2double(metadata.location.location.lat.lat);
%     stations(ii).state=metadata.location.location.state.state;
%     stations(ii).date_established=metadata.date_established.date_established;
%     stations(ii).shed_id=metadata.shef_id.shef_id;
%     stations(ii).deployment_designation=metadata.deployment_designation.deployment_designation;
%     for ipar=1:length(station.parameter)
%         stations(ii).parameters(ipar).name=station.parameter(ipar).parameter.ATTRIBUTES.name;
%         stations(ii).parameters(ipar).dcp=str2double(station.parameter(ipar).parameter.ATTRIBUTES.DCP);
%         stations(ii).parameters(ipar).sensorid=station.parameter(ipar).parameter.ATTRIBUTES.sensorID;
%         stations(ii).parameters(ipar).status=str2double(station.parameter(ipar).parameter.ATTRIBUTES.status);
%     end
% end

%%
function d=getData(id,parameter,waterleveloption,t0,t1,timezone0,datum,unit0)

subsetstr=[];
d=[];

try
    switch lower(parameter)
        case{'waterlevel','water level','wl'}
            
            switch lower(waterleveloption)
                case{'verified6minutes'}
                    [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,unitstring,timeZone,data]=getWLVerifiedSixMinAndMetadata(WaterLevelVerifiedSixMinService,id,t0,t1,datum,unit0,timezone0);
                case{'verifiedhourly'}
                    [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,unitstring,timeZone,data]=getVerifiedHourlyAndMetadata(WaterLevelVerifiedHourlyService,id,t0,t1,datum,unit0,timezone0);
%                 case{'highlow'}
%                     data=getWaterLevelVerifiedHourly(WaterLevelVerifiedHourlyService,id,t0,t1,datum,unit,timezone);
%                 case{'dailymean'}
%                 case{'raw1minute'}
%                     [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data]=getWLRawOneMinAndMetadata(WaterLevelRawOneMinService,id,t0,t1,datum,unit0,timezone0);                    
                case{'raw6minutes'}
                    [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,datum1,unitstring,timeZone,data]=getWLRawSixMinAndMetadata(WaterLevelRawSixMinService,id,t0,t1,datum,unit0,timezone0);                    
            end
            
            subsetstr=waterleveloption;
            parametername{1}='water_level';
            parametercode{1}='WL';
            unit{1}=unitstring;            
            
        case{'temperature','water temp','water temperature'}
            [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data]=getWaterTemperatureAndMetadata(WaterTemperatureService,id,t0,t1,unit0,timezone0);
            parametername{1}='water_temperature';
            parametercode{1}='WT';
            unit{1}=unitstring;

        case{'wind','winds'}
            [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data]=getWindAndMetadata(WindService,id,t0,t1,unit0,timezone);
            
            parametername{1}='wind_speed';
            parametername{2}='wind_direction';
            parametername{3}='wind_gust';
            parametercode{1}='WS';
            parametercode{2}='WD';
            parametercode{3}='WG';
            unitstring=textscan(unitstring,'%s','delimiter',',');
            unit{1}=unitstring{1}{1};
            unit{2}=unitstring{1}{2};
            unit{3}=unitstring{1}{3};

        case{'barometric pressure','barometric_pressure','air pressure','air_pressure'}
            [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data] = getPressureAndMetadata(BarometricPressureService,id,t0,t1,timezone);
%            data=getBarometricPressure(BarometricPressureService,id,t0,t1,timezone);
            parametername{1}='barometric_pressure';
            parametercode{1}='BP';
            unit{1}=unitstring;

        case{'airtemperature','air temp','air temperature'}
            [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data]=getAirTemperatureAndMetadata(AirTemperatureService,id,t0,t1,unit0,timezone);
            parametername{1}='air_temperature';
            parametercode{1}='AT';
            unit{1}=unitstring;

        case{'conductivity'}
            [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unitstring,data]=getConductivityAndMetadata(ConductivityService,id,t0,t1,timezone);
            parametername{1}='conductivity';
            parametercode{1}='AT';
            unit{1}=unitstring;
            
        otherwise
            disp(['Parameter ' parameter ' not recognized ...']);
    end

    if ~isempty(data)
        
        d.stationid=stationId;
        d.stationname=stationName;
        d.latitude=latitude;
        d.longitude=longitude;
        d.state=state;
        d.datasource=dataSource;
        d.disclaimer=COOPSDisclaimer;
        d.begindate=beginDate;
        d.enddata=endDate;
        d.timezone=timeZone;
        d.unit=unit;
        if ~isempty(subsetstr)
            d.subset=subsetstr;
        end
        
        % Time
        zer=zeros(1,length(data.item));
        time=zer;
        for it=1:length(data.item)
            time(it)=datenum(data.item(it).timeStamp);
        end
        
        for ip=1:length(parametername)
            d.parameters(ip).parameter.name=parametername{ip};
            d.parameters(ip).parameter.dbname=parameter;
            d.parameters(ip).parameter.time=time;
            d.parameters(ip).parameter.val=zer;
            for it=1:length(data.item)
                d.parameters(ip).parameter.val(it)=str2double(data.item(it).(parametercode{ip}));
            end
            d.parameters(ip).parameter.size=[length(data.item) 0 0 0 0];
            d.parameters(ip).parameter.quantity='scalar';
            d.parameters(ip).parameter.unit=unit{ip};
        end
        
    end
    
catch
    warning('No data available ...');
    d=[];
end

%%
function [datums,MinMaxWL]=getDatum(id,unit,epoch)

[datums,MinMaxWL]=getDatums(DatumsService,id,epoch,unit);
fldnames=fieldnames(datums);
for ii=1:length(fldnames)
    datums.(fldnames{ii})=str2double(datums.(fldnames{ii}));
end
MinMaxWL.maxWaterLevel=str2double(MinMaxWL.maxWaterLevel);
MinMaxWL.minWaterLevel=str2double(MinMaxWL.minWaterLevel);

[stationId,stationName,latitude,longitude,state,dataSource,status,epoch,unit,elevation,datums,MinMaxWL]=getDatumsAndMetaData(DatumsService,id,epoch,unit);

%%
function s=getDataInventory(id)
url=['http://opendap.co-ops.nos.noaa.gov/axis/webservices/datainventory/response.jsp?stationId=' id '&format=xml&Submit=Submit'];
xml=fastxml2struct(url,'structuretype','long','includeattributes');
for ipar=1:length(xml.Body.Body.DataInventory.DataInventory.station.station.parameter)
    s.parameters(ipar).longname=xml.Body.Body.DataInventory.DataInventory.station.station.parameter(ipar).parameter.ATTRIBUTES.name.value;
    s.parameters(ipar).firsttime=xml.Body.Body.DataInventory.DataInventory.station.station.parameter(ipar).parameter.ATTRIBUTES.first.value;
    s.parameters(ipar).lasttime=xml.Body.Body.DataInventory.DataInventory.station.station.parameter(ipar).parameter.ATTRIBUTES.last.value;
    switch s.parameters(ipar).longname
        case{'Preliminary 1-Minute Water Level'}
            s.parameters(ipar).name='water_level';
            s.parameters(ipar).subset='raw1minute';
        case{'Preliminary 6-Minute Water Level'}
            s.parameters(ipar).name='water_level';
            s.parameters(ipar).subset='raw6minutes';
        case{'Verified 6-Minute Water Level'}
            s.parameters(ipar).name='water_level';
            s.parameters(ipar).subset='verified6minutes';
        case{'Verified Hourly Height Water Level'}
            s.parameters(ipar).name='water_level';
            s.parameters(ipar).subset='verifiedhourly';
        case{'Verified High/Low Water Level'}
            s.parameters(ipar).name='water_level';
            s.parameters(ipar).subset='verifiedhighlow';
    end
end

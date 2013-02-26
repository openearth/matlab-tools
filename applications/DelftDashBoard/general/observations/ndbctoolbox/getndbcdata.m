function varargout=getndbcdata(opt,varargin)

setglobal=0;
inputfile=[];
outputfile=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id','stationid'}
                id=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'starttime','t0'}
                t0=varargin{ii+1};
            case{'stoptime','t1'}
                t1=varargin{ii+1};
            case{'inputfile'}
                inputfile=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
            case{'global'}
                setglobal=1;
        end
    end
end

switch lower(opt)
    case{'getcapabilities'}
        varargout{1}=getCapabilities(inputfile,outputfile,setglobal);
    case{'getstations'}
        varargout{1}=getStations();
    case{'getobservations'}
        varargout{1}=getData(id,parameter,t0,t1);
end

%%
function capabilities=getCapabilities(inputfile,outputfile,setglobal)

if isempty(inputfile)
    % Get data from NDBC SOS server
    capabilities=fastxml2struct('http://sdf.ndbc.noaa.gov/sos/server.php?request=GetCapabilities&service=SOS','structuretype','long','includeroot');
else
    % Get data from file
    [pathstr,name,ext]=fileparts(inputfile);
    switch lower(ext(2:end))
        case{'mat'}            
            capabilities=load(inputfile);
        case{'xml'}
            capabilities=fastxml2struct(inputfile,'structuretype','long','includeroot');
    end
end

if ~isempty(outputfile)
    [pathstr,name,ext]=fileparts(outputfile);
    switch lower(ext(2:end))
        case{'mat'}            
            save(outputfile,'-struct','capabilities');
        case{'xml'}
            struct2xml(outputfile,capabilities,'structuretype','long','includeattributes','includeroot')
    end
end

if setglobal
    setCapabilitiesGlobal(capabilities);
end

%%
function setCapabilitiesGlobal(capabilities)

global NDBCCapabilities

NDBCCapabilities=capabilities.Capabilities;

%%
function stations=getStations

global NDBCCapabilities

s0=NDBCCapabilities.Contents.Contents.ObservationOfferingList.ObservationOfferingList.ObservationOffering;

n=0;
for ib=1:length(s0)
    s=s0(ib).ObservationOffering;
    id=s.ATTRIBUTES.id.value;
    switch id
        case{'network-all'}
        otherwise
            n=n+1;
            stations(n).id=id(end-4:end);
            stations(n).description=s.description.description.value;
            loc=str2num(s.boundedBy.boundedBy.Envelope.Envelope.upperCorner.upperCorner.value);
            stations(n).x=loc(2);
            stations(n).y=loc(1);
            np=length(s.observedProperty);
            for ip=1:np
                property=s.observedProperty(ip).observedProperty.ATTRIBUTES.href.value;
                ii=find(property=='/');
                property=property(ii(end)+1:end);
                stations(n).observedproperties{ip}=property;
            end
    end
end

%%
function data=getData(id,parameter,t0,t1)
   
url='http://sdf.ndbc.noaa.gov/sos/server.php';

arg.request='GetObservation';
arg.service='SOS';
arg.version='1.0.0';
arg.responseformat='text/xml;subtype="om/1.0.0"';
arg.responseformat='text/csv';
arg.offering=['urn:ioos:station:wmo:' id];
arg.observedproperty=parameter;
t0=datestr(t0,'yyyy-mm-ddTHH:MM:SSZ');
t1=datestr(t1,'yyyy-mm-ddTHH:MM:SSZ');
arg.eventtime=[t0 '/' t1];

urlstr=[url '?'];
fldnames=fieldnames(arg);
for ii=1:length(fldnames)
    urlstr=[urlstr fldnames{ii} '=' arg.(fldnames{ii})];
    if ii<length(fldnames)
        urlstr=[urlstr '&'];
    end
end

s=urlread(urlstr);

data=[];

values=textscan(s,'%s','delimiter','\n');

% First read the parameter list
parstr=values{1}{1};
parameters=textscan(parstr,'%s','delimiter',',');    
parameters=parameters{1};
for ip=1:length(parameters)
    par=textscan(parameters{ip},'%s','delimiter','"');
    parameters{ip}(parameters{ip}=='"')='';
    ii=find(parameters{ip}==' ');
    if ~isempty(ii)
        unit{ip}=parameters{ip}(ii(1)+2:end-1);
        parameters{ip}=parameters{ip}(1:ii(1)-1);
    else
        unit{ip}='';
    end
end

% Now read the data
v=values{1};
v=v(2:end);
nt=length(v);

if nt>0
    
    for it=1:nt
        vv=textscan(v{it},'%s','delimiter',',');
        vv=vv{1};
        for ip=1:length(vv)
            val{it,ip}=vv{ip};
        end
        if strcmpi(v{it}(end),',')
            val{it,ip+1}='';
        end
    end
    
    d=[];
    
    for ip=1:length(parameters)
        switch parameters{ip}
            case{'date_time'}
                time=zeros(1,nt);
                for it=1:nt
                    str=val{it,ip};
                    str=strrep(str,'T',' ');
                    str=strrep(str,'Z',' ');
                    time(it)=datenum(str);
                end
            case{'station_id'}
                stationid=val{1,ip};
            case{'sensor_id'}
                sensorid=val{1,ip};
            case{'calculation_method'}
                calculationmethod=val{1,ip};
            case{'longitude'}
                lon=str2double(val{1,ip});
            case{'latitude'}
                lat=str2double(val{1,ip});
            otherwise
                % Real data
                % First check dimensions
                if isempty(val{1,ip})
                    npoints=0;
                else
                    cls=textscan(val{1,ip},'%f','delimiter',';');
                    npoints=length(cls{1});
                end
                d.(parameters{ip}).data=zeros(npoints,nt);
                for it=1:nt
                    if isempty(val{it,ip})
                        d.(parameters{ip}).data(it)=NaN;
                    else
                        cls=textscan(val{it,ip},'%f','delimiter',';');
                        d.(parameters{ip}).data(:,it)=cell2mat(cls);
                    end
                end
                d.(parameters{ip}).unit=unit{ip};
        end
    end
    
    % Now store in a proper data structure
    fldnames=fieldnames(d);
    data.stationname='';
    data.stationid=nocolon(stationid);
    data.longitude=lon;
    data.latitude=lat;
    data.timezone='UTC';
    data.source='NDBC';
    for ip=1:length(fldnames)
        data.parameters(ip).parameter.name=fldnames{ip};
        data.parameters(ip).parameter.time=time;
        data.parameters(ip).parameter.val=d.(fldnames{ip}).data;
        if size(d.(fldnames{ip}).data,1)>2
            % spectral data
            data.parameters(ip).parameter.size=[length(time) 0 size(d.(fldnames{ip}).data,1) 0 0];
        else
            % time series
            data.parameters(ip).parameter.size=[length(time) 0 0 0 0];
        end
        data.parameters(ip).parameter.quantity='scalar';
        data.parameters(ip).parameter.unit=d.(fldnames{ip}).unit;
    end
    
end


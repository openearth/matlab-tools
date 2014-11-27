function varargout=DDB_OBSERVATIONSTATIONS_USGS(OPT,varargin)
%DDB_OBSERVATIONSTATIONS_NDBC ddb wrapper for getndbcdata
%
%See also: getndbcdata, getcoopsdata

xl=[];
yl=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id','stationid'}
                id=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'starttime','t0','tstart'}
                t0=varargin{ii+1};
            case{'stoptime','t1','tstop'}
                t1=varargin{ii+1};
            case{'inputfile'}
                inputfile=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
            case{'xlim'}
                xl=varargin{ii+1};
            case{'ylim'}
                yl=varargin{ii+1};
        end
    end
end

switch lower(OPT)
    case{'readdatabase'}
        % Set capabilities in global structure
%        getndbcdata('getcapabilities','inputfile',inputfile);
        varargout{1}=readDatabase(xl,yl);
    case{'getobservations'}
        varargout{1}=getusgsdata('getobservations','id',id,'parameter',parameter,'t0',t0,'t1',t1);
end

%%
function database=readDatabase(xl,yl)

database.name                  = 'usgs';
database.longname              = 'USGS Water Data';
database.institution           = 'USGS';
database.coordinatesystem.name = 'WGS 84';
database.coordinatesystem.type = 'geographic';
database.servertype            = [];
database.url                   = [];

if isempty(xl)
    
    stations.description='N/A';
    stations.id='n/a';
    stations.x=0;
    stations.y=0;
    stations.observedproperties{1}='none';
    
    
else
    
    url='http://waterservices.usgs.gov/nwis/iv/?format=waterml,1.1&bBox=';
    url=[url num2str(xl(1)) ',' num2str(yl(1)) ',' num2str(xl(2)) ',' num2str(yl(2))];
    sloc=xml2struct(url,'structuretype','long');
    
    for iii=1:length(sloc.timeSeries)
        
        stations(iii).description=sloc.timeSeries(iii).timeSeries.sourceInfo.sourceInfo.siteName.siteName.value;
        stations(iii).id=sloc.timeSeries(iii).timeSeries.sourceInfo.sourceInfo.siteCode.siteCode.value;
        
        lon=str2double(sloc.timeSeries(iii).timeSeries.sourceInfo.sourceInfo.geoLocation.geoLocation.geogLocation.geogLocation.longitude.longitude.value);
        lat=str2double(sloc.timeSeries(iii).timeSeries.sourceInfo.sourceInfo.geoLocation.geoLocation.geogLocation.geogLocation.latitude.latitude.value);
        
        stations(iii).x=lon;
        stations(iii).y=lat;
        
        for ivar=1:length(sloc.timeSeries(iii).timeSeries.variable)
%            stations(iii).observedproperties{ivar}=sloc.timeSeries(iii).timeSeries.variable(ivar).variable.variableName.variableName.value;
            stations(iii).observedproperties{ivar}=sloc.timeSeries(iii).timeSeries.variable(ivar).variable.variableCode.variableCode.value;
        end
        
    end
    
end

for istat=1:length(stations)
    database.stationlongnames{istat} = stations(istat).description;
    database.stationnames{istat}     = stations(istat).description;
    database.stationids{istat}       = stations(istat).id;
    database.x(istat)                = stations(istat).x;
    database.y(istat)                = stations(istat).y;
    database.xlocal(istat)           = stations(istat).x;
    database.ylocal(istat)           = stations(istat).y;
    for j=1:length(stations(istat).observedproperties)
        database.parameters(istat).name{j}=stations(istat).observedproperties{j};
        database.parameters(istat).status(j)=1;
    end
end


database.datums      = {''};
database.datum       = '';

database.subset      = '';
database.subsets     = {''};
database.subsetnames = {''};

database.timezones   = {''};
database.timezone    = '';

database.download    = 1;

%%
function data=getusgsdata(opt,varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id'}
                id=varargin{ii+1};
            case{'t0'}
                t0=varargin{ii+1};
            case{'t1'}
                t1=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
        end
    end
end

t0str=datestr(t0,'yyyy-mm-dd');
t1str=datestr(t1,'yyyy-mm-dd');

url=['http://waterservices.usgs.gov/nwis/iv/?format=waterml,1.1&indent=on&sites=' id '&startDT=' t0str '&endDT=' t1str '&parameterCd=' parameter];
s=xml2struct(url,'structuretype','long');
nval=length(s.timeSeries.timeSeries.values(1).values.value);
%for it=1:nval
t=zeros(nval,1);
v=t;
for it=1:nval
    tstr=s.timeSeries.timeSeries.values(1).values.value(it).value.ATTRIBUTES.dateTime.value(1:19);
    vstr=s.timeSeries.timeSeries.values(1).values.value(it).value.value;
    t(it)=datenum(tstr,'yyyy-mm-ddTHH:MM:SS');
    v(it)=str2double(vstr);
end
v(v<-999)=NaN;
plot(t,v);

lon=str2double(sloc.timeSeries.timeSeries.sourceInfo.sourceInfo.geoLocation.geoLocation.geogLocation.geogLocation.longitude.longitude.value);
lat=str2double(sloc.timeSeries.timeSeries.sourceInfo.sourceInfo.geoLocation.geoLocation.geogLocation.geogLocation.latitude.latitude.value);

% Now store in a proper data structure
data.stationname  = '';
data.stationid    = nocolon(id);
data.longitude    = lon;
data.latitude     = lat;
data.timezone     = 'UTC';
data.source       = 'USGS';
ip=1;
data.parameters(ip).parameter.name = parameter;
data.parameters(ip).parameter.time = t;
data.parameters(ip).parameter.val  = v;
data.parameters(ip).parameter.size=[length(t) 0 0 0 0];
data.parameters(ip).parameter.quantity='scalar';
data.parameters(ip).parameter.unit    ='m';


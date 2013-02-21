clear variables;

% url='http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveCurrentStations?wsdl';
% createClassFromWsdl(url);
% serv=ActiveCurrentStationsService;
% stations = getActiveCurrentStations(serv);

% url='http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveStations?wsdl';
% createClassFromWsdl(url);
% disp('done')
% stations = getActiveStations(ActiveStationsService);

% url='http://opendap.co-ops.nos.noaa.gov/axis/services/SurveyCurrentStations?wsdl';
% createClassFromWsdl(url);
% disp('done')
% serv=SurveyCurrentStationsService;
% stations = getSurveyCurrentStations(serv);

url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/datums/wsdl/Datums.wsdl';
createClassFromWsdl(url);
disp('done')
serv=DatumsService;
getDatums(serv,'8454000','A','0');

% url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhourly/wsdl/WaterLevelVerifiedHourly.wsdl';
% createClassFromWsdl(url);
% serv=WaterLevelVerifiedHourlyService;
% 
% stationId='8454000';
% beginDate='20060101 00:00';
% endDate='20060105 00:18';
% datum='MLLW';
% unit='0';
% timeZone='0';
% data=getWaterLevelVerifiedHourly(serv,stationId,beginDate,endDate,datum,unit,timeZone);
% disp('done')
% for i=1:length(data.item)
%     t(i)=datenum(data.item(i).timeStamp);
%     v(i)=str2double(data.item(i).WL);
% end
% plot(t,v);


% url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelrawsixmin/wsdl/WaterLevelRawSixMin.wsdl';
% createClassFromWsdl(url);
% serv=WaterLevelRawSixMinService;
% disp('done')
% stationId='8454000';
% beginDate='20060101 00:00';
% endDate='20060105 00:18';
% datum='MLLW';
% unit='0';
% timeZone='0';
% [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,datum,unit,timeZone,data]=getWLRawSixMinAndMetadata(serv,stationId,beginDate,endDate,datum,unit,timeZone);
% disp('done')
% for i=1:length(data.item)
%     t(i)=datenum(data.item(i).timeStamp);
%     v(i)=str2double(data.item(i).WL);
% end
% plot(t,v);
% 

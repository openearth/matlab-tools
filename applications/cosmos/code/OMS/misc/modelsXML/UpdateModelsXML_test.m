function UpdateModelsXML(hm,m)

dr=[hm.WebDir 'forecasts\'];

models=xml_load([dr 'models.xml']);

ifound = 0;

for i=1:length(models)
    if strcmpi(models(i).model.name,hm.Models(m).Abbr)
        ifound=i;
        break;
    end
end

if ifound>0
    ii=ifound;
else
    ii=length(models)+1;
end

models(ii).model.name=hm.Models(m).Abbr;
models(ii).model.longname=hm.Models(m).Name;
models(ii).model.continent=hm.Models(m).Continent;
models(ii).model.longitude=hm.Models(m).Location(1);
models(ii).model.latitude=hm.Models(m).Location(2);
models(ii).model.type=hm.Models(m).Type;
models(ii).model.size=hm.Models(m).Size;
% models(ii).model.starttime=datestr(hm.Models(m).StartTime);
% models(ii).model.stoptime =datestr(hm.Models(m).StopTime);
% models(ii).model.starttime=datestr(now-3,'yyyymmdd HHMMSS');
% models(ii).model.stoptime =datestr(now,'yyyymmdd HHMMSS');
models(ii).model.starttime='20090329 120000';
models(ii).model.stoptime ='20090401 120000';
models(ii).model.timestep ='3';
models(ii).model.lastupdate=[datestr(now) ' (CET)'];
for j=1:hm.Models(m).NrStations
    models(ii).model.stations(j).station.name      = hm.Models(m).Stations(j).Name1;
    models(ii).model.stations(j).station.longname  = hm.Models(m).Stations(j).Name2;
    models(ii).model.stations(j).station.longitude = hm.Models(m).Stations(j).Location(1);
    models(ii).model.stations(j).station.latitude  = hm.Models(m).Stations(j).Location(2);
    models(ii).model.stations(j).station.type      = hm.Models(m).Stations(j).Type;
end

xml_save([dr 'models.xml'],models,'off');

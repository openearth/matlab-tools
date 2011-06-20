function UpdateScenarioXML(hm)

dr=[hm.WebDir 'scenarios\' hm.Name '\'];

scenarios(1).scenario.name=hm.Name;
scenarios(1).scenario.longname=hm.LongName;
scenarios(1).scenario.starttime=datestr(hm.StartTime,'yyyymmdd HHMMSS');
scenarios(1).scenario.stoptime=datestr(hm.StopTime,'yyyymmdd HHMMSS');
scenarios(1).scenario.timestring=[datestr(hm.StartTime,0) ' - ' datestr(hm.StopTime,0)];

xml_save([dr 'scenario.xml'],scenarios,'off');

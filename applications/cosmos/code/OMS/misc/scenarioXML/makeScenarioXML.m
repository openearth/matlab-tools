clear all;close all;

hm=ReadOMSMainConfigFile;

hm.Name    ='forecasts';
hm.LongName='Forecasts';
hm.StartTime = floor(now);
hm.StopTime = floor(now)+3;

UpdateScenarioXML(hm);

hm.Name    ='elnino1982';
hm.LongName='El Nino 1982';
hm.StartTime = datenum(1982,2,15);
hm.StopTime = datenum(1982,2,18);

UpdateScenarioXML(hm);

hm.Name    ='winter2003';
hm.LongName='Winter 2003';
hm.StartTime = datenum(2003,2,15);
hm.StopTime = datenum(2003,2,18);

UpdateScenarioXML(hm);

hm.Name    ='storm500y';
hm.LongName='500-year storm';
hm.StartTime = datenum(2015,4,12);
hm.StopTime = datenum(2015,4,15);

UpdateScenarioXML(hm);

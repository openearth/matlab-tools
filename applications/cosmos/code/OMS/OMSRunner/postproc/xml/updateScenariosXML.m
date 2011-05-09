function updateScenariosXML(hm,m)

% Updates scenarios.xml file for all websites

for iw=1:length(hm.Models(m).WebSite)

    wbdir=hm.Models(m).WebSite(iw).Name;

    dr=[hm.WebDir wbdir filesep 'scenarios' filesep];

    fname=[dr 'scenarios.xml'];

    if exist(fname,'file')

        scenarios=xml_load([dr 'scenarios.xml']);

        ifound = 0;

        for i=1:length(scenarios)
            if strcmpi(scenarios(i).scenario.name,hm.Scenario)
                ifound=i;
                break;
            end
        end

        if ifound>0
            ii=ifound;
        else
            ii=length(scenarios)+1;
        end

    else
        ii=1;
    end

    scenarios(ii).scenario=[];

    scenarios(ii).scenario.name=hm.scenarioShortName;
    scenarios(ii).scenario.longname=hm.scenarioLongName;
    t0=hm.Cycle;
    t1=hm.Cycle+hm.RunTime/24;
    scenarios(ii).scenario.starttime=datestr(t0,'yyyymmdd HHMMSS');
    scenarios(ii).scenario.stoptime=datestr(t1,'yyyymmdd HHMMSS');
    scenarios(ii).scenario.timestring=[datestr(t0) ' - ' datestr(t1)];

    for iw2=1:length(hm.website)
        if strcmpi(hm.website(iw2).name,wbdir)
            scenarios(ii).scenario.longitude=hm.website(iw2).longitude;
            scenarios(ii).scenario.latitude=hm.website(iw2).latitude;
            scenarios(ii).scenario.elevation=hm.website(iw2).elevation;
        end
    end

    im=0;
    for i=1:hm.NrModels

        Model=hm.Models(i);
        
        % Check if model should be included in website
        incl=0;
        for iw2=1:length(Model.WebSite)
            if strcmpi(Model.WebSite(iw2).Name,wbdir)
                xloc=Model.WebSite(iw2).Location(1);
                yloc=Model.WebSite(iw2).Location(2);
                incl=1;
                break;
            end
        end

        if hm.Models(i).Run && incl

            im=im+1;

            scenarios(ii).scenario.models(im).model.shortname=Model.Name;
            scenarios(ii).scenario.models(im).model.longname=Model.LongName;
            scenarios(ii).scenario.models(im).model.continent=Model.Continent;


            if ~strcmpi(Model.CoordinateSystem,'wgs 84')
                [lon,lat]=ConvertCoordinates(xloc,yloc,'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            else
                lon=xloc;
                lat=yloc;
            end
            scenarios(ii).scenario.models(im).model.longitude=lon;
            scenarios(ii).scenario.models(im).model.latitude=lat;
            scenarios(ii).scenario.models(im).model.type=Model.Type;
            scenarios(ii).scenario.models(im).model.size=Model.Size;
        end

    end

    xml_save([dr 'scenarios.xml'],scenarios,'off');

end

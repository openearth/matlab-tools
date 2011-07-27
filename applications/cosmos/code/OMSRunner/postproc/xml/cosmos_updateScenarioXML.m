function cosmos_updateScenarioXML(hm,m)
% Updates scenario xml file for present scenario on all websites

for iw=1:length(hm.Models(m).WebSite)

    wbdir=hm.Models(m).WebSite(iw).Name;

    dr=[hm.WebDir wbdir filesep 'scenarios' filesep hm.scenarioShortName filesep];

    fname=[dr hm.scenarioShortName '.xml'];

    scenario=[];

    scenario.name.value=hm.scenarioShortName;
    scenario.name.type='char';

    scenario.longname.value=hm.scenarioLongName;
    scenario.longname.type='char';

    t0=hm.Cycle;
    t1=hm.Cycle+hm.RunTime/24;
    
    scenario.starttime.value=t0;
    scenario.starttime.type='date';

    scenario.stoptime.value=t1;
    scenario.stoptime.type='date';

    scenario.timestring.value=[datestr(t0) ' - ' datestr(t1)];
    scenario.timestring.type='char';

    for iw2=1:length(hm.website)
        if strcmpi(hm.website(iw2).name,wbdir)

            scenario.longitude.value=hm.website(iw2).longitude;
            scenario.longitude.type='real';
            
            scenario.latitude.value=hm.website(iw2).latitude;
            scenario.latitude.type='real';
            
            scenario.elevation.value=hm.website(iw2).elevation;
            scenario.elevation.type='real';
        end
    end

    im=0;
    for i=1:hm.NrModels

        Model=hm.Models(i);
        
        % Check if model should be included in website
        incl=0;
        for iw2=1:length(Model.WebSite)
            if strcmpi(Model.WebSite(iw2).Name,wbdir)
                incl=1;
                break;
            end
        end

        if hm.Models(i).Run && incl

            im=im+1;

            scenario.models(im).model.shortname.value=Model.Name;
            scenario.models(im).model.shortname.type='char';

        end

    end

    struct2xml(fname,scenario);

end

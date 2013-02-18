function cosmos_updateScenarioXML(hm,m)
% Updates scenario xml file for present scenario on all websites

for iw=1:length(hm.models(m).webSite)

    wbdir=hm.models(m).webSite(iw).name;

    dr=[hm.webDir wbdir filesep 'scenarios' filesep hm.scenarioShortName filesep];

    fname=[dr hm.scenarioShortName '.xml'];

    scenario=[];

    scenario.name.value=hm.scenarioShortName;
    scenario.name.type='char';

    scenario.longname.value=hm.scenarioLongName;
    scenario.longname.type='char';
    
    scenario.type.value=hm.scenarioType;
    scenario.type.type='char';
    
    t0=hm.cycle;
    t1=hm.cycle+hm.runTime/24;
    
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
    
%     iorder=[];
%     for i=1:hm.nrModels
%         if hm.models(i).webSite(iw).positionToDisplay>=0
%             iorder(end+1)=hm.models(i).webSite(iw).positionToDisplay;
%         else
%             iorder(end+1)=i;
%         end
%     end

    scenario.models=[];
    im=0;
%     for ii=1:length(find(iorder~=0))
%         i=find(iorder==ii);

    for i=1:hm.nrModels

        model=hm.models(i);
        
        % Check if model should be included in website
        incl=0;
        for iw2=1:length(model.webSite)
            if strcmpi(model.webSite(iw2).name,wbdir)
                incl=1;
                break;
            end
        end

        if hm.models(i).run && incl
            if hm.models(i).webSite(iw2).positionToDisplay>=0
                im=hm.models(i).webSite(iw2).positionToDisplay;
            else
                im=im+1;            
            end
            scenario.models(im).model.shortname.value=model.name;
            scenario.models(im).model.shortname.type='char';
        end
        
    end

    struct2xml(fname,scenario,'includeattributes',1,'structuretype',0);

end

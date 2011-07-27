function cosmos_updateScenariosDotXML(hm,m)
% Updates scenarios.xml file for all websites

for iw=1:length(hm.Models(m).WebSite)
    
    wbdir=hm.Models(m).WebSite(iw).Name;
    
    dr=[hm.WebDir wbdir filesep 'scenarios' filesep];
    
    fname=[dr 'scenarios.xml'];
    
    iUpdate=0;
    
    if exist(fname,'file')
        
        scenarios=xml_load([dr 'scenarios.xml']);
        
        ifound = 0;
        
        for i=1:length(scenarios)
            if strcmpi(scenarios(i).scenario.name,hm.Scenario)
                ifound=i;
                break;
            end
        end
        
        if ifound==0
            % New scenarios
            ii=length(scenarios)+1;
        end
        
    else
        ii=1;
        iUpdate=1;
    end
    
    if iUpdate
        scenarios(ii).scenario=[];
        scenarios(ii).scenario.name=hm.scenarioShortName;
        scenarios(ii).scenario.longname=hm.scenarioLongName;
        xml_save([dr 'scenarios.xml'],scenarios,'off');
    end

end

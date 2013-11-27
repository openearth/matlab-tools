function cosmos_updateScenariosDotXML(hm)
% Updates scenarios.xml file for all websites

% First find the website that are affected
k=0;
wb={''};
for m=1:hm.nrModels
    for iw=1:length(hm.models(m).webSite)
        ii=strmatch(hm.models(m).webSite(iw).name,wb,'exact');
        if isempty(ii)
            k=k+1;
            wb{k}=hm.models(m).webSite(iw).name;
        end
    end    
end

for iw=1:length(wb)

    wbdir=[hm.webDir wb{iw} filesep 'scenarios' filesep];
    fname=[wbdir 'scenarios.xml'];
    
    iUpdate=0;
    
    if exist(fname,'file')
        
        system(['TortoiseProc.exe /command:update /path:"' fname '" /closeonend:1']);

        scenarios=xml_load(fname);
%        scenarios=xml2struct(fname);
        
        ifound = 0;
        
        for i=1:length(scenarios)
            if strcmpi(scenarios(i).scenario.name,hm.scenario)
                ifound=i;
                break;
            end
        end
        
        if ifound==0
            % New scenarios
            ii=length(scenarios)+1;
            iUpdate=1;
        end
        
    else
        ii=1;
        iUpdate=1;
    end
    
    if iUpdate
        
        % Write scenarios.xml
        scenarios(ii).scenario=[];
        scenarios(ii).scenario.name=hm.scenarioShortName;
        scenarios(ii).scenario.type=hm.scenarioType;
        xml_save(fname,scenarios,'off');
        
        % Commit scenarios.xml
        system(['TortoiseProc.exe /command:commit /path:"' fname '" /logmsg:" scenarios.xml for website ' wb{iw} ' updated" /closeonend:1']);
        
        % Upload scenarios.xml
        if hm.uploadFTP
            fid=fopen('scp.txt','wt');
            fprintf(fid,'%s\n','option batch on');
            fprintf(fid,'%s\n','option confirm off');
            fprintf(fid,'%s\n','open cosmos:c0sm0sw3bs1t3@cosmos.deltares.nl -timeout=15 -hostkey="ssh-rsa 1024 cc:17:70:a2:d1:1e:ed:86:09:23:ea:2e:1c:3e:66:5e"');
            fprintf(fid,'%s\n',['cd ' wb{iw} '/scenarios']);
            fprintf(fid,'%s\n',['put ' fname]);
            fprintf(fid,'%s\n','close');
            fprintf(fid,'%s\n','exit');
            fclose(fid);
            system([hm.exeDir 'winscp.exe /console /script=scp.txt']);
            delete('scp.txt');
        end
        
    end
    
end

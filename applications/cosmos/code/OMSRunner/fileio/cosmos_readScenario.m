function hm=cosmos_readScenario(hm)

fname=[hm.MainDir filesep 'scenarios' filesep hm.Scenario filesep hm.Scenario '.xml'];

scn=xml_load(fname);

hm.RunEnv='win32';
hm.NumCores=1;

nh=24*(now-floor(now));
if nh>12
    hm.Cycle=floor(now)+0.5;
else
    hm.Cycle=floor(now);
end

hm.scenarioLongName=scn.longname;
hm.scenarioShortName=scn.shortname;

if ~strcmpi(hm.Scenario,'forecasts')
    hm.Cycle=datenum(scn.cycle,'yyyymmdd HHMMSS');
end
hm.RunInterval=str2double(scn.runinterval);
hm.RunTime=str2double(scn.runtime);
hm.CycleMode=scn.cyclemode;

txt=scn.getmeteodata;
if strcmpi(txt(1),'t')
    hm.GetMeteo=1;
else
    hm.GetMeteo=0;
end

txt=scn.getobsdata;
if strcmpi(txt(1),'t')
    hm.GetObservations=1;
else
    hm.GetObservations=0;
end

hm.GetOceanModel=0;
if isfield(scn,'getoceandata')
    txt=scn.getoceandata;
    if strcmpi(txt(1),'t')
        hm.GetOceanModel=1;
    end
end

if isfield(scn,'websites')
    for iw=1:length(scn.websites)
        hm.website(iw).name=scn.websites(iw).website.name;
        hm.website(iw).longitude=str2double(scn.websites(iw).website.longitude);
        hm.website(iw).latitude=str2double(scn.websites(iw).website.latitude);
        hm.website(iw).elevation=str2double(scn.websites(iw).website.elevation);
    end
end


% for i=1:length(txt)
% 
%     switch lower(txt{i})
%         case {'scenario'}
%             hm.scenarioLongName=txt{i+1};
%         case {'shortname'}
%             hm.scenarioShortName=txt{i+1};
%         case {'cycle'}
%             if ~strcmpi(hm.Scenario,'forecasts')                  
%                 hm.Cycle=datenum([txt{i+1} txt{i+2}],'yyyymmddHHMMSS');
%             end
%         case {'runinterval'}
%             hm.RunInterval=str2double(txt{i+1});
%         case {'runtime'}
%             hm.RunTime=str2double(txt{i+1});
%         case {'cyclemode'}
%             hm.CycleMode=txt{i+1};
%         case {'getmeteodata'}
%             if strcmpi(txt{i+1},'true')
%                 hm.GetMeteo=1;
%             else
%                 hm.GetMeteo=0;
%             end
%         case {'getobsdata'}
%             if strcmpi(txt{i+1},'true')
%                 hm.GetObservations=1;
%             else
%                 hm.GetObservations=0;
%             end
%         case {'runenv'}
%             Scenario.RunEnv=txt{i+1};
%     end
% end

function hm=cosmos_readScenario(hm)

fname=[hm.scenarioDir filesep hm.scenario '.xml'];

scn=xml_load(fname);

hm.runEnv='win32';
hm.numCores=1;

nh=24*(now-floor(now));
if nh>12
    hm.cycle=floor(now)+0.5;
else
    hm.cycle=floor(now);
end

hm.stoptime=hm.cycle+1000;

hm.scenarioLongName=scn.longname;
hm.scenarioShortName=scn.shortname;

hm.scenarioType='hindcast';
if isfield(scn,'type')
    hm.scenarioType=scn.type;
end

if isfield(scn,'cycle')
    hm.cycle=datenum(scn.cycle,'yyyymmdd HHMMSS');
end

hm.runInterval=str2double(scn.runinterval);
hm.runTime=str2double(scn.runtime);
hm.cycleMode=scn.cyclemode;

txt=scn.getmeteodata;
if strcmpi(txt(1),'t')
    hm.getMeteo=1;
else
    hm.getMeteo=0;
end

txt=scn.getobsdata;
if strcmpi(txt(1),'t')
    hm.getObservations=1;
else
    hm.getObservations=0;
end

hm.getOceanModel=0;
if isfield(scn,'getoceandata')
    txt=scn.getoceandata;
    if strcmpi(txt(1),'t')
        hm.getOceanModel=1;
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
%             if ~strcmpi(hm.scenario,'forecasts')                  
%                 hm.cycle=datenum([txt{i+1} txt{i+2}],'yyyymmddHHMMSS');
%             end
%         case {'runinterval'}
%             hm.runInterval=str2double(txt{i+1});
%         case {'runtime'}
%             hm.runTime=str2double(txt{i+1});
%         case {'cyclemode'}
%             hm.cycleMode=txt{i+1};
%         case {'getmeteodata'}
%             if strcmpi(txt{i+1},'true')
%                 hm.getMeteo=1;
%             else
%                 hm.getMeteo=0;
%             end
%         case {'getobsdata'}
%             if strcmpi(txt{i+1},'true')
%                 hm.getObservations=1;
%             else
%                 hm.getObservations=0;
%             end
%         case {'runenv'}
%             Scenario.runEnv=txt{i+1};
%     end
% end

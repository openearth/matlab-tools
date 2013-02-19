function hm=cosmos_readScenario(hm)

fname=[hm.scenarioDir filesep hm.scenario '.xml'];

%scn=xml_load(fname);

xml=xml2struct3(fname);

hm.runEnv='win32';
hm.numCores=1;

hm.archiveinput=0;
hm.archiveoutput=0;
hm.archivefigures=0;

nh=24*(now-floor(now));
if nh>12
    hm.cycle=floor(now)+0.5;
else
    hm.cycle=floor(now);
end

hm.stoptime=hm.cycle+1000;

hm.scenarioLongName=xml.longname;
hm.scenarioShortName=xml.shortname;

hm.scenarioType='hindcast';
if isfield(xml,'type')
    hm.scenarioType=xml.type;
end

if isfield(xml,'cycle')
    hm.cycle=datenum(xml.cycle,'yyyymmdd HHMMSS');
end

hm.runInterval=str2double(xml.runinterval);
hm.runTime=str2double(xml.runtime);
hm.cycleMode=xml.cyclemode;

txt=xml.getmeteodata;
if strcmpi(txt(1),'t')
    hm.getMeteo=1;
else
    hm.getMeteo=0;
end

txt=xml.getobsdata;
if strcmpi(txt(1),'t')
    hm.getObservations=1;
else
    hm.getObservations=0;
end

hm.getOceanModel=0;
if isfield(xml,'getoceandata')
    txt=xml.getoceandata;
    if strcmpi(txt(1),'t')
        hm.getOceanModel=1;
    end
end

nmdl=length(xml.model);
for im=1:nmdl
    hm.models(im).name=xml.model(im).model.name;
    hm.models(im).archiveinput=hm.archiveinput;
    hm.models(im).archiveoutput=hm.archiveoutput;
    hm.models(im).archivefigures=hm.archivefigures;    
    if isfield(xml.model(im).model,'archiveinput')
        switch xml.model(im).model.archiveinput(1)
            case{'y','t','1'}
                hm.models(im).archiveinput=1;
            otherwise
                hm.models(im).archiveinput=0;
        end
    end
    if isfield(xml.model(im).model,'archiveoutput')
        switch xml.model(im).model.archiveoutput(1)
            case{'y','t','1'}
                hm.models(im).archiveoutput=1;
            otherwise
                hm.models(im).archiveoutput=0;
        end
    end
    if isfield(xml.model(im).model,'archivefigures')
        switch xml.model(im).model.archivefigures(1)
            case{'y','t','1'}
                hm.models(im).archivefigures=1;
            otherwise
                hm.models(im).archivefigures=0;
        end
    end
end

if isfield(xml,'website')
    for iw=1:length(xml.website)
        hm.website(iw).name=xml.website(iw).website.name;
        hm.website(iw).longitude=str2double(xml.website(iw).website.longitude);
        hm.website(iw).latitude=str2double(xml.website(iw).website.latitude);
        hm.website(iw).elevation=str2double(xml.website(iw).website.elevation);
    end
end

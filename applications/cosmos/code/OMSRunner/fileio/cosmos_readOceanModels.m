function hm=cosmos_readOceanModels(hm)

s=xml_load([hm.dataDir 'oceanmodels' filesep 'OceanModels.xml']);
for i=1:length(s.models)
    hm.oceanModel(i).name = s.models(i).model.name;
    hm.oceanModel(i).longName = s.models(i).model.longname;
    hm.oceanModel(i).URL = s.models(i).model.url;
    hm.oceanModel(i).type = s.models(i).model.type;
    hm.oceanModel(i).delay = 8;
    hm.oceanModel(i).cycleInterval = 24;
    hm.oceanModel(i).xLim(1) = str2double(s.models(i).model.xlim1);
    hm.oceanModel(i).yLim(1) = str2double(s.models(i).model.ylim1);
    hm.oceanModel(i).xLim(2) = str2double(s.models(i).model.xlim2);
    hm.oceanModel(i).yLim(2) = str2double(s.models(i).model.ylim2);
    if isfield(s.models(i).model,'gridcoordinates')
        hm.oceanModel(i).gridCoordinates = s.models(i).model.gridcoordinates;
    else
        hm.oceanModel(i).gridCoordinates=[];
    end
    if isfield(s.models(i).model,'region')
        hm.oceanModel(i).region = s.models(i).model.region;
    else
        hm.oceanModel(i).region=[];
    end
    hm.oceanModels{i} = s.models(i).model.longname;
end

for i=1:length(hm.oceanModels)
    hm.oceanModel(i).tLastAnalyzed=rounddown(now-hm.oceanModel(i).delay/24,hm.oceanModel(i).cycleInterval/24);
end

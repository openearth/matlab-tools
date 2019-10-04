function [dims,start,count,order] = EHY_getmodeldata_optimiseDims(dims,modelType)

start=[];
count=[];

for iD=1:length(dims)
    dims(iD).sizeOut = length(dims(iD).index);
end

if strcmp(modelType,'dfm')
    % get indices
    timeInd     = strmatch('time'    ,{dims(:).name},'exact');
    stationsInd = strmatch('stations',{dims(:).name},'exact');
    layersInd   = strmatch('layers'  ,{dims(:).name},'exact');
    
    start = ones(1,numel(dims));
    count = [dims.size];
    
    % change 'time'-values to wanted indices
    if ~isempty(timeInd)
        % take OPT.tint into account
        start(timeInd) = dims(timeInd).index(1);
        count(timeInd) = dims(timeInd).index(end)-dims(timeInd).index(1)+1;
        dims(timeInd).index = dims(timeInd).index-dims(timeInd).index(1)+1;% needed to 'only keep requested indices'
    end
    
    % change 'layer'-values to wanted indices
    if ~isempty(layersInd)
        diffLayers=diff(dims(layersInd).index);
        if isempty(diffLayers) || all(diffLayers==1)
            start(layersInd) = dims(layersInd).index(1);
            count(layersInd) = dims(layersInd).index(end)-dims(layersInd).index(1)+1;
            dims(layersInd).index = dims(layersInd).index-dims(layersInd).index(1)+1;% needed to 'only keep requested indices'
        end
    end
    
    % change 'station'-values to wanted indices
    if ~isempty(stationsInd)
        diffStations=diff(dims(stationsInd).index);
        if isempty(diffStations) || all(diffStations==1)
            start(stationsInd) = dims(stationsInd).index(1);
            count(stationsInd) = dims(stationsInd).index(end)-dims(stationsInd).index(1)+1;
            dims(stationsInd).index = dims(stationsInd).index-dims(stationsInd).index(1)+1;% needed to 'only keep requested indices'
        end
    end
    
    if numel(dims)==1
        dims(end+1).name = '-';
        dims(end).nameOnFile = '-';
        dims(end).index = 1;
        dims(end).indexOut = 1;
    end
end

order = numel(dims):-1:1;
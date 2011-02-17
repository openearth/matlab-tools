function handles=ddb_readTideModels(handles)

if exist([handles.tideDir '\tidemodels.def'])==2
    txt=ReadTextFile([handles.tideDir '\tidemodels.def']);
else
    error(['Tidemodel defintion file ''' [handles.tideDir '\tidemodels.def'] ''' not found!']);
end

k=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'tidemodel'}
            k=k+1;
            handles.tideModels.longNames{k}=txt{i+1};
            handles.tideModels.nrModels=k;
            handles.tideModels.model(k).longName=txt{i+1};
            handles.tideModels.model(k).useCache=1;
        case{'name'}
            handles.tideModels.model(k).name=txt{i+1};
            handles.tideModels.names{k}=txt{i+1};
        case{'url'}
            handles.tideModels.model(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.tideModels.model(k).useCache=1;
            else
                handles.tideModels.model(k).useCache=0;
            end
    end
end

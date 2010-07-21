function handles=ddb_readTideModels(handles)

txt=ReadTextFile([handles.TideDir '\tidemodels.def']);

k=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'tidemodel'}
            k=k+1;
            handles.TideModels.longName{k}=txt{i+1};
            handles.TideModels.nrModels=k;
            handles.TideModels.Model(k).longName=txt{i+1};
            handles.TideModels.Model(k).useCache=1;
        case{'name'}
            handles.TideModels.Model(k).Name=txt{i+1};
            handles.TideModels.Name{k}=txt{i+1};
        case{'url'}
            handles.TideModels.Model(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.TideModels.Model(k).useCache=1;
            else
                handles.TideModels.Model(k).useCache=0;
            end
    end
end

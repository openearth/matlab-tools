function handles=ddb_readShorelines(handles)

if exist([handles.ShorelineDir '\Shorelines.def'])==2
    txt=ReadTextFile([handles.ShorelineDir '\Shorelines.def']);
else
    error(['Shorelines defintion file ''' [handles.ShorelineDir '\Shorelines.def'] ''' not found!']);
end

k=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'shoreline'}
            k=k+1;
            handles.Shorelines.longName{k}=txt{i+1};
            handles.Shorelines.nrShorelines=k;
            handles.Shorelines.Shoreline(k).longName=txt{i+1};
            handles.Shorelines.Shoreline(k).useCache=1;
        case{'name'}
            handles.Shorelines.Shoreline(k).Name=txt{i+1};
            handles.Shorelines.Name{k}=txt{i+1};
        case{'type'}
            handles.Shorelines.Shoreline(k).Type=txt{i+1};
        case{'url'}
            handles.Shorelines.Shoreline(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.Shorelines.Shoreline(k).useCache=1;
            else
                handles.Shorelines.Shoreline(k).useCache=0;
            end
    end
end

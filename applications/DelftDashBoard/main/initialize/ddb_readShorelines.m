function handles=ddb_readShorelines(handles)

if exist([handles.shorelineDir '\Shorelines.def'])==2
    txt=ReadTextFile([handles.shorelineDir '\Shorelines.def']);
else
    error(['Shorelines defintion file ''' [handles.shorelineDir '\Shorelines.def'] ''' not found!']);
end

k=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'shoreline'}
            k=k+1;
            handles.shorelines.longName{k}=txt{i+1};
            handles.shorelines.nrShorelines=k;
            handles.shorelines.shoreline(k).longName=txt{i+1};
            handles.shorelines.shoreline(k).useCache=1;
        case{'name'}
            handles.shorelines.shoreline(k).name=txt{i+1};
            handles.shorelines.name{k}=txt{i+1};
        case{'type'}
            handles.shorelines.shoreline(k).type=txt{i+1};
        case{'url'}
            handles.shorelines.shoreline(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.shorelines.shoreline(k).useCache=1;
            else
                handles.shorelines.shoreline(k).useCache=0;
            end
    end
end

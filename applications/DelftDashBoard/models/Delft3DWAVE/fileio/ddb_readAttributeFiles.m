function handles=ddb_readAttributeFiles(handles)

id=handles.ActiveDomain;

if ~isempty(handles.Model(md).Input(id).GrdFile)
    [x,y,enc]=wlgrid('read',[handles.WorkingDirectory filesep handles.Model(md).Input(id).GrdFile]);
    handles.Model(md).Input(id).GridX=x;
    handles.Model(md).Input(id).GridY=y;
    [handles.Model(md).Input(id).GridXZ,handles.Model(md).Input(id).GridYZ]=GetXZYZ(x,y);
    handles=ddb_determineKCS(handles);
    if ~isempty(handles.Model(md).Input(id).EncFile)
        mn=ddb_enclosure('read',[handles.WorkingDirectory filesep handles.Model(md).Input(id).EncFile]);
        [handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY);
    end
    nans=zeros(size(handles.Model(md).Input(id).GridX));
    nans(nans==0)=NaN;
    handles.Model(md).Input(id).Depth=nans;
    handles.Model(md).Input(id).DepthZ=nans;
end
if ~isempty(handles.Model(md).Input(id).DepFile)
    mmax=handles.Model(md).Input(id).MMax;
    nmax=handles.Model(md).Input(id).NMax;
    dp=wldep('read',[handles.WorkingDirectory filesep handles.Model(md).Input(id).DepFile],[mmax nmax]);
    handles.Model(md).Input(id).Depth=-dp(1:end-1,1:end-1);
    handles.Model(md).Input(id).DepthZ=GetDepthZ(handles.Model(md).Input(id).Depth,handles.Model(md).Input(id).DpsOpt);
end
if ~isempty(handles.Model(md).Input(id).BndFile)
    handles=ddb_readBndFile(handles);
    handles=ddb_sortBoundaries(handles,id);
end

% ddb_initialize Tracers and Sediment
for i=1:handles.Model(md).Input(id).NrTracers
    handles=ddb_initializeTracer(handles,i);
end
for i=1:handles.Model(md).Input(id).NrSediments
    handles=ddb_initializeSediment(handles,i);
end

if ~isempty(handles.Model(md).Input(id).BcaFile)
    handles=ddb_readBcaFile(handles);
end
if ~isempty(handles.Model(md).Input(id).CorFile)
    handles=ddb_readCorFile(handles);
end
if ~isempty(handles.Model(md).Input(id).BctFile)
    handles=ddb_readBctFile(handles);
end
if ~isempty(handles.Model(md).Input(id).BchFile)
    handles=ddb_readBchFile(handles);
end
if ~isempty(handles.Model(md).Input(id).BcqFile)
    handles=ReadBcqFile(handles);
end
if ~isempty(handles.Model(md).Input(id).BccFile)
    handles=ddb_readBccFile(handles);
end
if ~isempty(handles.Model(md).Input(id).ObsFile)
    handles=ddb_readObsFile(handles);
end
if ~isempty(handles.Model(md).Input(id).CrsFile)
    handles=ddb_readCrsFile(handles);
end
if ~isempty(handles.Model(md).Input(id).DryFile)
    handles=ddb_readDryFile(handles);
end
if ~isempty(handles.Model(md).Input(id).ThdFile)
    handles=ddb_readThdFile(handles);
end
if ~isempty(handles.Model(md).Input(id).SrcFile)
    handles=ddb_readSrcFile(handles,id);
    if ~isempty(handles.Model(md).Input(id).DisFile)
        handles=ddb_readDisFile(handles,id);
    end
end


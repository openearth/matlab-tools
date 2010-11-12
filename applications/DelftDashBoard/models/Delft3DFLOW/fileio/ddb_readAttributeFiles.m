function handles=ddb_readAttributeFiles(handles)

if ~isempty(handles.Model(md).Input(ad).GrdFile)
    [x,y,enc]=ddb_wlgrid('read',[handles.Model(md).Input(ad).GrdFile]);
    handles.Model(md).Input(ad).GridX=x;
    handles.Model(md).Input(ad).GridY=y;
    [handles.Model(md).Input(ad).GridXZ,handles.Model(md).Input(ad).GridYZ]=GetXZYZ(x,y);
    handles=ddb_determineKCS(handles);
    if ~isempty(handles.Model(md).Input(ad).EncFile)
        mn=ddb_enclosure('read',[handles.Model(md).Input(ad).EncFile]);
        [handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
    end
    nans=zeros(size(handles.Model(md).Input(ad).GridX));
    nans(nans==0)=NaN;
    handles.Model(md).Input(ad).Depth=nans;
    handles.Model(md).Input(ad).DepthZ=nans;
end
if ~isempty(handles.Model(md).Input(ad).DepFile)
    mmax=handles.Model(md).Input(ad).MMax;
    nmax=handles.Model(md).Input(ad).NMax;
    dp=ddb_wldep('read',handles.Model(md).Input(ad).DepFile,[mmax nmax]);
    handles.Model(md).Input(ad).Depth=-dp(1:end-1,1:end-1);
    handles.Model(md).Input(ad).DepthZ=GetDepthZ(handles.Model(md).Input(ad).Depth,handles.Model(md).Input(ad).DpsOpt);
end
if ~isempty(handles.Model(md).Input(ad).BndFile)
    handles=ddb_readBndFile(handles);
    handles=ddb_sortBoundaries(handles,ad);
end

% ddb_initialize Tracers and Sediment
for i=1:handles.Model(md).Input(ad).NrTracers
    handles=ddb_initializeTracer(handles,i);
end
for i=1:handles.Model(md).Input(ad).NrSediments
    handles=ddb_initializeSediment(handles,i);
end

if ~isempty(handles.Model(md).Input(ad).BcaFile)
    handles=ddb_readBcaFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).CorFile)
    handles=ddb_readCorFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).BctFile)
    handles=ddb_readBctFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).BchFile)
    handles=ddb_readBchFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).BcqFile)
    handles=ReadBcqFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).BccFile)
    handles=ddb_readBccFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).ObsFile)
    handles=ddb_readObsFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).CrsFile)
    handles=ddb_readCrsFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).DroFile)
    handles=ddb_readDroFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).DryFile)
    handles=ddb_readDryFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).ThdFile)
    handles=ddb_readThdFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).WndFile)
    handles=ddb_readWndFile(handles,ad);
end
if ~isempty(handles.Model(md).Input(ad).SrcFile)
    handles=ddb_readSrcFile(handles,ad);
    if ~isempty(handles.Model(md).Input(ad).DisFile)
        handles=ddb_readDisFile(handles,ad);
    end
end


function handles=ddb_readAttributeFiles(handles)

if ~isempty(handles.Model(md).Input(ad).grdFile)
    [x,y,enc]=ddb_wlgrid('read',[handles.Model(md).Input(ad).grdFile]);
    handles.Model(md).Input(ad).gridX=x;
    handles.Model(md).Input(ad).gridY=y;
    [handles.Model(md).Input(ad).gridXZ,handles.Model(md).Input(ad).gridYZ]=GetXZYZ(x,y);
    handles=ddb_determineKCS(handles);
    if ~isempty(handles.Model(md).Input(ad).encFile)
        mn=ddb_enclosure('read',[handles.Model(md).Input(ad).encFile]);
        [handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
    end
    nans=zeros(size(handles.Model(md).Input(ad).gridX));
    nans(nans==0)=NaN;
    handles.Model(md).Input(ad).depth=nans;
    handles.Model(md).Input(ad).depthZ=nans;
end
if ~isempty(handles.Model(md).Input(ad).depFile)
    mmax=handles.Model(md).Input(ad).MMax;
    nmax=handles.Model(md).Input(ad).NMax;
    dp=ddb_wldep('read',handles.Model(md).Input(ad).depFile,[mmax nmax]);
    handles.Model(md).Input(ad).depth=-dp(1:end-1,1:end-1);
    handles.Model(md).Input(ad).depthZ=GetDepthZ(handles.Model(md).Input(ad).depth,handles.Model(md).Input(ad).dpsOpt);
end
if ~isempty(handles.Model(md).Input(ad).bndFile)
    handles=ddb_readBndFile(handles,ad);
    handles=ddb_sortBoundaries(handles,ad);
end

% ddb_initialize Tracers and Sediment
for i=1:handles.Model(md).Input(ad).nrTracers
    handles=ddb_initializeTracer(handles,i);
end

% Initialize sediment
for i=1:handles.Model(md).Input(ad).nrSediments
    handles=ddb_initializeSediment(handles,ad,i);
end

if ~isempty(handles.Model(md).Input(ad).bcaFile)
    handles=ddb_readBcaFile(handles,ad);
end
if ~isempty(handles.Model(md).Input(ad).corFile)
    handles=ddb_readCorFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).bctFile)
    handles=ddb_readBctFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).bchFile)
    handles=ddb_readBchFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).bcqFile)
    handles=ReadBcqFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).bccFile)
    handles=ddb_readBccFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).obsFile)
    handles=ddb_readObsFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).crsFile)
    handles=ddb_readCrsFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).droFile)
    handles=ddb_readDroFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).dryFile)
    handles=ddb_readDryFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).thdFile)
    handles=ddb_readThdFile(handles);
end
if ~isempty(handles.Model(md).Input(ad).wndFile)
    handles=ddb_readWndFile(handles,ad);
end
if ~isempty(handles.Model(md).Input(ad).srcFile)
    handles=ddb_readSrcFile(handles,ad);
    if ~isempty(handles.Model(md).Input(ad).disFile)
        handles=ddb_readDisFile(handles,ad);
    end
end
if handles.Model(md).Input(ad).sediments.include
    handles=ddb_readSedFile(handles,ad);
    handles=ddb_readMorFile(handles,ad);
end

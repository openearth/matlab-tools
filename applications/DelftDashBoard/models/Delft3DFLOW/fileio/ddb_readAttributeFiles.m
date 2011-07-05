function handles=ddb_readAttributeFiles(handles,id)

if ~isempty(handles.Model(md).Input(id).grdFile)
    [x,y,enc]=ddb_wlgrid('read',[handles.Model(md).Input(id).grdFile]);
    handles.Model(md).Input(id).gridX=x;
    handles.Model(md).Input(id).gridY=y;
    [handles.Model(md).Input(id).gridXZ,handles.Model(md).Input(id).gridYZ]=getXZYZ(x,y);
    handles.Model(md).Input(id).kcs=determineKCS(handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY);
    if ~isempty(handles.Model(md).Input(id).encFile)
        mn=ddb_enclosure('read',[handles.Model(md).Input(id).encFile]);
        [handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY);
    end
    nans=zeros(size(handles.Model(md).Input(id).gridX));
    nans(nans==0)=NaN;
    handles.Model(md).Input(id).depth=nans;
    handles.Model(md).Input(id).depthZ=nans;
end
if ~isempty(handles.Model(md).Input(id).depFile)
    mmax=handles.Model(md).Input(id).MMax;
    nmax=handles.Model(md).Input(id).NMax;
    dp=ddb_wldep('read',handles.Model(md).Input(id).depFile,[mmax nmax]);
    handles.Model(md).Input(id).depth=-dp(1:end-1,1:end-1);
    handles.Model(md).Input(id).depthZ=GetDepthZ(handles.Model(md).Input(id).depth,handles.Model(md).Input(id).dpsOpt);
end
if ~isempty(handles.Model(md).Input(id).bndFile)
    handles=ddb_readBndFile(handles,id);
    handles=ddb_sortBoundaries(handles,id);
end

% ddb_initialize Tracers and Sediment
for i=1:handles.Model(md).Input(id).nrTracers
    handles=ddb_initializeTracer(handles,i);
end

% Initialize sediment
for i=1:handles.Model(md).Input(id).nrSediments
    handles=ddb_initializeSediment(handles,id,i);
end

if ~isempty(handles.Model(md).Input(id).bcaFile)
    handles=ddb_readBcaFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).corFile)
    handles=ddb_readCorFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).bctFile)
    handles=ddb_readBctFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).bchFile)
    handles=ddb_readBchFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).bcqFile)
    handles=ReadBcqFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).bccFile)
    handles=ddb_readBccFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).obsFile)
    handles=ddb_readObsFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).crsFile)
    handles=ddb_readCrsFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).droFile)
    handles=ddb_readDroFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).dryFile)
    handles=ddb_readDryFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).thdFile)
    handles=ddb_readThdFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).wndFile)
    handles=ddb_readWndFile(handles,id);
end
if ~isempty(handles.Model(md).Input(id).srcFile)
    handles=ddb_readSrcFile(handles,id);
    if ~isempty(handles.Model(md).Input(id).disFile)
        handles=ddb_readDisFile(handles,id);
    end
end
if handles.Model(md).Input(id).sediments.include
    handles=ddb_readSedFile(handles,id);
    handles=ddb_readMorFile(handles,id);
end

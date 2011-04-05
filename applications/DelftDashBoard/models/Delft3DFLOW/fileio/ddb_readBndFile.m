function handles=ddb_readBndFile(handles,id)

handles.Model(md).Input(id).openBoundaryNames=[];

% Set some values for initializing (Dashboard specific)
t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;
nrsed=handles.Model(md).Input(id).nrSediments;
nrtrac=handles.Model(md).Input(id).nrTracers;
nrharmo=handles.Model(md).Input(id).nrHarmonicComponents;
x=handles.Model(md).Input(id).gridX;
y=handles.Model(md).Input(id).gridY;
z=handles.Model(md).Input(id).depthZ;
kcs=handles.Model(md).Input(id).kcs;

% Read boundaries into structure
openBoundaries=delft3dflow_readBndFile(handles.Model(md).Input(id).bndFile);

% Initialize individual boundary sections
for i=1:length(openBoundaries)
    openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,i,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs);
end

% Copy open boundaries to Dashboard structure
handles.Model(md).Input(id).openBoundaries=openBoundaries;
handles.Model(md).Input(id).nrOpenBoundaries=length(openBoundaries);

for i=1:length(openBoundaries)
    handles.Model(md).Input(id).openBoundaryNames{i}=openBoundaries(i).name;
end

% Count number of harmonic, time series etc.
handles=ddb_countOpenBoundaries(handles,id);

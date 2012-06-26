function handles=ddb_readMDW(handles,filename)

MDW = ddb_readDelft3D_keyWordFile(filename);

handles.Model(md).Input.activedomain=1;

handles.Model(md).Input.referencedate=floor(now);

%% General
fldnames=fieldnames(MDW.general);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.general.(fldnames{ii});
end

%% Constants
fldnames=fieldnames(MDW.constants);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.constants.(fldnames{ii});
end

%% Processes
fldnames=fieldnames(MDW.processes);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.processes.(fldnames{ii});
end

%% Numerics
fldnames=fieldnames(MDW.numerics);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.numerics.(fldnames{ii});
end

%% Output
fldnames=fieldnames(MDW.output);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.output.(fldnames{ii});
end

%% Domains
ndomains=length(MDW.domain);
handles.Model(md).Input.gridnames={''};
handles.Model(md).Input.nrdomains=ndomains;
handles.Model(md).Input.domains=[];
for id=1:ndomains
    handles.Model(md).Input.domains=ddb_initializeDelft3DWAVEDomain(handles.Model(md).Input.domains,id);
    fldnames=fieldnames(MDW.domain(id));
    for ii=1:length(fldnames)
        handles.Model(md).Input.domains(id).(fldnames{ii})=MDW.domain(id).(fldnames{ii});
    end
    handles.Model(md).Input.gridnames{id}=handles.Model(md).Input.domains(id).grid(1:end-4);
end

%% Boundaries
nbnd=length(MDW.boundary);
handles.Model(md).Input.nrboundaries=nbnd;
handles.Model(md).Input.boundaries=[];
for ib=1:nbnd
    handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,ib);
    fldnames=fieldnames(MDW.boundary(ib));
    for ii=1:length(fldnames)
        handles.Model(md).Input.boundaries(ib).(fldnames{ii})=MDW.boundary(ib).(fldnames{ii});
    end
    handles.Model(md).Input.boundarynames{ib}=handles.Model(md).Input.boundaries(ib).name;
end

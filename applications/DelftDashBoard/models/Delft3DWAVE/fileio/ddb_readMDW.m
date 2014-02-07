function handles=ddb_readMDW(handles,filename)

MDW = ddb_readDelft3D_keyWordFile(filename);

handles.Model(md).Input.activedomain=1;

handles.Model(md).Input.referencedate=floor(now);

%% General
fldnames=fieldnames(MDW.general);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.general.(fldnames{ii});
end
handles.Model(md).Input.referencedate=datenum(handles.Model(md).Input.referencedate);
handles.Model(md).Input.timepoint=handles.Model(md).Input.referencedate+handles.Model(md).Input.timepoint/1440.0;

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
switch lower(handles.Model(md).Input.bedfriction)
    case{'jonswap'}
        handles.Model(md).Input.bedfriccoefjonswap=handles.Model(md).Input.bedfriccoef;
    case{'collins'}
        handles.Model(md).Input.bedfriccoefcollins=handles.Model(md).Input.bedfriccoef;
    case{'madsen et al.'}
        handles.Model(md).Input.bedfriccoefmadsen=handles.Model(md).Input.bedfriccoef;
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
if ~iscell(handles.Model(md).Input.locationfile)
    v=handles.Model(md).Input.locationfile;
    if ~isempty(v)
        handles.Model(md).Input.locationfile=[];
        handles.Model(md).Input.locationfile{1}=v;
    end
end


%% Domains
ndomains=length(MDW.domain);
handles.Model(md).Input.gridnames={''};
handles.Model(md).Input.nrdomains=ndomains;
handles.Model(md).Input.domains=[];
handles.Model(md).Input.nrgrids=ndomains;
for id=1:ndomains
    handles.Model(md).Input.domains=ddb_initializeDelft3DWAVEDomain(handles.Model(md).Input.domains,id);
    fldnames=fieldnames(MDW.domain(id));
    for ii=1:length(fldnames)
        handles.Model(md).Input.domains(id).(fldnames{ii})=MDW.domain(id).(fldnames{ii});
    end
    handles.Model(md).Input.domains(id).gridname=handles.Model(md).Input.domains(id).grid(1:end-4);
    handles.Model(md).Input.gridnames{id}=handles.Model(md).Input.domains(id).grid(1:end-4);
end
handles = ddb_Delft3DWAVE_setNestGrids(handles);
for id=1:ndomains
    if isfield(handles.Model(md).Input.domains(id),'nestedindomain')
        if ~isempty(handles.Model(md).Input.domains(id).nestedindomain)
            handles.Model(md).Input.domains(id).nestgrid=handles.Model(md).Input.gridnames{handles.Model(md).Input.domains(id).nestedindomain};
        end
    end
end

%% Boundaries
if isfield(MDW,'boundary')
    nbnd=length(MDW.boundary);
    handles.Model(md).Input.nrboundaries=nbnd;
    handles.Model(md).Input.boundaries=[];
    for ib=1:nbnd
        handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,ib);
        fldnames=fieldnames(MDW.boundary(ib));
        for ii=1:length(fldnames)
            if ~iscell(MDW.boundary(ib).(fldnames{ii}))
                handles.Model(md).Input.boundaries(ib).(fldnames{ii})=MDW.boundary(ib).(fldnames{ii});
            end
        end
        handles.Model(md).Input.boundarynames{ib}=handles.Model(md).Input.boundaries(ib).name;
        if isfield(MDW.boundary(ib),'waveheight')
            if iscell(MDW.boundary(ib).waveheight)
                handles.Model(md).Input.boundaries(ib).alongboundary='varying';
                handles.Model(md).Input.boundaries(ib).nrsegments=length(MDW.boundary(ib).waveheight);
                for iseg=1:handles.Model(md).Input.boundaries(ib).nrsegments
                    handles.Model(md).Input.boundaries(ib).segmentnames{iseg}=['Segment ' num2str(iseg)];
                    handles.Model(md).Input.boundaries(ib).segments(iseg).waveheight=MDW.boundary(ib).waveheight{iseg};
                    handles.Model(md).Input.boundaries(ib).segments(iseg).condspecatdist=MDW.boundary(ib).condspecatdist{iseg};
                    handles.Model(md).Input.boundaries(ib).segments(iseg).period=MDW.boundary(ib).period{iseg};
                    handles.Model(md).Input.boundaries(ib).segments(iseg).direction=MDW.boundary(ib).direction{iseg};
                    handles.Model(md).Input.boundaries(ib).segments(iseg).dirspreading=MDW.boundary(ib).dirspreading{iseg};
                end
            end
        end
    end
end

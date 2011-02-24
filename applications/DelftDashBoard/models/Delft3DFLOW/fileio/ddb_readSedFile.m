function handles=ddb_readSedFile(handles,id)

s=ddb_readDelft3D_keyWordFile(handles.Model(md).Input(id).sedFile);

handles.Model(md).Input(id).nrSediments=length(s.sediment);

handles.Model(md).Input(id).sediment=[];

handles.Model(md).Input(id).sediments.include=1;
handles.Model(md).Input(id).sediments.cRef=1600;
handles.Model(md).Input(id).sediments.iOpSus=0;
handles.Model(md).Input(id).sediments.sedimentNames={''};
handles.Model(md).Input(id).sediments.activeSediment=1;

if isfield(s.sedimentoverall,'cref')
    handles.Model(md).Input(id).sediments.cRef=s.sedimentoverall.cref;
end
if isfield(s.sedimentoverall,'iopsus')
    handles.Model(md).Input(id).sediments.iOpSus=s.sedimentoverall.iopsus;
end

for i=1:handles.Model(md).Input(id).nrSediments

    handles.Model(md).Input(id).sediment(i).type=s.sediment(i).sedtyp;
    handles.Model(md).Input(id).sediment(i).name=s.sediment(i).name;

    handles.Model(md).Input(id).sediments.sedimentNames{i}=handles.Model(md).Input(id).sediment(i).name;
    
    handles=ddb_initializeSediment(handles,id,i);
    
    
    if isfield(s.sediment(i),'rhosol')
        handles.Model(md).Input(id).sediment(i).rhoSol=s.sediment(i).rhosol;
    end
    if isfield(s.sediment(i),'cdryb')
        handles.Model(md).Input(id).sediment(i).cDryB=s.sediment(i).cdryb;
    end
    if isfield(s.sediment(i),'inisedthick')
        if ischar(s.sediment(i).inisedthick)
            handles.Model(md).Input(id).sediment(i).uniformThickness=0;
            handles.Model(md).Input(id).sediment(i).sdbFile=s.sediment(i).inisedthick;
        else
            handles.Model(md).Input(id).sediment(i).uniformThickness=1;
            handles.Model(md).Input(id).sediment(i).iniSedThick=s.sediment(i).inisedthick;
        end
    end
    if isfield(s.sediment(i),'facdss')
        handles.Model(md).Input(id).sediment(i).facDSS=s.sediment(i).facdss;
    end
    
    
    switch lower(s.sediment(i).sedtyp)
        case{'sand'}
            handles.Model(md).Input(id).sediment(i).type='non-cohesive';
            if isfield(s.sediment(i),'seddia')
                handles.Model(md).Input(id).sediment(i).sedDia=s.sediment(i).seddia;
            end
            if isfield(s.sediment(i),'sedd10')
                handles.Model(md).Input(id).sediment(i).sedD10=s.sediment(i).sedd10;
            end
            if isfield(s.sediment(i),'sedd90')
                handles.Model(md).Input(id).sediment(i).sedD90=s.sediment(i).sedd90;
            end
        case{'mud'}
            handles.Model(md).Input(id).sediment(i).type='non-cohesive';
            if isfield(s.sediment(i),'salmax')
                handles.Model(md).Input(id).sediment(i).salMax=s.sediment(i).salmax;
            end
            if isfield(s.sediment(i),'ws0')
                handles.Model(md).Input(id).sediment(i).wS0=s.sediment(i).ws0;
            end
            if isfield(s.sediment(i),'wsm')
                handles.Model(md).Input(id).sediment(i).wSM=s.sediment(i).wsm;
            end
            
            if isfield(s.sediment(i),'eropar')
                if ischar(s.sediment(i).eropar)
                    handles.Model(md).Input(id).sediment(i).uniformEroPar=0;
                    handles.Model(md).Input(id).sediment(i).eroFile=s.sediment(i).eropar;
                else
                    handles.Model(md).Input(id).sediment(i).uniformEroPar=1;
                    handles.Model(md).Input(id).sediment(i).eroPar=s.sediment(i).eropar;
                end
            end
            
            if isfield(s.sediment(i),'tcrsed')
                if ischar(s.sediment(i).tcrsed)
                    handles.Model(md).Input(id).sediment(i).uniformTCrSed=0;
                    handles.Model(md).Input(id).sediment(i).tcdFile=s.sediment(i).tcrsed;
                else
                    handles.Model(md).Input(id).sediment(i).uniformTCrSed=1;
                    handles.Model(md).Input(id).sediment(i).tCrSed=s.sediment(i).tcrsed;
                end
            end
            
            if isfield(s.sediment(i),'tcrero')
                if ischar(s.sediment(i).tcrero)
                    handles.Model(md).Input(id).sediment(i).uniformTCrEro=0;
                    handles.Model(md).Input(id).sediment(i).tceFile=s.sediment(i).tcrero;
                else
                    handles.Model(md).Input(id).sediment(i).uniformTCrEro=1;
                    handles.Model(md).Input(id).sediment(i).tCrEro=s.sediment(i).tcrero;
                end
            end
            
    end
end

function handles=ddb_readMorFile(handles,id)
% Reads Delft3D mor file into structure

s=ddb_readDelft3D_keyWordFile(handles.Model(md).Input(id).morFile);

handles=ddb_Delft3DFLOW_initializeMorphology(handles,id);

if isfield(s.morphology,'epspar')
    handles.Model(md).Input(id).morphology.epsPar=s.morphology.epspar;
end
if isfield(s.morphology,'iopkcw')
    handles.Model(md).Input(id).morphology.iOpKcw=s.morphology.iopkcw;
end
if isfield(s.morphology,'rdc')
    handles.Model(md).Input(id).morphology.rdc=s.morphology.rdc;
end
if isfield(s.morphology,'rdw')
    handles.Model(md).Input(id).morphology.rdw=s.morphology.rdw;
end
if isfield(s.morphology,'morfac')
    handles.Model(md).Input(id).morphology.morFac=s.morphology.morfac;
end
if isfield(s.morphology,'morstt')
    handles.Model(md).Input(id).morphology.morStt=s.morphology.morstt;
end
if isfield(s.morphology,'thresh')
    handles.Model(md).Input(id).morphology.thresh=s.morphology.thresh;
end
if isfield(s.morphology,'morupd')
    handles.Model(md).Input(id).morphology.morUpd=s.morphology.morupd;
end
if isfield(s.morphology,'eqmbc')
    handles.Model(md).Input(id).morphology.eqmBc=s.morphology.eqmbc;
end
if isfield(s.morphology,'densin')
    handles.Model(md).Input(id).morphology.densIn=s.morphology.densin;
end
if isfield(s.morphology,'aksfac')
    handles.Model(md).Input(id).morphology.aksFac=s.morphology.aksfac;
end
if isfield(s.morphology,'rwave')
    handles.Model(md).Input(id).morphology.rWave=s.morphology.rwave;
end
if isfield(s.morphology,'alfabs')
    handles.Model(md).Input(id).morphology.alphaBs=s.morphology.alfabs;
end
if isfield(s.morphology,'alfabn')
    handles.Model(md).Input(id).morphology.alphaBn=s.morphology.alfabn;
end
if isfield(s.morphology,'sus')
    handles.Model(md).Input(id).morphology.sus=s.morphology.sus;
end
if isfield(s.morphology,'bed')
    handles.Model(md).Input(id).morphology.bed=s.morphology.bed;
end
if isfield(s.morphology,'susw')
    handles.Model(md).Input(id).morphology.susW=s.morphology.susw;
end
if isfield(s.morphology,'bedw')
    handles.Model(md).Input(id).morphology.bedW=s.morphology.bedw;
end
if isfield(s.morphology,'sedthr')
    handles.Model(md).Input(id).morphology.sedThr=s.morphology.sedthr;
end
if isfield(s.morphology,'thetsd')
    handles.Model(md).Input(id).morphology.thetSd=s.morphology.thetsd;
end
if isfield(s.morphology,'hmaxth')
    handles.Model(md).Input(id).morphology.hMaxTh=s.morphology.hmaxth;
end
if isfield(s.morphology,'fwfac')
    handles.Model(md).Input(id).morphology.fwFac=s.morphology.fwfac;
end

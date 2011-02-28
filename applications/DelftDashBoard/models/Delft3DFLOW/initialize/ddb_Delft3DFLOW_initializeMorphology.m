function handles=ddb_Delft3DFLOW_initializeMorphology(handles,id)
% Initializes Delft3D-FLOW morphology

handles.Model(md).Input(id).morphology=[];

handles.Model(md).Input(id).morphology.morUpd=1;
handles.Model(md).Input(id).morphology.densIn=0;
handles.Model(md).Input(id).morphology.eqmBc=1;
handles.Model(md).Input(id).morphology.morFac=1;
handles.Model(md).Input(id).morphology.morStt=720;
handles.Model(md).Input(id).morphology.thresh=0.05;
handles.Model(md).Input(id).morphology.sedThr=0.1;
handles.Model(md).Input(id).morphology.thetSd=0.1;
handles.Model(md).Input(id).morphology.sus=1.0;
handles.Model(md).Input(id).morphology.bed=1.0;
handles.Model(md).Input(id).morphology.susW=1.0;
handles.Model(md).Input(id).morphology.bedW=1.0;
handles.Model(md).Input(id).morphology.iOpKcw = 1;
handles.Model(md).Input(id).morphology.epsPar = 0;
handles.Model(md).Input(id).morphology.rdc = 0.01;
handles.Model(md).Input(id).morphology.rdw = 0.02;
handles.Model(md).Input(id).morphology.aksFac = 1;
handles.Model(md).Input(id).morphology.rWave = 2;
handles.Model(md).Input(id).morphology.alphaBs = 1.0;
handles.Model(md).Input(id).morphology.alphaBn = 1.5;
handles.Model(md).Input(id).morphology.hMaxTh = 1.5;
handles.Model(md).Input(id).morphology.fwFac = 1.0;

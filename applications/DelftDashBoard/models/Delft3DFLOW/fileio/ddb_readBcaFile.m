function handles=ddb_readBcaFile(handles,id)
% Reads bca file and stores component sets in DDB structure

fname=handles.Model(md).Input(id).bcaFile;
handles.Model(md).Input(id).astronomicComponentSets=delft3dflow_readBcaFile(fname);
handles.Model(md).Input(id).nrAstronomicComponentSets=length(handles.Model(md).Input(id).astronomicComponentSets);

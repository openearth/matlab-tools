function handles=ddb_readWndFile(handles,id)

fname=handles.Model(md).Input(id).WndFile;
handles.Model(md).Input(id).WindData=load(fname);

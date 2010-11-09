function handles=ddb_readLTR(handles,filename)

LTR=ddb_readLTRText(filename);

handles.Model(md).Input.NumberofClimates=LTR.NumberofClimates;
handles.Model(md).Input.ORKSTfile=LTR.ORKST;
handles.Model(md).Input.PROFHfile=LTR.PROFH;
handles.Model(md).Input.PROfile=LTR.PRO;
handles.Model(md).Input.CFSfile=LTR.CFS;
handles.Model(md).Input.CFEfile=LTR.CFE;
handles.Model(md).Input.SCOfile=LTR.SCO;
handles.Model(md).Input.RAYfile=LTR.RAY;
handles.Model(md).Input.MDAfile=LTR.MDA;

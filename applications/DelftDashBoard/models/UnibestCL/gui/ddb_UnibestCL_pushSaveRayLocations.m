function ddb_UnibestCL_pushSaveRayLocations(varargin)

handles=getHandles;

RAYlocfile = handles.Model(md).Input.RAYlocfile;
RAYlocdata = handles.Model(md).Input.RAYlocdata;
ddb_writeRAYloc(RAYlocfile,RAYlocdata);



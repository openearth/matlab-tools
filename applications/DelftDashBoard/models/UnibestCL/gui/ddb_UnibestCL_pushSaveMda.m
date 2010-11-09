function ddb_UnibestCL_pushSaveMda(varargin)

handles=getHandles;

MDAfile = handles.Model(md).Input.MDAfile;
MDAdata = handles.Model(md).Input.MDAdata;
reference_line = [MDAdata.X MDAdata.Y];
writeMDA2(MDAfile,reference_line,MDAdata.Y1,MDAdata.Y2,MDAdata.nrgridcells);



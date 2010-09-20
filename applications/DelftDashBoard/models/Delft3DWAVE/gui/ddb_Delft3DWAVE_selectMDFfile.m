function ddb_Delft3DWAVE_selectMDFfile

handles=getHandles;

filename=handles.Model(md).Input.MDFFile;
MDF=ddb_readMDFText(filename);
ItDate=datenum(MDF.Itdate,'yyyy-mm-dd');
ComStartTime=ItDate+MDF.Flpp(1)/1440;
ComInterval=MDF.Flpp(2)/1440;
ComStopTime=ItDate+MDF.Flpp(3)/1440;
handles.Model(md).Input.ItDate=ItDate;
handles.Model(md).Input.AvailableFlowTimes=ComStartTime:ComInterval:ComStopTime;

setHandles(handles);

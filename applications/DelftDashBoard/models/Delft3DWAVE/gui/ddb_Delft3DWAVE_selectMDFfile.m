function ddb_Delft3DWAVE_selectMDFfile(varargin)

handles=getHandles;

filename=handles.Model(md).Input(ad).MDFFile;
MDF=ddb_readMDFText(filename);
ItDate=datenum(MDF.itdate,'yyyy-mm-dd');
ComStartTime=ItDate+MDF.flpp(1)/1440;
ComInterval=MDF.flpp(2)/1440;
ComStopTime=ItDate+MDF.flpp(3)/1440;
handles.Model(md).Input(ad).ItDate=ItDate;
handles.Model(md).Input(ad).AvailableFlowTimes=ComStartTime:ComInterval:ComStopTime;

setHandles(handles);

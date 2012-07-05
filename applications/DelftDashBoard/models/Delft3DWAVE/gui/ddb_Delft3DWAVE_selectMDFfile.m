function ddb_Delft3DWAVE_selectMDFfile(varargin)

handles=getHandles;

filename=handles.Model(md).Input.mdffile;
MDF=ddb_readMDFText(filename);
ItDate=datenum(MDF.itdate,'yyyy-mm-dd');
ComStartTime=ItDate+MDF.flpp(1)/1440;
ComInterval=MDF.flpp(2)/1440;
ComStopTime=ItDate+MDF.flpp(3)/1440;
handles.Model(md).Input.referencedate=ItDate;
handles.Model(md).Input.availableflowtimes=datestr(ComStartTime:ComInterval:ComStopTime);

setHandles(handles);

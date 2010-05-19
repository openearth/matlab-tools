function handles=ddb_computeMw(handles)

totflength = sum(handles.Toolbox(tb).Input.FaultLength);
handles.Toolbox(tb).Input.TotalUserFaultLength = totflength;
handles.Toolbox(tb).Input.TotalFaultLength = totflength;
if (totflength > 0)
   Mw = (log10(totflength) + 2.44) / 0.59;
   handles.Toolbox(tb).Input.Magnitude = Mw ;
end 

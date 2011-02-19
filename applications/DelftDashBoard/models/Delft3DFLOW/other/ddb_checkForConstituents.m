function handles=ddb_checkForConstituents(handles,id)
if handles.Model(md).Input(id).salinity.include || handles.Model(md).Input(id).temperature.include || ...
        handles.Model(md).Input(id).sediments.include || handles.Model(md).Input(id).tracers
    handles.Model(md).Input(id).constituents=1;
else
    handles.Model(md).Input(id).constituents=0;
end

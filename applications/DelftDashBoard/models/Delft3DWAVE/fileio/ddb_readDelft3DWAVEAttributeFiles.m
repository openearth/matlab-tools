function handles = ddb_readDelft3DWAVEAttributeFiles(handles)

for ib=1:handles.Model(md).Input.nrdomains
    if ~isempty(handles.Model(md).Input.domains(ib).grid)
        [x,y,enc]=ddb_wlgrid('read',handles.Model(md).Input.domains(ib).grid);
        handles.Model(md).Input.domains(ib).gridx=x;
        handles.Model(md).Input.domains(ib).gridy=y;
        [handles.Model(md).Input.domains(ib).gridXZ,handles.Model(md).Input.domains(ib).gridYZ]=getXZYZ(x,y);
        nans=zeros(size(handles.Model(md).Input.domains(ib).gridX));
        nans(nans==0)=NaN;
        handles.Model(md).Input.domains(ib).depth=nans;
        handles.Model(md).Input.domains(ib).depthz=nans;
    end    
end

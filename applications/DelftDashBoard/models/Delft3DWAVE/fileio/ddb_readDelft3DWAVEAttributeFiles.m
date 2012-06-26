function handles = ddb_readDelft3DWAVEAttributeFiles(handles)

for ib=1:handles.Model(md).Input.nrdomains
    if ~isempty(handles.Model(md).Input.domains(ib).grid)
        [x,y,enc]=ddb_wlgrid('read',handles.Model(md).Input.domains(ib).grid);
        handles.Model(md).Input.domains(ib).gridx=x;
        handles.Model(md).Input.domains(ib).gridy=y;
        nans=zeros(size(handles.Model(md).Input.domains(ib).gridx));
        nans(nans==0)=NaN;
        handles.Model(md).Input.domains(ib).depth=nans;
    end    
end

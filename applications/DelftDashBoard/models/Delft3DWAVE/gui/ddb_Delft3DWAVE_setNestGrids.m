function handles = ddb_Delft3DWAVE_setNestGrids(handles)

if handles.activeWaveGrid>1
    handles.Model(md).Input.nestgrids=[];
    for ii=1:handles.activeWaveGrid-1
        handles.Model(md).Input.nestgrids{ii}=handles.Model(md).Input.domains(ii).gridname;
    end
else
    handles.Model(md).Input.nestgrids={''};
end

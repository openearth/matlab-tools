function ddb_openDelft3DWAVE(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdw','Select MDW file');
        runid   = filename(1:end-4);
        if pathname~=0
            % Delete all domains
            ddb_plotDelft3DWAVE('delete','domain',0);
            handles.Model(md).Input = [];
            handles.activeWaveGrid                      = 1;
%            handles.toolbox(tb).Input.domains           = [];
            handles  = ddb_initializeDelft3DWAVEInput(handles,runid);
            filename =[runid '.mdw'];
            handles  = ddb_readMDW(handles,[pathname filename]);
            handles  = ddb_Delft3DWAVE_readAttributeFiles(handles);
            
            % Coupling with Delft3D-FLOW
            if handles.Model(1).Input(1).MMax>0

                % There is an active FLOW model
                ButtonName = questdlg('Couple with Delft3D-FLOW model?', ...
                    'Couple with flow', ...
                    'Cancel', 'No', 'Yes', 'Yes');
                switch ButtonName,
                    case 'Cancel',
                        return;
                    case 'No',
                        couplewithflow=0;
                    case 'Yes',
                        couplewithflow=1;
                end
                
                if couplewithflow
                    handles.Model(md).Input.referencedate=handles.Model(1).Input(1).itDate;
                    handles.Model(md).Input.mapwriteinterval=handles.Model(1).Input(1).mapInterval;
                    handles.Model(md).Input.comwriteinterval=handles.Model(1).Input(1).comInterval;
                    handles.Model(md).Input.writecom=1;
                    handles.Model(md).Input.coupling='ddbonline';
                    handles.Model(md).Input.mdffile=handles.Model(1).Input(1).mdfFile;
                    for id=1:handles.Model(1).nrDomains
                        handles.Model(1).Input(id).waves=1;
                        handles.Model(1).Input(id).onlineWave=1;
                    end
                    if handles.Model(1).Input(1).comInterval==0 || handles.Model(1).Input(1).comStartTime==handles.Model(1).Input(1).comStopTime
                        ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
                    end
                    if ~handles.Model(1).Input(1).wind
                        % Turn off wind
                        for id=1:handles.Model(md).Input.nrgrids
                            handles.Model(md).Input.domains(id).flowwind=0;                   
                        end
                    end
                end
                
            end
            
            setHandles(handles);
            ddb_plotDelft3DWAVE('plot','active',0,'visible',1,'wavedomain',awg);
            gui_updateActiveTab;
        end        
    otherwise
end

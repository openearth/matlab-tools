function [] = config_rund3d(Model,numNodesInCluster)
%% CONFIG_RUND3D(MODEL) sets up all the variables necessary to
% configure the simulation and runs the model. 

    Model.setuppath = [pwd filesep 'Setup_noRun',filesep];
    Model.finalpath = Model.mainpath;
    
    % Copy the files to the working folder
    copyd3dfiles(Model.setuppath,Model.finalpath)
    
    
    % -> Fix the time parameters that are a bit different
    Model.mdf.Tstart = 0;                                                  %Start time
    Model.mdf.Tstop  = Model.mor.coldstartSpinup + Model.Totalrun;         %Stop  time
    
    Model.mdf.Flmap = [num2str(Model.mor.coldstartSpinup),' ',num2str(Model.mdf.mapInterval)     ,'  ',num2str(Model.mdf.Tstop)]; % Saving Map File
    Model.mdf.Flpp  = [num2str(Model.mdf.Tstart)         ,' ',num2str(Model.mdw.COMWriteInterval),'  ',num2str(Model.mdf.Tstop)]; % Communication File
    
    
    Model.mor.MorStt = Model.mor.coldstartSpinup;

    disp(char(10));
    modmdf(Model.finalpath,Model.mdf);
    disp(char(10));
    modmor(Model.finalpath,Model.mor);
    disp(char(10));
    modmdw(Model.finalpath,Model.mdw);
        
    modbcc([Model.finalpath,Model.bcc.runID],Model.mdf.Tstart,Model.mdf.Tstop);

    disp(['MorStt',' = ',num2str(Model.mor.coldstartSpinup)])
    rund3d(Model,numNodesInCluster);
end
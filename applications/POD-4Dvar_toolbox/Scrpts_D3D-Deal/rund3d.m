function [] = rund3d(Model,numNodesInCluster)
%RUND3D runs the batch file run_delftflow_wave.bat for Delft3D simulations.
%    RUND3D(Model), 'MODEL' is a structure containing all the relevant (up 
%    to this moment) and necessary information to run the Delft3D,
%    properly. This function does not create the files necessary for the
%    execution of Delft3D. Instead, it copies the files from a set-up
%    folder where all the necessary information and files are stored and
%    modifies certain fields of interest in the MDF, MDW, MOR and BCC
%    files. The data used to update the stated files is provided in the
%    structure MODEL.
%    
%    The structure Model should have at least the following fields:
%
%    Model.setuppath ....... Path to the setup folder
%    Model.mdf.finalpath ... Path to the folder where D3D is ran
%    Model.mdf.vars ........ Contains the MDF instances to modify
%    Model.mdf.tstart ...... Contains the simulation starting time
%    Model.mdf.tfinal ...... Contains the simulation final time
%    Model.mor.vars ........ Contains the MOR instances to modify
%    Model.mdw ............. Contains the MDW instances to modify


    iniPath = [pwd,filesep];
    cd (Model.finalpath); 
    delete(['com*']);

    
    % Let's not clog the cluster
    [~,b] = system('qstat -u garcia_in');
    while length(strfind(b, 'garcia_in')) > numNodesInCluster
        disp('Waiting for first batch of jobs to finish.')
        [~,b] = system('qstat -u garcia_in');
        strfind(b, 'garcia_in');
        pause(10);
    end
    
    
    disp(['Starting simulation in: ',Model.finalpath]);
    elnum = num2str(fix(rand*100000));
    
    
    disp(['executing: qsub -V -N ','IG_D3D',elnum ,' run_flow2d3d_wave.sh ',Model.mdw.runID,char(10)])
    [status,w] = system(['qsub -V -N ','IG_D3D',elnum ,' run_flow2d3d_wave.sh ',Model.mdw.runID]);
    
    
    cd(iniPath);
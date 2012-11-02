function [runs] = getobsinfo(datasources, fileName)
% GETOBSINFO loads the information from Delft3D flow map files to a 
% structure.
%     [runs] = getRunsInfo(datasources,fileName) 'DATASOURCES' is a cell 
%     array in which the folders where the data is stored are saved in 
%     string format. 'FILENAME' is a string with the name 
%     of the runid of the Delft3D project. Currently only one fileName may 
%     be provided. So all the map files should have the same name, despite 
%     the different sources.
%
%     GETRUNSINFO returns a structure with the depth results from the map
%     file in two formats: 
%     
%     1. Vectorized in a matrix of [nxm,tn] where n
%     and m are the spatial domain dimensions and tn is the number of time
%     steps saved in the map file. 
%     2. Cell array in which the first column shows the simulation time and
%     the second column is a [nxm] array of the depths. 
% 
%     If 'DATASOURCES' has size more than 1, GETRUNSINFO will be an array 
%     of structures. The size of the spatial domain is also given in the
%     structure. 
   
    addpath('C:\Delft3D\w32\matlab\');
    
    for jSources=1:1:length(datasources)

        trims = dirrec(datasources{jSources},['trih-',fileName,'.dat*']);                  %Find all "trim- RUNID .DAT" files in that directory and subdirectories
        if isempty(trims), error(['No NEFIS map files where found in :', datasources{jSources},'trih-',fileName,'.dat*']); end
        disp(['Searching in: ',datasources{jSources},'trih-',fileName,'.dat*']);
        disp([num2str(size(trims,2)),' Trim files found in Directory and sub-Directories'])
           
        cont = 1; 
        for iTrim=1:1:size(trims,2)               %Not interested in loading the information from the Spin-up period. 
            disp(['Attempting to open: ', trims{iTrim}]);            
            trih = vs_use(trims{iTrim},'quiet');

            step = vs_get(trih,'his-infsed-serie','ITHISS','quiet');
            tunit = vs_get(trih,'his-const','TUNIT','quiet');            
            dt = vs_get(trih,'his-const','DT','quiet');    
            runs(jSources).coords = vs_get(trih,'his-const','MNSTAT','quiet');
            
            for kStepInTrim=1:1:length(step)
              
              if iscell(step), time(cont) = step{kStepInTrim}.*(tunit*dt/60/60);
              else             time(cont) = step(kStepInTrim).*(tunit*dt/60/60);
              end
              
              dps{cont,:}  = vs_get(trih,'his-sed-series',{kStepInTrim},'ZDPS','quiet')';
              %vel.u{cont,:}  = vs_get(trih,'his-series',{kStepInTrim},'ZCURU','quiet')';
              %vel.v{cont,:}  = vs_get(trih,'his-series',{kStepInTrim},'ZCURV','quiet')';
              
              runs(jSources).vectors.dps(:,cont) = dps{cont}';
              %runs(jSources).vectors.Uvel(:,cont) = vel.u{cont}';
              %runs(jSources).vectors.Vvel(:,cont) = vel.v{cont}';
                            
              cont = cont+1;
            end
        end
        
        runs(jSources).times.dps = [time'];
        %runs(jSources).times.vel = [time'];
        clear step time trih trims tunit cont dt Uvel Vvel Wl
    end
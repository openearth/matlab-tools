function [runs] = getrunsinfo(datasources,fileName,options)
% GETRUNSINFO loads the information from Delft3D flow map files to a 
% structure.
%     [runs] = getRunsInfo(datasources,fileName,options) 'DATASOURCES' is a
%     string with the path to the information. 'FILENAME' is a string with
%     the name of the runid of the Delft3D project. Currently only one
%     fileName may be provided. So all the map files should have the same
%     name, despite the different sources. OPTIONS is an optional 
%     structure with the following fields (shown values are default): 
%     
%        depthreshold  = 0.01
%        time          = 'mor'
%        bordermarginN = 1
%        bordermarginS = 1
%        bordermarginE = 1
%        bordermarginW = 1
%        waterleveldata = false
%        velocitydata  = false
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

    defaultopt = struct('depthreshold',0.01,'time','mor','bordermarginN',1,'bordermarginS',1,'bordermarginE',1, ...
        'bordermarginW',1,'waterleveldata',false,'velocitydata',false);

    if (~exist('options','var')) 
        options=defaultopt;
    else
        f = fieldnames(defaultopt);
        for i=1:length(f),
            if (~isfield(options,f{i})||(isempty(options.(f{i})))), options.(f{i})=defaultopt.(f{i}); end
        end
    end
    
    % Check if the name includes extension
    if length(fileName) > 4,
        if strcmp(fileName(end-3),'.')
            fileName = fileName(1:end-4);
        end
    end
    
    % Find all "trim- RUNID .DAT" files in that directory and subdirectories
    trims = dirrec(datasources,['trim-',fileName,'.dat*']);

    if isempty(trims), error(['No NEFIS map files where found in :', datasources,'trim-',fileName,'.dat*']); end
    disp([char(10),'Searching in: ',datasources,'trim-',fileName,'.dat*']);
    disp([num2str(size(trims,2)),' Trim files found in Directory and sub-Directories'])
    
    
    
    % Harvest information
    cont = 1;
    for iTrim=1:1:size(trims,2)
        
        disp(['Attempting to open: ', trims{iTrim}]);
        trim = vs_use(trims{iTrim},'quiet');

        % Flow includes spin-up time, MOR doesn't.
        if strcmpi(options.time,'flow')
            step = vs_get(trim,'map-info-series','ITMAPC','quiet');
            tunit = vs_get(trim,'map-const','TUNIT','quiet');    
            dt = vs_get(trim,'map-const','DT','quiet');  
            
            refdate = datenum(num2str(vs_get(trim,'map-const',{1},'ITDATE',{1})),'yyyymmdd');
            if vs_get(trim,'map-const',{1},'ITDATE',{2}) ~= 0, error('dunno what to do with this time... have never seen it before'); end
            
        elseif strcmpi(options.time,'mor')
            step = vs_get(trim,'map-infsed-serie','MORFT','quiet');
            
            refdate = datenum(num2str(vs_get(trim,'map-const',{1},'ITDATE',{1})),'yyyymmdd');
            if vs_get(trim,'map-const',{1},'ITDATE',{2}) ~= 0, error('dunno what to do with this time... have never seen it before'); end
            
        end

        numsteps = length(step);
        
                                      dps = cell(numsteps,1);
        if options.waterleveldata, wlevel = cell(numsteps,1); end
        if options.velocitydata,     uvel = cell(numsteps,1); vvel = cell(numsteps,1); end
            
        for kStepInTrim=1:1:numsteps

            % Get times instead of steps
            if strcmpi(options.time,'flow')
                if iscell(step), 
                    time(cont) = step{kStepInTrim}.*(tunit*dt/60/60/24);
                else
                    time(cont) = step(kStepInTrim).*(tunit*dt/60/60/24);
                end
            elseif strcmpi(options.time,'mor')
                if iscell(step),
                    time(cont) = step{kStepInTrim};
                else
                    time(cont) = step(kStepInTrim);
                end
            end
            
            
            dps{cont}  = vs_get(trim,'map-sed-series',{kStepInTrim},'DPS','quiet');
            
            if options.waterleveldata
                wlevel{cont}  = vs_get(trim,'map-series',{kStepInTrim},'S1','quiet');
            end
            if options.velocitydata
                uvel{cont}    = mean(vs_get(trim,'map-series',{kStepInTrim},'U1','quiet'),3);
                vvel{cont}    = mean(vs_get(trim,'map-series',{kStepInTrim},'V1','quiet'),3);
            end
            
            if cont==1,
                
                runs.n = vs_get(trim,'map-const','NMAX','quiet');
                runs.m = vs_get(trim,'map-const','MMAX','quiet');

                runs.vectors.x = vs_get(trim,'map-const',{kStepInTrim},'XCOR','quiet'); % X-coord. bottom point in local system
                runs.vectors.y = vs_get(trim,'map-const',{kStepInTrim},'YCOR','quiet'); % Y-coord. bottom point in local system
                runs.vectors.x = runs.vectors.x(:);
                runs.vectors.y = runs.vectors.y(:);
                
                % Define morcells -> active(1)/non-active(0)morphodynamic cells
                % -> Check if a cell has fallen below the minimum threshold
                if length(options.depthreshold) == 1, 
                    morcells = double(dps{cont}>options.depthreshold);
                else 
                    morcells = double(dps{cont}>min(options.depthreshold)).*double(dps{cont}<max(options.depthreshold));
                end
                
                morcells(1:end,1:options.bordermarginW)         = 0;  % Let's not consider the borders.
                morcells(1:end,(end-options.bordermarginE):end) = 0;  % Let's not consider the borders.
                morcells(1:options.bordermarginS,1:end)         = 0;  % Let's not consider the borders.
                morcells((end-options.bordermarginN):end,1:end) = 0;  % Let's not consider the borders.
                
                runs.vectors.dps = nan(runs.n*runs.m,numsteps);
                if options.waterleveldata
                    runs.vectors.wlevel = nan(runs.n*runs.m,numsteps);
                end
                if options.velocitydata
                    runs.vectors.uvel = nan(runs.n*runs.m,numsteps);
                    runs.vectors.vvel = nan(runs.n*runs.m,numsteps);
                end
            else
                
                  if length(options.depthreshold) == 1, 
                      morcells = morcells.*double(dps{cont}>options.depthreshold);
                  else
                      morcells = morcells.*double(dps{cont}>min(options.depthreshold)).*double(dps{cont}<max(options.depthreshold));
                  end
            end
            
            morcells = morcells.*vs_get(trim,'map-series',{kStepInTrim},'KFU','quiet'); % Non-active/active in U-point
            morcells = morcells.*vs_get(trim,'map-series',{kStepInTrim},'KFV','quiet'); % Non-active/active in V-point

            runs.dt = vs_get(trim,'map-const','DT','quiet');
            runs.vectors.dps(:,cont)  = reshape(dps{cont},runs.n*runs.m,1);
            
            if options.waterleveldata
                runs.vectors.wlevel(:,cont) = reshape(wlevel{cont},runs.n*runs.m,1);
            end
            if options.velocitydata
                runs.vectors.uvel(:,cont) = reshape(uvel{cont},runs.n*runs.m,1);
                runs.vectors.vvel(:,cont) = reshape(vvel{cont},runs.n*runs.m,1);
            end
            
            cont = cont+1;
        end
        
        runs.dt(iTrim) = vs_get(trim,'map-const','DT','quiet');
    end

    %Organize a nice data table.
    runs.refdate = refdate;
    runs.times = time';
    runs.vectors.morcells = morcells(:);
    
    runs.validcells.x = runs.vectors.x(runs.vectors.morcells~=0);
    runs.validcells.y = runs.vectors.y(runs.vectors.morcells~=0);
    
    for iTime = 1:1:cont-1
        runs.validcells.z(:,iTime) = runs.vectors.dps(runs.vectors.morcells~=0,iTime);
    end
    
    clear step time trim trims tunit cont dt Uvel Vvel Wl
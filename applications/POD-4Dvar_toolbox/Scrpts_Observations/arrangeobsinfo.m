function [obs] = arrangeobsinfo(options, path2file, elbg)
% [OBS_STRUCT] = ARRANGEOBSINFO(LOADTYPE, ERRORPERCENT, OBSPATH, FILENAME,
% BG) contructs the observations structure for the data assimilation
% process. 
%
%     OBS_STRUCT is a structure that contains all the necessary information
%     regarding the observations characterization necessary in the data
%     assimilation process.
%
%     Observations.coords..... Two rows containing the North -East
%                              coordinates of each observation.
%     Observations.vectors.... A matrix whose columns contain the
%                              observed values at each time. 
%                              (Number of observations in time x Number of 
%                               observations in space)
%                              The observations of different nature will be
%                              stored in a different sub-field. Bottom
%                              Depth in DPS, velocity components in Uvel
%                              and Vvel.
%     Observations.info ..... Observations 
%     Observations.matCov.... Covariance matrix of the observations.
%     Observations.indices... Indices of the observations within the vectors
%                             format. Poiner to the observation station in
%                             Observations.vectors.
%     Observations.Operator.. Observations operator that takes values in the
%                             space of the model and delivers values in the
%                             observational space
%
%   options.path      = [pwd,filesep,'observations',filesep,'obs-full-2.10_7.50_87.8_5.00-sts_6',filesep];
%   options.domain    = 'fulldomain';   % 'stations'
%   options.errortype = 'fix';          % 'relative'
%   options.error     = 0.1;            % If fix: magnitude, if relative:  percentage

        
        disp(['Loading Observations',char(10)]);
        
        thefiles = dirrec(path2file,'.mat');
%        thefiles = dirrec(path2file,'.csv');

        numfiles = length(thefiles);
      
        for ifile = 1:numfiles
            disp(['Loading: ',thefiles{ifile}])
            obs(ifile) = load(thefiles{ifile});
%            obs{ifile} = dlmread(thefiles{ifile}); 
             obs(ifile).times = obs(ifile).times/60/24;
        end

        for ifile = 1:numfiles
            
            % x coordinates
            x_min = max(min(elbg.validcells.x),min(obs(ifile).data(:,1)));
            x_max = min(max(elbg.validcells.x),max(obs(ifile).data(:,1)));
            
            % y coordinates
            y_min = max(min(elbg.validcells.y),min(obs(ifile).data(:,2)));
            y_max = min(max(elbg.validcells.y),max(obs(ifile).data(:,2)));
            
            obs(ifile).data(obs(ifile).data(:,1)>x_max,:) = [];
            obs(ifile).data(obs(ifile).data(:,1)<x_min,:) = [];
            
            obs(ifile).data(obs(ifile).data(:,2)>y_max,:) = [];
            obs(ifile).data(obs(ifile).data(:,2)<y_min,:) = [];
            
            % obs.operator = obs(ifile).data(:,1:2)*[elbg.validcells.x,elbg.validcells.y]'*inv([elbg.validcells.x,elbg.validcells.y]*[elbg.validcells.x,elbg.validcells.y]');
            % [x y z] = griddata(elbg.validcells.x,elbg.validcells.y,elbg.validcells.z(:,ifile),obs(ifile).data(:,1),obs(ifile).data(:,2));
            
            [losind lasdist] = kNearestNeighbors([elbg.vectors.x elbg.vectors.y],[obs(ifile).data(:,1) obs(ifile).data(:,2)],1);
            numobs = size(obs(ifile).data(:,4),1);
           
            obs(ifile).operator = sparse(1:size(losind(lasdist==0),1), losind(lasdist==0),1, size(losind(lasdist==0),1),elbg.m*elbg.n);
            
            %plot3(obs(ifile).operator*elbg.vectors.x,obs(ifile).operator*elbg.vectors.y,obs(ifile).operator*elbg.vectors.dps(:,1),'.r',elbg.vectors.x,elbg.vectors.y,elbg.vectors.dps,'.b')
            %title(['Time: ',num2str(obs(ifile).times)]);

            if options.error == 0,
                obs(ifile).matCov = sparse(eye(numobs));
            else
                obs(ifile).matCov = sparse(1:numobs,1:numobs,obs(ifile).data(:,4)).^2;  %Now we can get the variances.
            end
            
        end
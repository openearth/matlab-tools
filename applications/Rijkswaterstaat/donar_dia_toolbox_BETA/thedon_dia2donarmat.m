function thedon_dia2donarmat
% thedon_dia2donarmat Read the data from the file and produce a matlab structure.
%
% The structure is organized by observed parameter. 

clc; clear;
    
    
    
    addpath([pwd,filesep,'utilities',filesep]);
  
  % -> The location of the ".dia" files
    thedonarfiles = dirrec('p:\1204561-noordzee\data\svnchkout\donar_dia\','.dia');

    
    for ifile = 1:1:length(thedonarfiles)
%% GENERATION OF DONARMAT FILE 
                
        thefolder = thedonarfiles{ifile}(1:max(strfind(thedonarfiles{ifile},filesep)))

        if strfind(lower(thedonarfiles{ifile}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(thedonarfiles{ifile}),'ferry')
            sensor_name = 'FerryBox';
        elseif strfind(lower(thedonarfiles{ifile}),'meetvis')
            sensor_name = 'ScanFish';
        end

        disp(thedonarfiles{ifile});

        % Three inputs: 1. Absolute path to the '.dia' file. (string)
        %               2. Names of columns and corresponding units. The
        %                  units of the variable are taken from the header
        %                  so they are not necessary. (Cell array of
        %                  strings with two columns, column 1 is the name 
        %                  and column 2. is the units.)
        %               3. The timezone. 
        thecompend = donar_dia2donarMat( ...
                         thedonarfiles{ifile}, ....
                         {   'longitude'  ,'degrees_east'; ...
                             'latitude'   ,'degrees_north'; ...
                             'depth'      ,'centimeters'; ...
                             'datestring' ,'yyyymmdd';...
                             'timestring' ,'HHMMSS'; ...
                             'variable'   ,'' ...
                         }, ...
                         'UTC + 1' ...
                     );
        disp(['Opening file',char(10)]);


        year_fields = strrep(fields(thecompend),'year','');
        for iyear = 1:1:length(year_fields)


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Save information with flags %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            toSave = thecompend.(['year',year_fields{iyear}])
            disp(['Saving: ',thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat']);
            save([thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat'],'toSave');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Save only unflagged information %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            parameter_fields = fields(thecompend.(['year',year_fields{iyear}]));
            for j = 1:length(parameter_fields)

                index = thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(:,7) ~= 0;
                thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(index,:) = []; % Remove the flagged data... to use in the rest of the scripts
            end
            toSave = thecompend.(['year',year_fields{iyear}]);

            disp(['Saving ',thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat',char(10)]);
            save([thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat'], 'toSave');

        end

    end


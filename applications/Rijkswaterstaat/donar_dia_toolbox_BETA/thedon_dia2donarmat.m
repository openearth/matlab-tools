function thedon_dia2donarmat(OPT)
%thedon_dia2donarmat  Transform DIA file to mat file, loop wrapper for donar_dia2donarMat
%
% The structure is organized by observed parameter.
% thedon_dia2donarmat is a wrapper for donar_dia2donarMat.
%
% Takes ~ 13 minutes for all 3 sensors.
%
%See also: findAllFiles, donar_dia2donarMat

OPT.diadir = 'p:\1204561-noordzee\data\raw\RWS\';
OPT.diadir = 'p:\1209005-eutrotracks\raw\';
    
%% The location of the raw ".dia" files

diafiles  = findAllFiles(OPT.diadir,'pattern_incl','*.dia');
nfile     = length(diafiles);
for ifile = 1:1:nfile

%% GENERATION OF DONARMAT FILE 
    thefolder = first_subdir(fileparts(diafiles{ifile}),-1); % remove trailing \raw\

    if     strfind(lower(diafiles{ifile}),'ctd')    ;sensor_name = 'CTD'; 
    elseif strfind(lower(diafiles{ifile}),'ferry')  ;sensor_name = 'FerryBox';
    elseif strfind(lower(diafiles{ifile}),'meetvis');sensor_name = 'ScanFish';
    end

    disp(diafiles{ifile});

    % Three inputs: 1. Absolute path to the '.dia' file. (string)
    %               2. Names of columns and corresponding units. The
    %                  units of the variable are taken from the header
    %                  so they are not necessary. (Cell array of
    %                  strings with two columns, column 1 is the name 
    %                  and column 2. is the units.)
    %               3. The timezone. 
    disp(['Processing DONAR dia file ',num2str(ifile),'/',num2str(nfile),': ',diafiles{ifile}])
    thecompend = donar_dia2donarMat( ...
                     diafiles{ifile}, ....
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

%% Save information with flags, per parameter

        toSave = thecompend.(['year',year_fields{iyear}])
        disp(['Saving: ',thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat']);
        save([thefolder,sensor_name,'_',year_fields{iyear},'_withFlag','.mat'],'toSave');

%% Save only unflagged information, per parameter

        parameter_fields = fields(thecompend.(['year',year_fields{iyear}]));
        for j = 1:length(parameter_fields)

            index = thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(:,7) ~= 0;
                    thecompend.(['year',year_fields{iyear}]).(parameter_fields{j}).data(index,:) = []; % Remove the flagged data... to use in the rest of the scripts
        end
        toSave = thecompend.(['year',year_fields{iyear}]);

        disp(['Saving ',thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat',char(10)]);
        save([          thefolder,sensor_name,'_',year_fields{iyear},'_the_compend','.mat'], 'toSave');

    end

end


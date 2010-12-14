function Transform(s)

%clear all; close all; clc;
addpath('F:\Repository\oeTools1\matlab\applications\Rijkswaterstaat\matroos\')

%%  parameters
unit        = {'wave_height_hm0','wave_dir_th0','wave_period_tm02','waterlevel_surge'};
source      = {'observed','rws_prediction'};
tstart      = s.StartDate;
tstop       = s.EndDate;

%% open files
YM6 = textread('data_YM6.asc','%f','delimiter',' ','headerlines',6);
YM6 = reshape(YM6,6,length(YM6)/6)';
EUR = textread('data_EUR.asc','%f','delimiter',' ','headerlines',6);
EUR = reshape(EUR,6,length(EUR)/6)';
ELD = textread('data_ELD.asc','%f','delimiter',' ','headerlines',6);
ELD = reshape(ELD,6,length(ELD)/6)';

% get end time of input ASCII files
YM6_tend = datenum(num2str(YM6(end,1:2)),['yyyymmdd HHMMSS']);
% EUR_tend = datenum(num2str(EUR(end,1:2)),['yyyymmdd HHMMSS']);
% ELD_tend = datenum(num2str(ELD(end,1:2)),['yyyymmdd HHMMSS']);

%% get data from matroos

% ------------- YM6 --------------------------
% first check if the input files are up to date. If not, change the start date for getting data in the end date of the input file, 
% to make sure that the input file is continue in time
if tstart < YM6_tend
else;
    if tstart > YM6_tend + 1/24
        tstart1 = YM6_tend + 1/24;
    else
        tstart1 = tstart;
    end

    if YM6_tend < tstart

        %%% specify matroos user and password
        prompt      = {'username','password'};
        dlg_title   = 'MATROOS input';
        num_lines   = 1;
        def         = {'deltares','M@TR00$'};
        answer      = inputdlg(prompt,dlg_title,num_lines,def);

        %%% write script for user and password
        fid = fopen('matroos_user_password.m','w');
        fprintf(fid,'%s\n\n','function [user, passwd, url]=matroos_user_password');
        fprintf(fid,'%s\n',['  user    = ''' answer{1} ''';']);
        fprintf(fid,'%s\n',['  passwd  = ''' answer{2} ''';']);
        fprintf(fid,'%s\n',['  url     = ' '''matroos.deltares.nl'';']);
        fclose(fid);

        if tstop < floor(now)-1
            for i=1:length(unit)
                DataYM6a(i).val         = matroos_get_series('unit',unit{i},'source',source{1},'loc','ijmuiden munitiestort 1','tstart',tstart1,'tstop',tstop,'check','');
            end
            for i=1:length(unit)
                DataYM6aa(i).val        = matroos_get_series('unit',unit{i},'source',source{1},'loc','ijmuiden munitiestort 2','tstart',tstart1,'tstop',tstop,'check','');
            end
        elseif tstop > floor(now)-1
            % the period from the past to now
            tstop1 = (floor(now)-1);
            for i=1:length(unit)
                DataYM6a(i).val         = matroos_get_series('unit',unit{i},'source',source{1},'loc','ijmuiden munitiestort 1','tstart',tstart1,'tstop',tstop1,'check','');
            end
            for i=1:length(unit)
                DataYM6aa(i).val        = matroos_get_series('unit',unit{i},'source',source{1},'loc','ijmuiden munitiestort 2','tstart',tstart1,'tstop',tstop1,'check','');
            end
            % the period from now to the future; only wave height
            tstart1 = (floor(now)-1);
            for i=1
                DataYM6b(i).val         = matroos_get_series('unit','wave_height','source',source{2},'loc','ijmuiden munitiestort 1','tstart',tstart1,'tstop',tstop,'check','');
            end
        end
    end

    % combine datasets munitiestortplaats 1 and munitiestortplaats 2
    for i=1:length(unit)
        combined        = [DataYM6a(i).val; DataYM6aa(i).val];
        % sort to line everything up
        [dum ids]       = sort(combined(:,1));
        combined        = combined(ids,:);
        % remove double points
        [dum idu]       = unique(combined(:,1));
        DataYM6a(i).val = combined(idu,:);
        clear ids idu dum combined
    end

    % ------------- EUR --------------------------
    % first check if the input files are up to date. If not, change the start date for getting data in the end date of the input file,
    % to make sure that the input file is continue in time

    if tstart > YM6_tend + 1/24;
        tstart1 = YM6_tend + 1/24;
    else
        tstart1 = tstart;
    end

    if YM6_tend < tstart
        % get data from matroos
        if tstop < floor(now)-1
            for i=1:length(unit)
                DataEURa(i).val     = matroos_get_series('unit',unit{i},'source',source{1},'loc','europlatform 3','tstart',tstart1,'tstop',tstop,'check','');
            end
            for i=1:length(unit)
                DataEURaa(i).val    = matroos_get_series('unit',unit{i},'source',source{1},'loc','europlatform 2','tstart',tstart1,'tstop',tstop,'check','');
            end
        elseif tstop > floor(now)-1
            % the period from the past to now
            tstop1 = (floor(now)-1);
            for i=1:length(unit)
                DataEURa(i).val     = matroos_get_series('unit',unit{i},'source',source{1},'loc','europlatform 3','tstart',tstart1,'tstop',tstop1,'check','');
            end
            for i=1:length(unit)
                DataEURaa(i).val    = matroos_get_series('unit',unit{i},'source',source{1},'loc','europlatform 2','tstart',tstart1,'tstop',tstop1,'check','');
            end
            % the period from now to the future; only wave height
            tstart1 = (floor(now)-1);
            for i=1
                DataEURb(i).val     = matroos_get_series('unit','wave_height','source',source{2},'loc','europlatform','tstart',tstart1,'tstop',tstop,'check','');
            end
        end
    end

    % combine datasets europlatform 3 and europlatform 2
    for i=1:length(unit)
        combined        = [DataEURa(i).val; DataEURaa(i).val];
        % sort to line everything up
        [dum ids]       = sort(combined(:,1));
        combined        = combined(ids,:);
        % remove double points
        [dum idu]       = unique(combined(:,1));
        DataEURa(i).val = combined(idu,:);
        clear ids idu dum combined
    end

    % ------------- ELD --------------------------
    % first check if the input files are up to date. If not, change the start date for getting data in the end date of the input file,
    % to make sure that the input file is continue in time

    if tstart > YM6_tend + 1/24
        tstart1 = YM6_tend + 1/24;
    else
        tstart1 = tstart;
    end

    if YM6_tend < tstart
        % get data from matroos
        if tstop < floor(now)-1
            for i=1:length(unit)
                DataELDa(i).val     = matroos_get_series('unit',unit{i},'source',source{1},'loc','wadden eierlandse gat','tstart',tstart1,'tstop',tstop,'check','');
            end
        elseif tstop > floor(now)-1
            % the period from the past to now
            tstop1 = (floor(now)-1);
            for i=1:length(unit)
                DataELDa(i).val     = matroos_get_series('unit',unit{i},'source',source{1},'loc','wadden eierlandse gat','tstart',tstart1,'tstop',tstop1,'check','');
            end
            % the period from now to the future; only wave height
            % DATA FROM IJMUIDEN IS USED FOR EIERLANDSE GAT, BECAUSE NO PREDICTION FOR EIERLANDSE GAT AVAILABLE !!
            tstart1 = (floor(now)-1);
            for i=1
                DataELDb(i).val     = matroos_get_series('unit','wave_height','source',source{2},'loc','ijmuiden munitiestort 1','tstart',tstart1,'tstop',tstop,'check','');
            end
        end
    end

    % no surge data available, so matrix needs to be filled with NaNs
    DataYM6a(4).val     = [DataYM6a(1).val(:,1) nan(size(DataYM6a(1).val(:,2)))];
    DataEURa(4).val     = [DataEURa(1).val(:,1) nan(size(DataEURa(1).val(:,2)))];
    DataELDa(4).val     = [DataELDa(1).val(:,1) nan(size(DataELDa(1).val(:,2)))];

    % for future data no data available for Th0,Tm02,Surge, so matrix needs to be filled with NaNs
    for i=2:4
        DataYM6b(i).val = [DataYM6b(1).val(:,1) nan(size(DataYM6b(1).val(:,2)))];
        DataEURb(i).val = [DataEURb(1).val(:,1) nan(size(DataEURb(1).val(:,2)))];
        DataELDb(i).val = [DataELDb(1).val(:,1) nan(size(DataELDb(1).val(:,2)))];
    end

    %% combine datasets from past to now and from now to future
    for i=1:length(unit)
        YM6com(i).val = [DataYM6a(i).val;DataYM6b(i).val];
        EURcom(i).val = [DataEURa(i).val;DataEURb(i).val];
        ELDcom(i).val = [DataELDa(i).val;DataELDb(i).val];
    end

    %% format output
    Textra      = [(YM6_tend+1/24):1/24:tstop]';
    Textra      = (round(Textra*3600*24))/(3600*24);
    date        = datestr(Textra,'yyyymmdd');
    time        = datestr(Textra,'HHMMSS');

    YM6comA     = nan(size(Textra,1),4);
    EURcomA     = nan(size(Textra,1),4);
    ELDcomA     = nan(size(Textra,1),4);

    for i=1:length(unit)
        YM6comA(ismember(Textra,YM6com(i).val(:,1)),i) = YM6com(i).val(ismember(unique(YM6com(i).val(:,1)),Textra),2);
        EURcomA(ismember(Textra,EURcom(i).val(:,1)),i) = EURcom(i).val(ismember(unique(EURcom(i).val(:,1)),Textra),2);
        ELDcomA(ismember(Textra,ELDcom(i).val(:,1)),i) = ELDcom(i).val(ismember(unique(ELDcom(i).val(:,1)),Textra),2);
    end

    YM6comA(YM6comA==0) = NaN;
    EURcomA(EURcomA==0) = NaN;
    ELDcomA(ELDcomA==0) = NaN;

    YM6a        = [YM6;[str2num(date) str2num(time) YM6comA]];
    EURa        = [EUR;[str2num(date) str2num(time) EURcomA]];
    ELDa        = [ELD;[str2num(date) str2num(time) ELDcomA]];

    %% write data in ascii files

    % ------------- YM6 --------------------------
    fid = fopen('data_YM6a.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],YM6a');
    fclose(fid);

    % ------------- EUR --------------------------
    fid = fopen('data_EURa.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],EURa');
    fclose(fid);

    % ------------- ELD --------------------------
    fid = fopen('data_ELDa.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],ELDa');
    fclose(fid);
end
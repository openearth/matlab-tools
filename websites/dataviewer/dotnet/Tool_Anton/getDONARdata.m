clearvars -except s
addpath(genpath('F:\Repository\oeTools1\matlab\io\netcdf\'));

%% Parameters (check on: opendap.deltares.nl)
Locations   = {'IJMDMNTSPS.nc','EURPFM.nc','EIELSGT.nc'};
Parameters  = {'sea_surface_wave_significant_height','sea_surface_wave_from_direction','sea_surface_wind_wave_tm02'};
url_ini     = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/';

% nc_dump(url)

%% get data from DONAR database
for i=1:length(Locations)
    for j=1:length(Parameters)
        url     =    [url_ini Parameters{j} '/id2' num2str(j+1) '-' Locations{i}];
        if     j==1; D(i).hm0.val   = nc_varget(url,Parameters{1});  D(i).hm0.time = nc_cf_time(url,'time')'; 
        elseif j==2; D(i).th0.val   = nc_varget(url,Parameters{2});  D(i).th0.time = nc_cf_time(url,'time')'; 
        elseif j==3; D(i).tm02.val  = nc_varget(url,Parameters{3});  D(i).tm02.time = nc_cf_time(url,'time')'; 
        end
        clear url;
    end
end

%% get data from ASCII files

YM6 = textread('data_YM6.asc','%f','delimiter',' ','headerlines',6);
YM6 = reshape(YM6,6,length(YM6)/6)';
EUR = textread('data_EUR.asc','%f','delimiter',' ','headerlines',6);
EUR = reshape(EUR,6,length(EUR)/6)';
ELD = textread('data_ELD.asc','%f','delimiter',' ','headerlines',6);
ELD = reshape(ELD,6,length(ELD)/6)';

% get end time of input ASCII files (assuming this is the same for YM6, EUR and ELD
YM6_tend = datenum(num2str(YM6(end,1:2)),['yyyymmdd HHMMSS']);

%% check overlap data
% check minimum end time of DONAR files
minTime = min([D(1).tm02.time(end),D(2).tm02.time(end),D(3).tm02.time(end)]);
% make time line for the data
Textra  = [(YM6_tend+1/24):1/24:minTime]'; 
Textra  = (round(Textra*3600*24))/(3600*24);

if any(Textra)

    % check data on times
    for i=1:length(Locations)
        Outmat(i).val                                   = NaN(size(Textra,1),4);
        Outmat(i).val(ismember(Textra,D(i).hm0.time),1) = D(1).hm0.val(ismember(Textra,D(i).hm0.time));
        Outmat(i).val(ismember(Textra,D(i).th0.time),2) = D(1).th0.val(ismember(Textra,D(i).th0.time));
        Outmat(i).val(ismember(Textra,D(i).tm02.time),3)= D(1).tm02.val(ismember(Textra,D(i).tm02.time));
    end
    OutmatT = [datestr(Textra,'yyyymmdd') datestr(Textra,'HHMMSS')];

    %% add data to ASCII files
    % make new output matrix
    YM6new  = [YM6;[str2num(OutmatT(:,1:8)) str2num(OutmatT(:,9:14)) Outmat(1).val]];
    EURnew  = [EUR;[str2num(OutmatT(:,1:8)) str2num(OutmatT(:,9:14)) Outmat(2).val]];
    ELDnew  = [ELD;[str2num(OutmatT(:,1:8)) str2num(OutmatT(:,9:14)) Outmat(3).val]];

    % ------------- YM6 --------------------------
    fid = fopen('data_YM6.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],YM6new');
    fclose(fid);

    % ------------- EUR --------------------------
    fid = fopen('data_EUR.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],EURnew');
    fclose(fid);

    % ------------- ELD --------------------------
    fid = fopen('data_ELD.asc','w');
    fprintf(fid,'%s\n','* column 1 = Date');
    fprintf(fid,'%s\n','* column 2 = Time');
    fprintf(fid,'%s\n','* column 3 = Hm0   (m)');
    fprintf(fid,'%s\n','* column 4 = Hdir  (deg N)');
    fprintf(fid,'%s\n','* column 5 = Tm02  (s)');
    fprintf(fid,'%s\n','* column 6 = Surge (m)');
    fprintf(fid,['%08.0f  %06.0f  ' repmat('%8.3f   ',1,4) '\n'],ELDnew');
    fclose(fid);

end

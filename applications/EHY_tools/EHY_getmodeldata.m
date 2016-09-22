function Data = EHY_getmodeldata(sim_dir,runid,modelType,varargin)

% Extracts time series (of water levels), from SDS file, Sobek3 file, implic output etc.
OPT.varName = 'wl';
OPT         = setproperty(OPT,varargin);

switch OPT.varName
    %% Waterlevels
    case 'wl'
        %% Read Sobek3 data
        if strcmpi(modelType,'sobek3')
            sobekFile=dir([ sim_dir filesep runid '.dsproj_data\Water level (op)*.nc*']);
            D=read_sobeknc([sim_dir filesep runid '.dsproj_data' filesep sobekFile.name]);
            
            Data.stationNames=strtrim(D.feature_name.Val);
            Data.times       =D.water_level.Time;
            Data.val         =D.water_level.Val;
            %% Read Waqua data
        elseif strcmpi(modelType,'waqua')
            sds= qpfopen([sim_dir filesep 'SDS-' runid]);
            
            Data.stationNames  = strtrim(qpread(sds,1,'water level (station)','stations'));
            Data.times         = qpread(sds,1,'water level (station)','times');
            Data.val           = waquaio(sds,[],'wlstat',0,0);
            %% Read Implic data (write to mat file for future fast processing
        elseif strcmpi(modelType,'implic')
            if exist([sim_dir filesep 'implic.mat'],'file')
                load([sim_dir filesep 'implic.mat']);
            else
                months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
                D         = dir2(sim_dir,'file_incl','\.dat$');
                files     = find(~[D.isdir]);
                filenames = {D(files).name};
                for i_stat = 1: length(filenames)
                    [~,name,~] = fileparts(filenames{i_stat});
                    Data.stationNames{i_stat} = name;
                    fid   = fopen([sim_dir filesep filenames{i_stat}],'r');
                    line  = fgetl(fid);
                    line  = fgetl(fid);
                    line  = fgetl(fid);
                    i_time = 0;
                    while ~feof(fid)
                        i_time  = i_time + 1;
                        line    = fgetl(fid);
                        i_day   = str2num(line(1:2));
                        i_month = find(~cellfun(@isempty,strfind(months,line(4:6))));
                        i_year  = str2num(line( 8:11));
                        i_hour  = str2num(line(13:14));
                        i_min   = str2num(line(16:17));
                        r_val   = str2num(line(18:end))/100.;
                        Data.times(i_time) = datenum(i_year,i_month,i_day,i_hour,i_min,0);
                        Data.val(i_time,i_stat)  = r_val;
                    end
                    fclose(fid);
                end
                save([sim_dir filesep 'implic.mat'],'Data');
            end
        end
    case 'uv'
        
        % To be implemented
        
    case 'sal'
        
        % To be implemented
end



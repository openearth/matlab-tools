function cyclonestats_write_WES_input(destout,type, cyclone_files, setting)
% This script creates spiderwebs based on track with wind speed
% Initially, wind speeds are in knots and 1 min averaged
% We will convert that to m/s and 10 min
% We use Nederhoff et al. (2019) for the radii (mode or stochastic)
% We use wes to create the spiderweb including asymmetry
% Wind speed reduces simple with 10 knots per 6 hours to get down to 10 kn
% There is an option to change the date to 1970-01-01 for input for SWAN and save 'real' datenum

% Start!
disp('Start cyclonestats_write_WES_input.m')

% Get all variables
simfile             = cyclone_files.(type);
AoIfile             = cyclone_files.AoIfile;
rainfall            = 0; %setting.rainfall;
rain_relation       = 'default'; %setting.rain_relation;
change_cs           = setting.change_cs;
merge_frac          = setting.merge_frac;
change_date         = setting.change_date;
region              = setting.regionID;

% Stochastic wind radii?
if isequal(type,'observed')
    probability         = setting.stochastic_radii(1);
else
    probability         = setting.stochastic_radii(2);
end

% Settings
averagepressure     = 101325;     % Pa

% Input
icount      = 0;
tracks      = load(simfile);
numtracks   = size(tracks.vmax,1);
chosentracks = [];

% AoI
xldb=AoIfile(:,2);
yldb=AoIfile(:,1);

% Also define the spiderweb
spw.rainfall    = rainfall;
spw.rain_relation = rain_relation;
spw.wind_speed_unit='ms';
spw.radius_unit='KM';
spw.wind_conversion_factor=1;
spw.radius_velocity=[35 50 65 100];
spw.radius=900000;
spw.nr_directional_bins=36;
spw.nr_radial_bins=600;
spw.reference_time=datenum(1970,1,1);
if change_cs == 1
    spw.cs.name = cs.name;
    spw.cs.type = cs.type;
else
    spw.cs.name='WGS 84';
    spw.cs.type='geographic';
end
spw.cut_off_speed=0;
spw.merge_frac=merge_frac;
spw.pn                  = averagepressure / 100;
spw.asymmetry_magnitude='schwerdt1979';
spw.asymmetry_magnitude='factor';
spw.asymmetry_factor=0.55;
spw.wind_profile='holland2010';
spw.phi_spiral=22.6;                    % source: https://journals.ametsoc.org/doi/pdf/10.1175/MWR-D-11-00339.1
spw.asymmetry_option = 'schwerdt1979';

% Standard
knt_to_ms               = 0.514444444 ;
wind_conversion_factor  = setting.wind_conversion_factor; 		% Harper et al., 2010

% Loop over tracks
possibletracks = zeros(numtracks,1);
parfor i=1:numtracks
    
    % Generate tracks
    disp([' generating parfor wes ' num2str(i) ' of ' num2str(numtracks)]);
    
    % Lon and lat
    lon = tracks.lon(i,:);
    lat = tracks.lat(i,:);
    time= tracks.time(i,:);
    dt  = (time(2)-time(1))*24;
    
    time0(i) = time(1);
    
    if change_date ==1 % change date to 1970
        time_diff = time0(i) - datenum(1970,01,01);
        time = time - time_diff; %change time of spw to 1970
    end
    wind= tracks.vmax(i,:);
    
    % If probabilty = 1, we also run with certain exceedance probability
    CDF_RMW = round(rand(1)*10000);
    CDF_R35 = round(rand(1)*10000);
    
    if any(inpolygon(lon,lat,xldb, yldb))
        
        try
            
        % Write spw for real in seperate folders
        % Set dummy values
        tc.track            = [];
        tc.track.time       = [];       tc.track.rmax = [];
        tc.track.x          = [];       tc.track.y = [];
        tc.track.vmax       = [];       tc.track.pc = [];
        tc.track.r35ne      = [] ;      tc.track.r35se =[];     tc.track.r35sw = [];    tc.track.r35nw = [];
        tc.track.r50ne      = [] ;      tc.track.r50se =[];     tc.track.r50sw = [];    tc.track.r50nw = [];
        tc.track.r65ne      = [] ;      tc.track.r65se =[];     tc.track.r65sw = [];    tc.track.r65nw = [];
        tc.track.r100ne     = [] ;      tc.track.r100se =[];    tc.track.r100sw = [];   tc.track.r100nw = [];
        
        % Add dummy values
        windnotzero         = 1;
        while windnotzero == 1
            
            % Track continues in same direction untill low wind speed
            idvalue                 = find(~isnan(wind));
            dlon                    = diff(lon(idvalue(end-1):idvalue(end)));
            dlat                    = diff(lat(idvalue(end-1):idvalue(end)));
            
            if idvalue(end) < length(lon)
                lon(idvalue(end)+1)     = lon(idvalue(end)) + dlon;
                lat(idvalue(end)+1)     = lat(idvalue(end)) + dlat;
                
                % Wind speed decreases with 20 knots per 6 hours (10 per 3 hrs)
                time(idvalue(end)+1)    = time(idvalue(end)) + dt/24;
                wind(idvalue(end)+1)    = wind(idvalue(end)) - dt/6*20;
                
                if wind(idvalue(end)+1) <= 10
                    wind(idvalue(end)+1) = 10;
                    windnotzero          = 0;
                end
            else
                wind(end)               = 10;
                windnotzero             = 0;
            end
        end
        
        
        % Create tc
        for it = 1:length(lon(~isnan(lon)))
            
            % Real values
            tc.track.time(it,1)     = time(it);
            tc.track.x(it,1)        = lon(it);
            tc.track.y(it,1)        = lat(it);
            tc.track.vmax(it,1)     = wind(it) * knt_to_ms;         % m/s but 1 min averaged
            
            % Determine values for wind or pressure
            tc.track.pc(it,1)   = wpr_holland2008('vmax',tc.track.vmax(it,1));
            
            % Determine radius -> note tcs structure has 10 minute wind, but
            % relationships are derived for 1 minute winds!
            [rmax,dr35]             = wind_radii_nederhoff(tc.track.vmax(it,1), tc.track.y(it,1), region, probability);
            
            if probability == 1
                tc.track.rmax(it,1)     = rmax.numbers(CDF_RMW);
                if isnan(dr35.mode)
                    r35 = -999;
                else
                    r35                     = rmax.numbers(CDF_RMW) + dr35.numbers(CDF_RMW);
                end
            else
                tc.track.rmax(it,1)     = rmax.mode;
                if isnan(dr35.mode)
                    r35 = -999;
                else
                    r35                     = rmax.mode + dr35.mode;
                end
            end
            
            % Define r35 (if possible)
            tc.track.r35ne(it,1)    = r35 ;       tc.track.r35se(it,1) = r35;     tc.track.r35sw(it,1) = r35;     tc.track.r35nw(it,1) = r35;
            tc.track.r50ne(it,1)    = -999 ;      tc.track.r50se(it,1) = -999;    tc.track.r50sw(it,1) = -999;    tc.track.r50nw(it,1) = -999;
            tc.track.r65ne(it,1)    = -999 ;      tc.track.r65se(it,1) = -999;    tc.track.r65sw(it,1) = -999;    tc.track.r65nw(it,1) = -999;
            tc.track.r100ne(it,1)   = -999 ;      tc.track.r100se(it,1) = -999;   tc.track.r100sw(it,1) = -999;   tc.track.r100nw(it,1) = -999;
        end
        %figure; scatter(tc.track.x, tc.track.y, [], tc.track.vmax, 'filled');
        
        % Determine reference time
        reference_time  = floor(tc.track.time(1))-1;
        
        % Never negative wind
        id                      = tc.track.vmax < 0; tc.track.vmax(id) = 0;
        
        % Only pressure drop
        id                      = tc.track.pc > averagepressure/100;
        tc.track.pc(id)         = averagepressure/100-1;
        tc.track.vmax           = tc.track.vmax * wind_conversion_factor; % wind is 10 minute averaged
        
        % Create tc and spw
        tc.cs.type              = 'geo'; % TL: TCWiSE input is always in degrees so has to remain 'geo', independent of wanted to project output or not
        tc.wind_speed_unit      = 'ms';
        tc.radius_unit          = 'km';
        tc.radius_velocity      = [34,50,64,100] * 0.514;
        fname                   = ['TC_', num2str(i, '%04d')];
        mkdir([destout, '/spw_', type, '/', fname]);
        cd([destout, '/spw_', type, '/', fname]);
                
        % Write cyclone
        tc                      = wes4_tcwise(tc,'tcstructure',spw,['cyclone.spw']);
        fclose('all');
        possibletracks(i) = 1;
        
        catch
            disp([' something went wrong with ' , num2str(i)])
        end
        
    end
end

% Finish this
cd([destout, '\spw_', type])
chosentracks = find(possibletracks==1);
fileID = fopen('chosentracks.txt','wt');
for nn = 1:length(chosentracks)
    fprintf(fileID,'%d \n',chosentracks(nn));
end
fclose(fileID);
fclose('all');

if change_date ==1 % save time(0) in datenums if the times have been changed (can be corrected in post-processing)
    save('chosentracks_datenum_time0.txt', 'time0', '-ascii');
end

fprintf('%s\n',[' tracks found inside polygon = ' num2str(length(chosentracks)) ' out of total ' num2str(numtracks)]);
disp('Finish cyclonestats_write_WES_input.m')
disp(' ');
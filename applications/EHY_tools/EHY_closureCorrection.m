function varargout = EHY_closureCorrection(fileObs,fileMdu,fileCorr,varargin)
%% varargout =  EHY_closureCorrection(fileObs,fileMdu,fileCorr,varargin)
%  Computes closure correction for enclosed water bodies (Veerse Meer, Grevelingen, Volkerak Zoommmeer etc.)
%  First attampt which will hopefully result in a generic approach. 
%  Feel free to modify/improve/extent
% 
%  Input:
%  fileObs: mat file with observed water levels,
%  fileMdu: name of the mdu file of the model (used to get the time-frame,
%           network, external forcing file etc.
%  output:
%  fileCorr: name of the file with time series of the closure correction (*.tim)
% 
%  limitations:
%  1) Wet area determined from the water level in combination with hysometric
%     curve derived from network and depths. This might slightly differ from
%     actual wet area which in longer simulations might result in small
%     differences in computed and measured water level. 
%  2) Only takes into account discharge points defined in ext file.
%     not yet: rain and evaporation over the whole model domain,
%              discharges defined as open boundary.
%
%  Additional input as <keyword,value> pairs
%  timeSkip - time periods to skip measurements because they are considered
%             unreliable
%  dt_bc    - interval to write the closure correction (default 10 minutes)
%  days_ave - time period for the moving average operation used in the
%             closure correction (default 7 days)
oetsettings ('quiet');

%% Time intervals
OPT.timeSkip  = []  ; % Time interval for skipping of measurements (filled in by linear interpolation)
OPT.dt_bc     = 10.0; % Interval in minutes 
OPT.days_ave  = 7;    % number of days for the moving average

OPT = setproperty(OPT,varargin);

%% Load waterlevels
obs = load(fileObs);
%  Proces waterlevel (fill values in intervals timeSkip with NaN 
stations = {obs.A.name};
for istat = 1:length(stations)
    for i_int = 1: size(OPT.timeSkip,1)
        index = find(obs.A(istat).time >= OPT.timeSkip(i_int,1) &  obs.A(istat).time <= OPT.timeSkip(i_int,2));
        obs.A(istat).wl(index) = NaN;
    end
end

%% Read mdu
mdu = dflowfm_io_mdu('read',fileMdu);

%% Time info from MDU
RefDate = num2str(mdu.time.RefDate);
ref_date=datenum(RefDate,'yyyymmdd');
DtUser = mdu.time.DtUser;
DtUser = DtUser * timeFactor('s','d');% in dagen vanaf ref_date
Tunit  = mdu.time.Tunit;
TStart = mdu.time.TStart; % in Tunit vanaf ref_date
TStart = TStart * timeFactor(Tunit,'d');% in dagen vanaf ref_date
TStart = TStart + ref_date; % in MATLAB-dagen
TStop  = mdu.time.TStop * timeFactor(Tunit,'d') + ref_date; % TStop in 1 regel

model_times = TStart:DtUser:TStop;
t_bc        = TStart:OPT.dt_bc/1440.:TStop;

%% Geometry data
data             = EHY_getGridInfo(EHY_getFullWinPath(mdu.geometry.NetFile,fileparts(fileMdu)),{'XYcor' 'Z' 'spherical'});
%  Remove depth points with default value
index            = find(data.Zcor == -999);
data.Zcor(index) = mdu.geometry.Bedlevuni; 

%% Hypsometric curve
[area, volume, interface] = EHY_dethyps(data.Xcor,data.Ycor,data.Zcor,'spherical',data.spherical);

%%  From mdu > ext > pli > discharge_series 
ext_file = mdu.external_forcing.ExtForceFile;
ext_file = EHY_getFullWinPath(ext_file,fileparts(fileMdu));
ext = dflowfm_io_extfile('read',ext_file);
extInd = strmatch('discharge_',{ext.quantity});
pli_files = {ext.filename};
pli_files = pli_files(extInd);
pli_files = EHY_getFullWinPath(pli_files,fileparts(fileMdu));

%  time series from discharge tim files (interpolate to t_bc)
for i_file = 1:length(pli_files)
    pli_file = pli_files{1,i_file};
    tim_file = strrep(pli_file,'.pli','.tim'); % replace '.pli' by '.tim'
    
    [~, name] = fileparts(tim_file);
    pli_names{1,i_file} = name;
            
    %% read tim file
    raw=importdata(tim_file);
    data=raw;
    data     (:,1     ) = data(:,1)/1440.0 + ref_date;% time from min. from ref_date to MATLAB-times
    data_intp(:,i_file) = interp1( data(:,1) , data(:,2) , t_bc);
    
end

%% Discharges associated with water level variations
for istat = 1: length(stations) 
   wl_intp(:,istat) = interp1(obs.A(istat).time, obs.A(istat).wl, t_bc);
end

%  average over all stations, fill NaN values by linear interpolation
DVpeil   = nanmean(wl_intp,2);
nonan    = ~isnan(DVpeil);
DVpeil   = interp1(t_bc(nonan), DVpeil(nonan), t_bc); % lineaire interp om kleine gaten te vullen
area_now = interp1(interface,area,DVpeil);
Qpeil  = area_now.*[diff(DVpeil)/mean(diff(t_bc))/3600/24 0]; %m3/s

%% Closure correction (use the moving average over days_ave)
closeCorr = movmean(Qpeil - sum(data_intp,2)',OPT.days_ave*(1440./OPT.dt_bc)); 

%% Write closure correction tim file
t_bc   = (t_bc - ref_date ) * 1440.0 ;
fid    = fopen(fileCorr,'w'); 
format = '%10.0f %10.6f\n'; 

for i_tm = 1:length(t_bc)
    fprintf(fid,format, t_bc(i_tm) , closeCorr(i_tm));
end
disp(['created file: ', fileCorr])


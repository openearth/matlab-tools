function [cyclonetracks,percbreak]=cyclonestats_simulatetracks(x0,y0,t0,ndays,dt,s,sstfile, setting, varargin)
disp('Start cyclonestats_simulatetracks')

% varargin
coupled_allowed     = [1,1];
decoupled_allowed   = [1,1];
latitude_allowed    = [1,1,1]; 					% forward, heading, vmax based on location (1) instead of latitude (0)
termination_method 	= [2];						% termination method based on simple (1) or complex (2) method
landfile 			= [];
landeffect          = [1];                      % additional effect of land=1 means Kaplan
lon_conv            = 0;
seedrng             = rng;
disp([' used Matlab seed by TCWiSE is: ',num2str(seedrng.Seed)])

% allocate (not sure why needed)
x0_mesh             = [];
y0_mesh             = [];
onland              = 0;

% varagin
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'coupled_allowed'}
                coupled_allowed=varargin{ii+1};
            case{'decoupled_allowed'}
                decoupled_allowed=varargin{ii+1};
            case{'latitude_allowed'}
                latitude_allowed=varargin{ii+1};
            case{'termination_method'}
                termination_method=varargin{ii+1};
            case{'landfile'}
                landfile=varargin{ii+1};
            case{'landeffect'}
                landeffect=varargin{ii+1};
            case{'coefficient_decay'}
                coefficient_decay=varargin{ii+1};
            case{'lon_conversion'}
                lon_conv = varargin{ii+1};
            case{'cutoff_sst'}
                cutoff_sst=varargin{ii+1};
            case{'cutoff_windspeed'}
                cutoff_windspeed = varargin{ii+1};
        end
    end
end
latitude_forward     = latitude_allowed(1);
latitude_heading     = latitude_allowed(2);
latitude_vmax        = latitude_allowed(3);

% Load SST
sst                 = load(sstfile);
sst.lon             = [-179.5:179.5];
if lon_conv == 1
    sst.lon(sst.lon<0) = sst.lon(sst.lon<0) +  360;
    disp('  Converting longitudes of SST from -180:180 to 0:360')
end
sst.lat             = [-89.5:+89.5];
[sst.lon, sst.lat]  = meshgrid(sst.lon, sst.lat);

% Land boundary file to speedup the computation
if ~isempty(landfile)
    
    % Get x,y,z
    data                = load(landfile);
    Ftopo               = scatteredInterpolant(data(:,1), data(:,2), data(:,3), 'natural', 'none');
    
    % Is x0 and y0 in this domain?
    resolution          = 0.1;
    x0TMP               = nanmin(x0):resolution:nanmax(x0);
    y0TMP               = nanmin(y0):resolution:nanmax(y0);
    
    % Mesh grid
    [x0_mesh, y0_mesh]  = meshgrid(x0TMP,y0TMP);
    z0_mesh             = Ftopo(x0_mesh, y0_mesh);
    onland              = z0_mesh > 0;
    
end
ntracks     = length(x0);

% Compute total (maximum) number of time steps for each track
ntimesteps  = floor(ndays*24/dt)+1;

% Allocate track matrices
xtrack      = zeros(ntracks,ntimesteps);xtrack(xtrack==0)=NaN;
ytrack      = xtrack;
vmaxtrack   = xtrack;

nbreak=0;
nbreaktot=0;
brkemptyphi=0;
brkemptyspd=0;
brkemptyvmax=0;
brklimvmax=0;
brkno50kt=0;
brknegspd=0;
brkoffgrid=0;

latavgvmax=0;
latavgphi=0;
latavgspd=0;
nrmlvmax=0;
nrmlphi=0;
nrmlspd=0;

nterm=0;
nterm_speed=0;
nterm_temp=0;
nterm_prob=0;

dxg=s.xg(1,2)-s.xg(1,1);
dyg=s.yg(2,1)-s.yg(1,1);

% Loop through tracks
disp([' start with generating tracks']);
%  WaitMessage = parfor_wait(ntracks, 'Waitbar', true);
parfor k=1:ntracks
    
    % Generate tracks
    disp([' generating parfor synthetic track ' num2str(k) ' of ' num2str(ntracks)]);
    
    % Start
    ok=0;
    nbreak=0;
    nbreaktot=nbreaktot+nbreak;
    
    % Stay in the following loop until we have created a track that is okay.
    while ~ok
        
        % start while loop
        ok=1;
        
        %% Initialize genesis point & allocate arrays
        x 					= zeros(1,ntimesteps);
        x(x==0) 			= NaN;
        y 					= x;
        foreward_speed 		= x;
        heading 		    = x;
        vmax 				= x;
        onland_list 		= x;
        latavg_vmax         = x;
        latavg_forward      = x;
        latavg_heading      = x;
        
        
        % Latitude and longitude of start point
        if nbreak<50
            x(1)=x0(k);
            y(1)=y0(k);
        else
            % This track has failed more than 50 times. Let's try another start location randomly selected from the initial set of genesis points.
            irand=ceil(rand(1,1)*(ntracks-1));
            x(1)=x0(irand);
            y(1)=y0(irand);
        end
        
        % Indices of nearest grid point
        jj 						= round((x(1)-s.xg(1,1))/dxg)+1;
        ii 						= round((y(1)-s.yg(1,1))/dyg)+1;
        
        % Randomly sample foreward speed and heading
        [foreward_speed(1),~]   = randomsample(s.gen_occ(ii,jj).spd.occurrences,1);
        [heading(1),~]          = randomsample(s.gen_occ(ii,jj).phi.occurrences,1);
        
        % Random sample vmax at genesis
        [vmax(1),~]             = randomsample(s.gen_occ(ii,jj).vmax.occurrences,1);
        howlongonland  			= 0; % only genesis not on land
        
        % Loop through time steps
        for it=2:ntimesteps
            
            % Indices nearest grid point
            jj 					= round((x(it-1)-s.xg(1,1))/dxg)+1;
            ii 					= round((y(it-1)-s.yg(1,1))/dyg)+1;
            
            % Check if point falls within grid
            if ii>size(s.xg,1) || ii<=0 || jj>size(s.xg,2) || jj<=0
                
                % Point falls outside grid, so let's try again.
                nrgt35 			= length(find(vmax>setting.minimum_windspeed));
                if nrgt35>0
                    % Yes! This is a proper track!
                    ok=1;
                else
                    
                    % Never exceeded 50kts, so try again...
                    nbreak          = nbreak+1;
                    brkoffgrid 		= brkoffgrid+1;
                    ok          	= 0;
                
                end
                break
            end
            
            % Check for landfall
            iland=0;
            if ~isempty(landfile)
                [index, distance, twoout]   = near_lonlat(x0_mesh, y0_mesh,x(it-1),y(it-1));
                inpol                       = onland(index);
                if inpol==1
                    iland=1;
                    onland_list(it) = 1;
                else
                    onland_list(it) = 0;
                end
            end
            
            %% Foreward speed and heading
            % Find foreward speed and heading bin indices
            ispd 	= near(s.forward_speed_bins,foreward_speed(it-1));
            iphi 	= near(s.heading_bins,heading(it-1));
            
            % Get all occurences within this bin
            % we use based on vector - location, if that one does not exists (if choosen)
            % we use based on decoupled - location, if that one does not (if choosen)
            % we use latitude-based (if choosen)
            
            % A. Forward speed
            Fspd=[];Xspd=[];
            try
                if isfield(s.location(ii,jj).decoupled_forward_speed_change(ispd),'F') && isempty(Fspd)
                    if ~isempty(s.location(ii,jj).decoupled_forward_speed_change(ispd).F)
                        Fspd				= s.location(ii,jj).decoupled_forward_speed_change(ispd).F;
                        Xspd				= s.location(ii,jj).decoupled_forward_speed_change(ispd).X;
                        latavg_forward(it) 	= -1;
                        nrmlspd 			= nrmlspd+1;
                    end
                end
                if isfield(s.latitude(ii).decoupled_forward_speed_change(ispd),'F') && isempty(Fspd) && (latitude_forward ==1)
                    if ~isempty(s.latitude(ii).decoupled_forward_speed_change(ispd).F)
                        Fspd 				= s.latitude(ii).decoupled_forward_speed_change(ispd).F;
                        Xspd 				= s.latitude(ii).decoupled_forward_speed_change(ispd).X;
                        latavg_forward(it) 	= 1;
                        nrmlspd 			= nrmlspd+1;
                        latavgspd 			= latavgspd+1;
                    end
                end
            catch
                disp([' Fspd issue: this should not happen']);
            end
            
            % empty KDE means this has never happened before so try again
            if isempty(Fspd)
                
                % If no KDE, break
                nbreak                          = nbreak+1;
                brkemptyspd                     = brkemptyspd+1;
                ok                              = 0;
                                
                break
            end
            
            
            % Get random sample from previous occurences - change in forward speed
            dspd 				= hit_and_mis(Fspd,Xspd);
            foreward_speed(it) 	= foreward_speed(it-1)+dspd;
            
            % Make sure foreward speed does not go below 0.0
            if foreward_speed(it)<0
                
                % Positive forward speed required, so try again
                nbreak                      = nbreak+1;
                brknegspd                   = brknegspd+1;
                ok                          = 0;
                                
                break
            end
            
            
            
            % B. Heading change
            Fphi=[];Xphi=[];
            try
                if isfield(s.location(ii,jj).decoupled_heading_change(iphi),'F') && isempty(Fphi)
                    if ~isempty(s.location(ii,jj).decoupled_heading_change(iphi).F)
                        Fphi 					= s.location(ii,jj).decoupled_heading_change(iphi).F;
                        Xphi 					= s.location(ii,jj).decoupled_heading_change(iphi).X;
                        latavg_heading(it)      = -1;
                        nrmlphi 				= nrmlphi+1;
                    end
                end
                if isfield(s.latitude(ii).decoupled_heading_change(iphi),'F') && isempty(Fphi) && (latitude_heading ==1)
                    if ~isempty(s.latitude(ii).decoupled_heading_change(iphi).F)
                        Fphi 					= s.latitude(ii).decoupled_heading_change(iphi).F;
                        Xphi 				    = s.latitude(ii).decoupled_heading_change(iphi).X;
                        latavg_heading(it)      = +1;
                        nrmlphi 				= nrmlphi+1;
                        latavgphi 				= latavgphi+1;
                    end
                end
            catch
                disp([' Fphi issue: this should not happen']);
            end
            
            % empty KDE means this has never happened before so try again
            if isempty(Fphi)
                
                % Empty phi
                nbreak                  =nbreak+1;
                brkemptyphi             =brkemptyphi+1;
                ok                      =0;
                                
                break
            end
            
            
            % Compute heading for new time step
            dphi 			= hit_and_mis(Fphi,Xphi);                  	% change in heading
            heading(it) 	= heading(it-1)+dphi; 						% new heading
            heading(it) 	= mod(heading(it),2*pi); 					% stay between 0 and 2 pi
            
            % Compute new position (old method)
            dx  			= 3600*dt*foreward_speed(it)*cos(heading(it));        % Distance travelled in m
            dy  			= 3600*dt*foreward_speed(it)*sin(heading(it));        % Distance travelled in m
            dlon 			= dx/111111/cos(y(it-1)*pi/180);                      % Distance travelled in deg
            dlat 			= dy/111111;                                          % Distance travelled in deg
            x(it) 			= x(it-1)+dlon;
            y(it) 			= y(it-1)+dlat;
            
            
            %% C. Vmax
            % Find index of vmax bin
            ivmax 		=near(s.vmax_bins,vmax(it-1)); % Find Vmax bin
            Fvmax=[];Xvmax=[];
            try
                if isfield(s.location(ii,jj).vmax_change(ivmax),'F')
                    if ~isempty(s.location(ii,jj).vmax_change(ivmax).F)
                        Fvmax 				= s.location(ii,jj).vmax_change(ivmax).F;
                        Xvmax 				= s.location(ii,jj).vmax_change(ivmax).X;
                        nrmlvmax			= nrmlvmax+1;
                        latavg_vmax(it)     = -1;
                    end
                end
                if isfield(s.latitude(ii).vmax_change(ivmax),'F') && isempty(Fvmax) && (latitude_vmax ==1)
                    if ~isempty(s.latitude(ii).vmax_change(ivmax).F)
                        Fvmax 				= s.latitude(ii,1).vmax_change(ivmax).F;
                        Xvmax 				= s.latitude(ii,1).vmax_change(ivmax).X;
                        nrmlvmax 			= nrmlvmax+1;
                        latavgvmax 			= latavgvmax+1;
                        latavg_vmax(it)     = +1;
                    end
                end
            catch
                disp([' Fvmax issue: this should not happen']);
            end
            
            % empty KDE means this has never happened before so try again
            if isempty(Fvmax)
                
                % Empty vmax
                nbreak                      = nbreak+1;
                brkemptyvmax                = brkemptyvmax+1;
                ok                          = 0;
                break
                
            end
            
            
            % Randomly sample change in vmax
            [dvmax] 	= hit_and_mis(Fvmax,Xvmax);
            try
                vmax(it) 	= vmax(it-1)+dvmax(1)*1.0;
            catch
                disp('why');
            end
            
            % Limit Vmax
            if vmax(it)>180
                
                % Check vmax
                nbreak                      = nbreak+1;
                brklimvmax                  = brklimvmax+1;
                ok                          = 0;
                
            end
            
            
            % Optional: land decay based on Kaplan and DeMaria (1995)
            if iland
                howlongonland   = howlongonland + dt; % this adds up (e.g. 6 + 3 = 9 hours)
                
                if landeffect == 1
                    
                    % Compute decay (variable, Kaplan inspired)
                    [v0]            = computelandwarddecay_wind(vmax(it),howlongonland, coefficient_decay);
                    vmax(it)        = v0;
                    
                end
            else
                howlongonland = 0;  % we are not on land anymore
            end
            
            %% D. Termination
            % 1. Termination when vmax < 10 kn/s, but only when 50 kn/s was part of track
            if vmax(it)<=cutoff_windspeed
                vmax(it)=1;
                nrgt35=length(find(vmax>setting.minimum_windspeed));
                if nrgt35>0
                    % Yes! This is a proper track!
                    nterm 		 = nterm+1;
                    nterm_speed  = nterm_speed+1;
                    ok 		     = 1;
                else
                    
                    % Wind speed never reached 50 knots
                    nbreak              = nbreak+1;
                    brkno50kt           = brkno50kt+1;
                    ok                  = 0;
                    
                
                end
                break
            end
            
            % 2. Termination based on temperature of water
            if ~iland
                
                % Find month
                timenow = t0(k) + (dt*it)/24;
                monthnow= month(timenow);
                
                % Find nearest SST value
                [idfull, distance, twoout] = nearxy(x(it), y(it), sst.lon, sst.lat);
                sst_now = sst.sst(monthnow, idfull);
                
                % If sea water at this location is less than 10 degrees celsius (good value?)
                if sst_now < cutoff_sst
                    nrgt35=length(find(vmax>setting.minimum_windspeed));
                    if nrgt35>0
                        
                        % Yes! This is a proper track!
                        nterm 		 = nterm+1;
                        nterm_temp   = nterm_temp+1;
                        ok 		     = 1;
                        
                    else
                        
                        % Sea water break
                        nbreak 		= nbreak+1;
                        brkno50kt 	= brkno50kt+1;
                        ok 			= 0;
                        
                    end
                    break
                end
            end
            
            
            % 3. Termination based on probability
            randterm 	= rand(1);
            hours 		= it*dt;
            
            % Get value
            if termination_method == 1
                pterm 		= s.ptermination(ii,jj);
            elseif termination_method == 2
                hours 		= find(s.termination.timebins<hours,1,'last');
                vmaxterm 	= find(s.termination.vmaxbins<vmax(it),1,'last');
                pterm 		= s.termination.term(hours,vmaxterm).p(ii,jj);
            end
            
            % Check for pterm
            if pterm>randterm
                nrgt35=length(find(vmax>setting.minimum_windspeed));
                if nrgt35>0
                    % Yes! This is a proper track!
                    nterm 		= nterm+1;
                    nterm_prob 	= nterm_prob+1;
                    ok 		     = 1;
                else
                    
                    % Too low
                    nbreak 		= nbreak+1;
                    brkno50kt 	= brkno50kt+1;
                    ok 			= 0;
                    
                
                end
                break
                
            end
            
        end
    end
    
    % Store track in track matrix
%     WaitMessage.Send;
    tt(k,:)             = t0(k):dt/24:t0(k)+ndays;
    xtrack(k,:)         = x;
    ytrack(k,:)         = y;
    vmaxtrack(k,:)      = vmax;
    
end

cyclonetracks.time 			= tt;
cyclonetracks.lon 			= xtrack;
cyclonetracks.lat 			= ytrack;
cyclonetracks.vmax  		= vmaxtrack;

nbreaktot 					= nbreaktot+nbreak;
percbreak.nbreaktot 		= nbreaktot;
percbreak.brkemptyphi 		= brkemptyphi;          % 1
percbreak.brkemptyspd 		= brkemptyspd;          % 2
percbreak.brkemptyvmax 		= brkemptyvmax;         % 3
percbreak.brklimvmax 		= brklimvmax;           % 4
percbreak.brkno50kt 	    = brkno50kt;            % 5
percbreak.brknegspd 		= brknegspd;            % 6
percbreak.brkoffgrid 		= brkoffgrid;           % 7

percbreak.percbreak 		= 100*nbreaktot/ntracks;



percbreak.latavgphi 		= latavgphi;
percbreak.latavgspd 	    = latavgspd;
percbreak.latavgvmax 		= latavgvmax;

percbreak.nrmlspd 			= nrmlspd;
percbreak.nrmlphi 			= nrmlphi;
percbreak.nrmlvmax 			= nrmlvmax;

percbreak.nterm 			= nterm;
percbreak.nterm_prob 	    = nterm_prob;
percbreak.nterm_temp 		= nterm_temp;
percbreak.nterm_speed 		= nterm_speed;

cyclonetracks.percbreak 	= percbreak;
% WaitMessage.Destroy
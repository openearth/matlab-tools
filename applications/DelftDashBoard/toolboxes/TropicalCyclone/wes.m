function tc=wes(trackinput,format,spwinput,outputfile,varargin)

% The tc structure contains all information about the track, as well as
% some conversion factors, e.g. in order to get to 10-minutes averaged wind
% speeds in m/s and some physical and numerical constants (spiralling angle etc.)

% The spw structure ONLY contains info of the spiderweb grid (radius, nr bins,
% etc.).

% Defaults (only used if tc structure does not have these values!)
rhoa=1.15;
phi_spiral=20;
cs.name='WGS 84';
cs.type='geographic';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'rhoa','rhoair','rho_air'}
                rhoa=varargin{ii+1};
            case{'phi_spiral','phispiral'}
                phi_spiral=varargin{ii+1};
        end
    end
end

% Set conversion constants
kts2ms=0.514;
nm2km=1.852;

switch lower(format)
    case{'tcstructure'}
        tc=trackinput;
    case{'jmv30'}
        tc=readjmv30_02(trackinput);
end

if isstruct(spwinput)
    spw=spwinput;
else
    % Read spw input file
end

% Add stuff to tc structure
if ~isfield(tc,'rhoa')
    tc.rhoa=rhoa;
end
if ~isfield(tc,'phi_spiral')
    tc.phi_spiral=phi_spiral;
end
if ~isfield(tc,'cs')
    tc.cs=cs;
end

%% Cut off parts of track that have a wind speed lower than 30 kts (15 m/s)

ifirst=[];
for it=1:length(tc.track)
    if tc.track(it).vmax>=spw.cut_off_speed && isempty(ifirst)
        ifirst=it;
        break
    end
end
tc.track=tc.track(ifirst:end);
ilast=[];
for it=1:length(tc.track)
    if tc.track(it).vmax<spw.cut_off_speed && isempty(ilast)
        ilast=it;
        break
    end
end
if ~isempty(ilast)
    tc.track=tc.track(1:ilast-1);
end

nt=length(tc.track);

%% Convert units

% Convert wind speeds to m/s
switch lower(tc.wind_speed_unit)
    case{'kts','kt','knots'}
        tc.radius_velocity=tc.radius_velocity*kts2ms*tc.wind_conversion_factor; % Convert to m/s
        for it=1:nt
            tc.track(it).vmax=tc.track(it).vmax*kts2ms*tc.wind_conversion_factor; % Convert to m/s
        end
end

% Convert radii to km
for it=1:nt
    switch lower(tc.radius_unit)
        case{'nm'}
            for iq=1:length(tc.track(it).quadrant)
                for irad=1:length(tc.track(it).quadrant(iq).radius)
                    tc.track(it).quadrant(iq).radius(irad)=tc.track(it).quadrant(iq).radius(irad)*nm2km; % Convert to km
                end
            end
    end
end


%% Determine forward speed vx and vy

for it=1:nt
    geofac=1;
    switch lower(tc.cs.type(1:3))
        case{'geo','lat'}
            geofac=111111*cos(tc.track(it).y*pi/180);
    end
    if it==1
        dt=86400*(tc.track(2).time-tc.track(1).time);
        dx=(tc.track(2).x-tc.track(1).x)*geofac;
        dy=(tc.track(2).y-tc.track(1).y)*geofac;
    elseif it==nt
        dt=86400*(tc.track(end).time-tc.track(end-1).time);
        dx=(tc.track(end).x-tc.track(end-1).x)*geofac;
        dy=(tc.track(end).y-tc.track(end-1).y)*geofac;
    else
        dt=86400*(tc.track(it+1).time-tc.track(it-1).time);
        dx=(tc.track(it+1).x-tc.track(it-1).x)*geofac;
        dy=(tc.track(it+1).y-tc.track(it-1).y)*geofac;
    end
    tc.track(it).u_prop=dx/dt;
    tc.track(it).v_prop=dy/dt;
end

%% Compute max wind speed relative to propagation speed
for it=1:nt
    tc.track(it).vmax_rel=tc.track(it).vmax-sqrt(tc.track(it).u_prop^2+tc.track(it).v_prop^2);
end

% And now for the real work, determining A and B (and Pdrop) for each track
% point

for it=1:nt
    
    if sum(~isnan(tc.track(it).quadrant(1).radius))>0
        tc.track(it).method=2;
    else
        tc.track(it).method=7;
    end
    
    switch tc.track(it).method
        case 1
            % Vmax, A and B (odd combo)
            tc=method1(tc,it);
        case 2
            % Vmax, R35 etc.
            tc=method2(tc,it);
        case 3
            % Vmax, Pdrop, Rw
            tc=method3(tc,it);
        case 4
            % Vmax, Pdrop
            tc=method4(tc,it);
        case 5
            % Pdrop based on US storm statistics
            tc=method5(tc,it);
        case 6
            % Pdrop based on Indian storm statistics
            tc=method6(tc,it);
        case 7 % Obsolete
            % Just Vmax
            tc=method7(tc,it);
    end
end

%% Spiderweb file

for it=1:nt
    
    dx=spw.radius/spw.nr_radial_bins;
    r=dx:dx:spw.radius;
    r=r/1000; % km
    dphi=360.0/spw.nr_directional_bins;
    phi=90:-dphi:-270+dphi;
    
    % Initialize arrays
    wind_speed=zeros(length(phi),length(r));
    wind_to_direction_cart=zeros(length(phi),length(r));
    pressure_drop=zeros(length(phi),length(r));
    
    if length(tc.track(it).quadrant)==1 || tc.track(it).method~=2 % FIX THIS
        
        % A and B used for entire circle
        a=tc.track(it).quadrant(1).a;
        b=tc.track(it).quadrant(1).b;
        
        for iphi=1:length(phi)
            wind_speed(iphi,:) = sqrt(a*b*tc.track(it).pdrop*exp(-a./r.^b)./(tc.rhoa*r.^b));
            if tc.track(it).y>0.0
                % Northern hemisphere
                dr=90+phi(iphi)+tc.phi_spiral;
            else
                % Southern hemisphere
                dr=-90+phi(iphi)-tc.phi_spiral;
            end
            wind_to_direction_cart(iphi,:)=dr;
            pd=tc.track(it).pdrop.*exp(-a./r.^b);
            pd=max(pd)-pd;
            pressure_drop(iphi,:) = pd;
        end
        
    else
        
        % First linear interpolation of A and B
        
        aa=[];
        bb=[];
        
        for iq=1:length(tc.track(it).quadrant)
            aa(iq)=tc.track(it).quadrant(iq).a;
            bb(iq)=tc.track(it).quadrant(iq).b;
        end
        
        aa=[aa aa aa];
        bb=[bb bb bb];
        dd=[45 -45 -135 -225];
        dd=[dd+360 dd dd-360];
        a=interp1(dd,aa,phi);
        b=interp1(dd,bb,phi);
        
        for iphi=1:length(phi)
            wind_speed(iphi,:) = sqrt(a(iphi)*b(iphi)*tc.track(it).pdrop*exp(-a(iphi)./r.^b(iphi))./(tc.rhoa*r.^b(iphi)));
            if tc.track(it).y>0.0
                % Northern hemisphere
                dr=90+phi(iphi)+tc.phi_spiral;
            else
                % Southern hemisphere
                dr=-90+phi(iphi)-tc.phi_spiral;
            end
            wind_to_direction_cart(iphi,:)=dr;
            pd=tc.track(it).pdrop.*exp(-a(iphi)./r.^b(iphi));
            pd=max(pd)-pd;
            pressure_drop(iphi,:) = pd;
        end
        
    end
    
    vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+tc.track(it).u_prop;
    vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+tc.track(it).v_prop;
    dr=atan2(vy,vx);
    dr=1.5*pi-dr;
    wind_speed=sqrt(vx.^2 + vy.^2);
    wind_from_direction=180*dr/pi;
    wind_from_direction=mod(wind_from_direction,360);
    
    tc.track(it).wind_speed=wind_speed;
    tc.track(it).wind_from_direction=wind_from_direction;
    tc.track(it).pressure_drop=pressure_drop;
    
end

if ~isempty(outputfile)
    switch lower(spw.cs.type(1:3))
        case{'geo'}
            gridunit='degree';
        otherwise
            gridunit='m';
    end
    write_spiderweb_file_delft3d(outputfile, tc, gridunit, spw.reference_time, spw.radius);
end


%%
function tc=method1(tc,it)

% Vmax, A and B (somewhat odd combo, but okay)

tc.track(it).pdrop=tc.rhoa*exp(1)*tc.track(it).vmax_rel/tc.track(it).quadrant(1).b;


%%
function tc=method2(tc,it)

% Set search ranges
aa=0:10:500;     % Holland A
bb=1.2:0.05:3;    % Holland B
pp=0:200:12000;  % Pressure drop

angles0=[135 45 315 225]; % Angles where the wind is blowing to in the four quadrants

% Compute relative wind speeds for different radii
if tc.track(it).y>0
    angles=angles0+tc.phi_spiral;        % Include spiralling effect
else
    angles=angles0-tc.phi_spiral;        % Include spiralling effect
end
angles=angles*pi/180;                 % Convert to radians
for iq=1:length(tc.track(it).quadrant)
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if ~isnan(tc.track(it).quadrant(iq).radius(irad))
            uabs=tc.radius_velocity(irad)*cos(angles(iq));
            vabs=tc.radius_velocity(irad)*sin(angles(iq));
            urel=uabs-tc.track(it).u_prop;
            vrel=vabs-tc.track(it).v_prop;
            tc.track(it).quadrant(iq).relative_speed(irad)=sqrt(urel^2+vrel^2);
        else
            tc.track(it).quadrant(iq).relative_speed(irad)=NaN;
        end
    end
    urel=tc.track(it).vmax_rel*cos(angles(iq));
    vrel=tc.track(it).vmax_rel*sin(angles(iq));
    uabs=urel+tc.track(it).u_prop;
    vabs=vrel+tc.track(it).v_prop;
    tc.track(it).quadrant(iq).vmax_abs=sqrt(uabs^2+vabs^2);
end

%% Now fit the data

% Do this in two steps
% 1) Find A, B and Pdrop for each quadrant
% 2) Take average value of Pdrop
% 3) Find A and B for each quadrant

for iq=1:length(tc.track(it).quadrant)
    
    tc.track(it).quadrant(iq).a=NaN;
    tc.track(it).quadrant(iq).b=NaN;
    tc.track(it).quadrant(iq).pdrop=NaN;
    
    n=0;
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if ~isnan(tc.track(it).quadrant(iq).radius(irad))
            n=n+1;
            rr(n)=tc.track(it).quadrant(iq).radius(irad);
            vv(n)=tc.track(it).quadrant(iq).relative_speed(irad);
        end
    end
    
    nr=length(rr);
    
    if nr>0
        
        % Try to fit the data
        
        [aaa,bbb,ppp]=meshgrid(aa,bb,pp);
        meanerr2=zeros(size(aaa));
        for ir=1:nr
            vc  = sqrt(aaa.*bbb.*ppp.*exp(-aaa./rr(ir).^bbb)./(tc.rhoa*rr(ir).^bbb));
            err2 = (vc-vv(ir)).^2;
            meanerr2=meanerr2+err2;
        end
        % Also take into account Vmax error
        vmax = sqrt(bbb.*ppp./(tc.rhoa*exp(1)));
        err2 = (vmax - tc.track(it).vmax_rel).^2;
        meanerr2=meanerr2+err2;
        meanerr2=meanerr2/(nr+1);
        rmse=sqrt(meanerr2);
        
        % And now find the minimum
        ind=find(rmse==min(min(min(rmse))));
        [ib,ia,ip]=ind2sub(size(rmse),ind);
        
        aopt=aa(ia);
        bopt=bb(ib);
        popt=pp(ip);
        
        tc.track(it).quadrant(iq).a=aopt;
        tc.track(it).quadrant(iq).b=bopt;
        tc.track(it).quadrant(iq).pdrop=popt;
        
    end
end

% Compute mean pdrop of the quadrants
for iq=1:length(tc.track(it).quadrant)
    pd(iq)=tc.track(it).quadrant(iq).pdrop;
end
pdrop=nanmean(pd);

% And now find A and B again

for iq=1:length(tc.track(it).quadrant)
    
    tc.track(it).quadrant(iq).a=NaN;
    tc.track(it).quadrant(iq).b=NaN;
    
    n=0;
    for irad=1:length(tc.track(it).quadrant(iq).radius)
        if ~isnan(tc.track(it).quadrant(iq).radius(irad))
            n=n+1;
            rr(n)=tc.track(it).quadrant(iq).radius(irad);
            vv(n)=tc.track(it).quadrant(iq).relative_speed(irad);
        end
    end
    
    nr=length(rr);
    
    if nr>0
        
        % Try to fit the data
        [aaa,bbb]=meshgrid(aa,bb);
        meanerr2=zeros(size(aaa));
        for ir=1:nr
            vc  = sqrt(aaa.*bbb.*pdrop.*exp(-aaa./rr(ir).^bbb)./(tc.rhoa*rr(ir).^bbb));
            err2 = (vc-vv(ir)).^2;
            meanerr2=meanerr2+err2;
        end
        % Also take into account Vmax error
        vmax = sqrt(bbb.*pdrop./(tc.rhoa*exp(1)));
        err2 = (vmax - tc.track(it).vmax_rel).^2;
        meanerr2=meanerr2+err2;
        meanerr2=meanerr2/(nr+1);
        rmse=sqrt(meanerr2);
        
        % And now find the minimum
        ind=find(rmse==min(min(rmse)));
        [ib,ia]=ind2sub(size(rmse),ind);
        
        aopt=aa(ia);
        bopt=bb(ib);
        
        tc.track(it).quadrant(iq).a=aopt;
        tc.track(it).quadrant(iq).b=bopt;
        
    end
end

tc.track(it).pdrop=pdrop;

%%
function tc=method3(tc,it)

% Vmax, Pdrop, Rmax

tc.track(it).quadrant.b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant.a=tc.track(it).rmax^tc.track(it).quadrant.b;

%%
function tc=method4(tc,it)

% Vmax, Pdrop

tc.track(it).rmax=25;
tc.track(it).quadrant(1).b=tc.rhoa*exp(1)*tc.track(it).vmax_rel^2/tc.track(it).pdrop;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method5(tc,it)

% Vmax, Rmax (Pdrop based on US storm statistics)

tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method6(tc,it)

% Vmax, Rmax (Pdrop based on Indian storm statistics)

tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

%%
function tc=method7(tc,it)

% Vmax

tc.track(it).rmax=25;
tc.track(it).pdrop=2*tc.track(it).vmax_rel^2;
tc.track(it).quadrant(1).b=1.563;
tc.track(it).quadrant(1).a=tc.track(it).rmax^tc.track(it).quadrant(1).b;

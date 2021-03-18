function cyclonestats_precompute_ibtracks_v04r00(fname,basinid,sst,outputfile,varargin)

% Start
nrnan       = 0;
start_year  = -9999;
end_year    = 9999;
lon_conv    = 0;
dt          = 3;
seedrng     = rng;
disp([' used Matlab seed by TCWiSE is: ',num2str(seedrng.Seed)])

sources = {'bom','cma','ds824','hko','mlc','nadi','neumann','newdelhi','reunion','td9635','td9636','tokyo','usa','wellington','wmo'};

% Get varargin
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'start_year'}
                start_year=varargin{ii+1};
            case{'end_year'}
                end_year=varargin{ii+1};
            case{'source'}
                source=varargin{ii+1};
            case{'lon_conversion'}
                lon_conv = varargin{ii+1};
            case{'timestep'}
                dt = varargin{ii+1};   % 3 or 6 hrs
        end
    end
end

%{
% Available sources in current dataset: 
bom = Australian BoM,
cma = Chinese Met. Admin.,
ds824 = ds824 (static library),
hko = Hong Kong Observatory,
mlc = M.L. Chenoweth dataset (static library),
nadi = RMSC Fiji,
neumann = Charlie Neumann Southern Hemisphere Data (static library),
newdelhi = RSMC New Delhi,
reunion = RSMC La Reunion,
td9635 = TD-9635 dataset (static library),
td9636 = TD-9636 dataset (static library),
tokyo = RMSC Tokyo,
usa = U.S. Agency (RMSC Honolulu and RSMC Miami),
wellington = RMSC Wellingtion,
wmo = Official WMO agency (combined with general lat/lon, 'This is merged position based on the
 position(s) from the various source datasets')

For references sources see https://www.ncdc.noaa.gov/ibtracs/index.php?name=sources
%}

% Default options
isource=[];
if strcmpi('default',source)    % set default data source per basin
    switch basinid
        case 'NA'
            isource = 'usa';
        case 'WP'
            isource = 'usa';        
        case 'EP'
            isource = 'usa';            
        case 'SP'
            isource = 'usa';     
        case 'NI'
            isource = 'usa';        
        case 'SI'
            isource = 'usa';  
    end
            
else % user defined - still check whether wanted data source is in ibtracks file
    for ii=1:size(sources,2)
        if strcmpi(deblank(sources{ii}),source)
            isource=source;
        end
    end
end
if isempty(isource)
    error(['Error reading IBTRACS data! Could not find source ' source '!']);
end

% Read all tracks
if strcmp(isource, 'wmo')==1 %               wmo does not provide a lat/lon > use general merged position  
    lon=nc_varget(fname,'lon',[0 0],[Inf Inf]);
    lat=nc_varget(fname,'lat',[0 0],[Inf Inf]);  
else
    lon=nc_varget(fname,[isource,'_lon'],[0 0],[Inf Inf]);
    lat=nc_varget(fname,[isource,'_lat'],[0 0],[Inf Inf]);
    %lon=nc_varget(fname,[isource,'_lon'],[0 0]);
    %lat=nc_varget(fname,[isource,'_lat'],[0 0]);
end

% Read seasons (=year)
season = nc_varget(fname,'season');

% Read time
tim     = nc_varget(fname,'time');
t0      = datenum(1858,11,17);
tim     = t0+tim;

% Read VMax
wnd     = nc_varget(fname,[isource,'_wind'],[0 0],[Inf Inf]);

% Read TC name
name    = nc_varget(fname, 'name');

% Filter on basin
disp(' filter data ...');
genbasin    = squeeze(nc_varget(fname,'basin',[0 0 0],[Inf 1 Inf])); %only read first
inbasin     = [];
count       = 0;
for ii = 1:size(genbasin,1)
    if strcmp(genbasin(ii,:),basinid)==1
        count = count+1;
        inbasin(count,1) = ii;
    end
end
lon         = lon(inbasin,:);
lat         = lat(inbasin,:);
season      = season(inbasin);
tim         = squeeze(tim(inbasin,:));
wnd         = squeeze(wnd(inbasin,:));
name        = name(inbasin,:);

% Only use storms after start year
iseason     = find(season>=start_year & season<=end_year);
tim         = tim(iseason,:);
lon         = lon(iseason,:);
lat         = lat(iseason,:);
wnd         = wnd(iseason,:);
season      = season(iseason);
name        = name(iseason,:);

% Determine forward speed and direction of storms
nstorms     = size(tim,1);
itlast 		= 30 * 24 / dt; %~longest possible track length around 25 days, so itlast must be longer than 150 steps for dt = 3 hrs
nr          = 0;
nans2       = 0;

% Loop over all the storms and fix things
for ii=1:nstorms
    
    % Get simple vector first
    consecnan=1;
    lon0=squeeze(lon(ii,:));
    lat0=squeeze(lat(ii,:));
    tim0=squeeze(tim(ii,:));
    wnd0=squeeze(wnd(ii,:));
    itwnd1=find(wnd0>0,1,'first');
    itwnd2=find(wnd0>0,1,'last');
    if isempty(itwnd1) || isempty(itwnd2)
        continue
    end
    if itwnd2==itwnd1
        continue
    end
    inanwnd=find(isnan(wnd0(itwnd1:itwnd2)));
    if ~isempty(inanwnd)
        
        % NaNs in the wind field
        if nanmax(wnd0)>=50
            
            % Check how many consecutive NaNs in the wind field
            for x=2:length(inanwnd)
                if inanwnd(x)==inanwnd(x-1)+1
                    consecnan=consecnan+1;
                elseif consecnan>=2
                    consecnan=1;
                end
                if consecnan >= 4           % If more than 3 consecutive NaNs skip cyclone
                    break
                end
            end
            if consecnan >= 4               % If more than 3 consecutive NaNs skip cyclone
                continue
            end
            
            % Interpolate NaNs
            nanData         = isnan(wnd0);
            index           = 1:numel(wnd0);
            wnd0(nanData)   = interp1(index(~nanData), wnd0(~nanData), index(nanData));
            lat0(nanData)   = interp1(index(~nanData), lat0(~nanData), index(nanData));
            lon0(nanData)   = interp1(index(~nanData), lon0(~nanData), index(nanData));
            nrnan           = nrnan+1;
        end
    end
    
    % Check if maximum wind exceeded 50 kts
    if nanmax(wnd0)<=50
        continue
    end
    nr=nr+1;
    
    % Interpolate to 3 or 6-hourly data
    dt_day 	= dt / 24;
    tt 		= tim0(itwnd1):dt_day:tim0(itwnd2); % Time in days
    lon1    = interp1(tim0(itwnd1:itwnd2),lon0(itwnd1:itwnd2),tt);
    lat1    = interp1(tim0(itwnd1:itwnd2),lat0(itwnd1:itwnd2),tt);
    wnd1    = interp1(tim0(itwnd1:itwnd2),wnd0(itwnd1:itwnd2),tt);
    n       = length(tt);
    
    % Sort
    tim2(nr,1:n)        = tt;
    lon2(nr,1:n)        = lon1;
    lat2(nr,1:n)        = lat1;
    wnd2(nr,1:n)        = wnd1;
    tim2(nr,n+1:itlast) = NaN;
    lon2(nr,n+1:itlast) = NaN;
    lat2(nr,n+1:itlast) = NaN;
    wnd2(nr,n+1:itlast) = NaN;
    season2(nr)         = season(ii);
    name2(nr,:)         = name(ii,:);
end
idnotvalues     	= wnd2==0 | tim2 ==0 | isnan(wnd2);
tim2(idnotvalues)   = NaN;
lon2(idnotvalues)   = NaN;
lat2(idnotvalues)   = NaN;
wnd2(idnotvalues)   = NaN;

% Show distribution of genesis
Yfig = 29.7/3;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','on');
hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');

subplot(2,1,1);
peryear=year(tim2(:,1));
edges=min(peryear):max(peryear);
[c,d]=hist(peryear,edges);
bar(d,c);
hold on
b = polyfit(d,c, 1); % calculate linear trendline
fr = polyval(b, d);
plot(d,fr,'k--')
xlim([min(peryear)-1 max(peryear)+1]);
ylabel('# TCs per year');
grid on; box on;

subplot(2,1,2);
permonth=month(tim2(:,1));
edges=1:12;
[c,d]=hist(permonth,edges);
bar(d,c / (max(peryear)-min(peryear)+1))
ylabel('average TC per month');
grid on; box on;
xlim([0.5 12.5]);
set(gca, 'xtick', edges, 'xticklabel', {'Jan', 'Feb', 'March', 'April', 'May', 'June', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'})
print('-dpng','-r300','genesis_year_month.png');


% Check if genesis location is at a warm enough SST area
permonth        = month(tim2(:,1));
edges           = 1:12;
[c,d]           = hist(permonth,edges);
[val monthidx]  = max(c);
xg              = -179.5:1:179.5;
yg              = -89.5:1:89.5;

[val row]       = min(abs(repmat(lat2(:,1),1,length(yg))-repmat(yg(:),1,size(lat2,1))'),[],2);
[val col]       = min(abs(repmat(lon2(:,1),1,length(xg))-repmat(xg(:),1,size(lon2,1))'),[],2);

monthidx1       = repmat(monthidx,1,size(lat2,1));
ind             = sub2ind(size(sst),monthidx1', row, col);
sst_gen         = sst(ind);
aa              = find(sst_gen<24);

if lon_conv == 1
    xg(xg<0) = xg(xg<0) +  360; 
    disp(' converting longitudes of SST from -180:180 to 0:360')    
end
[X,Y]           = meshgrid(xg,yg);

% Figure of main SST
Yfig = 29.7/2;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off'); hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');

if lon_conv == 1
    tmp = squeeze(sst(monthidx,:,:));
    scatter(X(:),Y(:),[],tmp(:), 'filled');  %contourf doesnt like my x-axis change, could be improved be fully swapping 'x1' and 'x2')
    tmp2 = lon2(:,1);
    tmp2(tmp2<0) = tmp2(tmp2<0) +  360;     
    
    tmp3 = lon2(aa,1);
    tmp3(tmp3<0) = tmp3(tmp3<0) +  360;     
    
    plot(tmp2,lat2(:,1),'.r',tmp3,lat2(aa,1),'or')
else
    contourf(X,Y,squeeze(sst(monthidx,:,:)),[0 5 10 15 20 25 30],'ShowText','on');

    plot(lon2(:,1),lat2(:,1),'.r',lon2(aa,1),lat2(aa,1),'or')   
    
end
c=colorbar;colormap;
[xl, yl] = ocean_basins(basinid);
hold on
axis equal
xlim(xl); ylim(yl);
ylabel('latitude [°]')
xlabel('longitude [°]')
grid on; box on;
c.Label.String = 'Sea Surface Temperature (SST) [°C] in main TC genesis month';
print('-dpng','-r300','SST_genesis.png');

% And now delete genesis temp criteria
tim2(aa,:)=[];
lon2(aa,:)=[];
lat2(aa,:)=[];
wnd2(aa,:)=[];
name2(aa,:)=[]; %creates error is aa is not empty?

% Filter points out when temperature is less than 10 degrees
[val row]=min(abs(repmat(lat2(:,:),1,1,length(yg))-permute(repmat(yg,size(lat2,1),1,size(lat2,2)),[1 3 2])),[],3);
[val col]=min(abs(repmat(lon2(:,:),1,1,length(xg))-permute(repmat(xg,size(lon2,1),1,size(lat2,2)),[1 3 2])),[],3);
monthidx2=repmat(monthidx,size(lat2,1),size(lat2,2));
ind=sub2ind(size(sst),monthidx2, row, col);
sstdat=sst(ind);
for n=1:size(lat2,1)
    sstvec=sstdat(n,:);
    i=find(sstvec<10,1,'first');
    tim2(n,i:end)=NaN;
    lon2(n,i:end)=NaN;
    lat2(n,i:end)=NaN;
    wnd2(n,i:end)=NaN;
end

%% Make CDF of track versus temp
monthID     = month(tim2);
countup     = 0;
windnow     = [];
sstnow      = [];
for ijn1 = 1:size(lon2,1)
    for ijn2 = 1:size(lon2,2)
        if ~isnan(wnd2(ijn1, ijn2))
            countup                     = countup+1;
            windnow(countup)            = wnd2(ijn1,ijn2);
            [index, distance, twoout]   = nearxy(X,Y,lon2(ijn1, ijn2), lat2(ijn1, ijn2));
            sstnow(countup)             = sst(monthID(ijn1,ijn2),index);
        end
    end
end

% Plot CDF of termination SST 
Yfig = 29.7/3;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off'); hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');
X = sstnow(~isnan(sstnow));
tmp = sort(reshape(X,prod(size(X)),1));
Xplot = reshape([tmp tmp].',2*length(tmp),1);
tmp = [1:length(X)].'/length(X);
Yplot = reshape([tmp tmp].',2*length(tmp),1);
Yplot = [0; Yplot(1:(end-1))];
hp = plot(Xplot, Yplot,'linewidth', 2);
ColOrd = get(gca, 'ColorOrder'); 
ord = mod(length(get(gca,'Children')), size(ColOrd,1)); 
set(hp, 'Color', ColOrd((ord==0) + (ord>0)*ord, :));
xlabel('X', 'FontWeight','b','FontSize',12);
ylabel('F(X)', 'FontWeight','b','FontSize',12);
title('Empirical CDF', 'FontWeight','b','FontSize',12);
grid on; title('SST when TC terminated');
xlabel('sst [celsius]');
print('-dpng','-r300','SST_termination.png');

%% Finishing
% Convert lat and lons
nryears     = max(season2)-min(season2)+1;
s           = [];

% conversion from -180:180 to 0:360 if wanted
if lon_conv ==1
    disp('  Converting longitudes of dataset from -180:180 to 0:360')
    lon2(lon2>360)  = lon2(lon2>360)-360;
    lon2(lon2<0)    = lon2(lon2<0)+360;
else
    lon2(lon2>180)  = lon2(lon2>180)-360;
    lon2(lon2<-180) = lon2(lon2<-180)+360;
end
lat2(lat2>90)   = lat2(lat2>90)-180;
lat2(lat2<-90)  = lat2(lat2<-90)+180;
    
s.nryears   = nryears;
s.time      = tim2;
s.lon       = lon2;
s.lat       = lat2;
s.vmax      = wnd2;

% Add some noise, since wind speeds are sampled every 5 knts
p           = rand(size(s.vmax));
p           = p*5-2.5;
s.vmax      = s.vmax+p;


% Create KDE generation
tgenesis   = tim2(:,1);
for ii = 1:length(tgenesis)
    yearday(ii) = tgenesis(ii) - datenum(year(tgenesis(ii)),1,1);
end
f_tgenesis = kde(yearday');
s.tgenesis.fcomplex = f_tgenesis.f;
s.tgenesis.xcomplex = f_tgenesis.x{:};

% Create simple genesis
yearday = round(yearday);
x       = 1:365;
f       = zeros(length(x),1);
for days = 1:365
    f(days) = sum(yearday == days)/length(yearday);
end
SmoothY=fastsmooth(f,14,1,1);
s.tgenesis.f = SmoothY;
s.tgenesis.x = x;

% add year and startdate
s.year = year(s.time(:,1));
s.startdate = s.time(:,1);

% add name and name (year)
s.name = name2;

s.nameyear = s.name;

for ii=1:length(s.name(:,1))
    tmp = s.name(ii,:);
    newStr = deblank(tmp);
    fullStr = [newStr, ' (',num2str(s.year(ii)),')'];
    s.nameyear(ii,1:length(fullStr)) = fullStr;
end

% Save file
save(outputfile,'-struct','s');

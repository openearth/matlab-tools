function cyclonestats_precompute(fname,basinid,sst,outputfile,varargin)

% Start
nrnan       = 0;
start_year  = 1970;
lon_conv    = 0;

% Get varargin
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'start_year'}
                start_year=varargin{ii+1};
            case{'source'}
                source=varargin{ii+1};
            case{'lon_conversion'}
                lon_conv = varargin{ii+1};
        end
    end
end
sources=nc_varget(fname,'source');
isource=[];
for ii=1:size(sources,1)
    if strcmpi(deblank(sources(ii,:)),source)
        isource=ii;
    end
end
if isempty(isource)
    error(['Error reading IBTRACS data! Could not find source ' source '!']);
end

% Read all tracks
lon=nc_varget(fname,'source_lon',[0 0 isource-1],[Inf Inf 1]);
lat=nc_varget(fname,'source_lat',[0 0 isource-1],[Inf Inf 1]);

% Read seasons
season=nc_varget(fname,'season');

% Read time
tim=nc_varget(fname,'source_time');
t0=datenum(1858,11,17);
tim=t0+tim;

% Read VMax
wnd=nc_varget(fname,'source_wind',[0 0 isource-1],[Inf Inf 1]);

% Filter on basin
disp('Filter data ...');
genbasin=nc_varget(fname,'genesis_basin');
ibasin=findbasinnumber(basinid);
inbasin=find(genbasin==ibasin);
lon=lon(inbasin,:);
lat=lat(inbasin,:);
season=season(inbasin);
tim=squeeze(tim(inbasin,:));
wnd=squeeze(wnd(inbasin,:));

% Only use storms after start year
iseason=find(season>=start_year);
tim=tim(iseason,:);
lon=lon(iseason,:);
lat=lat(iseason,:);
wnd=wnd(iseason,:);
season=season(iseason);

% Determine forward speed and direction of storms
nstorms=size(tim,1);
itlast=150;
nr=0;
nans2=0;
for ii=1:nstorms
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
                if consecnan >= 4 % If more than 3 consecutive NaNs skip cyclone
                    break
                end
            end
            if consecnan >= 4 %remove if more than 3 consec Nans
                continue
            end
            % Interpolate NaNs
            nanData = isnan(wnd0);
            index   = 1:numel(wnd0);
            wnd0(nanData) = interp1(index(~nanData), wnd0(~nanData), index(nanData));
            lat0(nanData) = interp1(index(~nanData), lat0(~nanData), index(nanData));
            lon0(nanData) = interp1(index(~nanData), lon0(~nanData), index(nanData));
            nrnan=nrnan+1;
        end
    end
    
    % Check if maximum wind exceeded 50 kts
    if nanmax(wnd0)<=50
        continue
    end
    nr=nr+1;
    
    % Interpolate to 6-hourly data
    tt=tim0(itwnd1):0.25:tim0(itwnd2);
    lon1=interp1(tim0(itwnd1:itwnd2),lon0(itwnd1:itwnd2),tt);
    lat1=interp1(tim0(itwnd1:itwnd2),lat0(itwnd1:itwnd2),tt);
    wnd1=interp1(tim0(itwnd1:itwnd2),wnd0(itwnd1:itwnd2),tt);
    n=length(tt);
    
    % Sort
    tim2(nr,1:n)=tt;
    lon2(nr,1:n)=lon1;
    lat2(nr,1:n)=lat1;
    wnd2(nr,1:n)=wnd1;
    tim2(nr,n+1:itlast)=NaN;
    lon2(nr,n+1:itlast)=NaN;
    lat2(nr,n+1:itlast)=NaN;
    wnd2(nr,n+1:itlast)=NaN;
    season2(nr)=season(ii);
    
end
wnd2(wnd2==0)=NaN;

% Check if genesis location is at a warm enough SST area
permonth=month(tim2(:,1));
edges=1:12;
[c,d]=hist(permonth,edges);
[val monthidx]=max(c);
xg=-179.5:1:179.5;
yg=-89.5:1:89.5;

[val row]=min(abs(repmat(lat2(:,1),1,length(yg))-repmat(yg(:),1,size(lat2,1))'),[],2);
[val col]=min(abs(repmat(lon2(:,1),1,length(xg))-repmat(xg(:),1,size(lon2,1))'),[],2);

monthidx1=repmat(monthidx,1,size(lat2,1));
ind=sub2ind(size(sst),monthidx1', row, col);
sst_gen=sst(ind);
aa=find(sst_gen<24);
[X,Y]=meshgrid(xg,yg);

% Show distribution of genesis
Yfig = 29.7/3;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off');; hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');

subplot(2,1,1);
peryear=year(tim2(:,1));
edges=min(peryear):max(peryear);
[c,d]=hist(peryear,edges);
bar(d,c);
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


% Figure of main SST
Yfig = 29.7/2;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off'); hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');
contourf(X,Y,squeeze(sst(monthidx,:,:)),[0 5 10 15 20 25 30],'ShowText','on');
c=colorbar;colormap;
[xl, yl] = ocean_basins(basinid);
hold on
plot(lon2(:,1),lat2(:,1),'.r',lon2(aa,1),lat2(aa,1),'or')
axis equal
xlim(xl); ylim(yl);
ylabel('latitude [°]')
xlabel('longitude [°]')
grid on; box on;
c.Label.String = 'Sea Surface Temperature (SST) [°C] in main TC genesis month';
print('-dpng','-r300','SST_genesis.png');

% Filter points out
tim2(aa,:)=[];
lon2(aa,:)=[];
lat2(aa,:)=[];
wnd2(aa,:)=[];
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

%% Finishing
% Convert lat and lons
nryears=max(season2)-min(season2)+1;
s=[];

% conversion from -180:180 to 0:360 if wanted
if lon_conv ==1
   disp('Converting longitudes of Ibtracs dataset from -180:180 to 0:360')
    lon2(lon2>360)=lon2(lon2>360)-360;
    lon2(lon2<0)=lon2(lon2<0)+360;
else
    lon2(lon2>180)=lon2(lon2>180)-360;
    lon2(lon2<-180)=lon2(lon2<-180)+360;
end

lat2(lat2>90)=lat2(lat2>90)-180;
lat2(lat2<-90)=lat2(lat2<-90)+180;
    
s.nryears=nryears;
s.time=tim2;
s.lon=lon2;
s.lat=lat2;
s.vmax=wnd2;

% Add some noise, since wind speeds are sampled every 5 knts
p=rand(size(s.vmax));
p=p*5-2.5;
s.vmax=s.vmax+p;

% Create KDE generation
tgenesis   = tim2(:,1);
for ii = 1:length(tgenesis)
    yearday(ii) = tgenesis(ii) - datenum(year(tgenesis(ii)),1,1);
end
f_tgenesis = kde(yearday');

% Create simple genesis
x = 1:365;
f = zeros(length(x),1);
for days = 1:365
    f(days) = sum(yearday == days)/length(yearday);
end
SmoothY=fastsmooth(f,14,1,1);

% Save genesis
s.tgenesis.f = SmoothY;
s.tgenesis.x = x;

% Save file
save(outputfile,'-struct','s');

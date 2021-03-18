function s=cyclonestats_compute_foreward_speed_components(s)

% First compute data for cyclone segments
dlon=s.lon(:,2:end)-s.lon(:,1:end-1);                     % dLon in deg
dlat=s.lat(:,2:end)-s.lat(:,1:end-1);                     % dLat in deg
dlon=111111.0*cos(s.lat(:,1:end-1)*pi/180).*dlon;         % dLon in m
dlat=111111.0*dlat;                                       % dLat in m
dt=86400*(s.time(:,2:end)-s.time(:,1:end-1));             % Time interval in s

allnans=zeros(size(s.lon));
allnans(allnans==0)=NaN;

s.u0=allnans;
s.v0=allnans;
s.u1=s.u0;
s.v1=s.v0;
s.u0(:,2:end)=dlon./dt;   % u velocity over previous stretch
s.v0(:,2:end)=dlat./dt;   % v velocity over previous stretch
s.u1(:,1:end-1)=dlon./dt; % u velocity over next stretch
s.v1(:,1:end-1)=dlat./dt; % v velocity over next stretch

s.vmax1=s.vmax;
s.vmax0=allnans;
s.vmax2=allnans;
for ii=1:size(s.vmax,1)
    for jj=2:size(s.vmax,2)
        s.vmax0(ii,jj)=s.vmax(ii,jj-1);
    end
    for jj=1:size(s.vmax,2)-1
        s.vmax2(ii,jj)=s.vmax(ii,jj+1);
    end
end

isn=isnan(s.u0) | isnan(s.u1);

s.u0(isn)=NaN;
s.v0(isn)=NaN;
s.u1(isn)=NaN;
s.v1(isn)=NaN;

isn=isnan(s.vmax0) | isnan(s.vmax1) | isnan(s.vmax2);
s.vmax0(isn)=NaN;
s.vmax2(isn)=NaN;
s.vmax1(isn)=NaN;
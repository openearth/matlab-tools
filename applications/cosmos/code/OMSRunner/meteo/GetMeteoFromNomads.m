function err=GetMeteoFromNomads(meteoname,cycledate,cyclehour,t,xlim,ylim,dirstr)

err=[];
ntry=10;

switch lower(meteoname)
    case{'ncep_gfs_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/analysis_complete';
        prstr='prmsl';
    case{'ncep_gfs'}
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_GFS/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfs_3_' datestr(cycledate,'yyyymmdd')  '_' num2str(cyclehour,'%0.2i') '00_fff'];
        prstr='prmsl';
    case{'gfs1p0'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs/gfs' datestr(cycledate,'yyyymmdd') '/gfs_' num2str(cyclehour,'%0.2i') 'z'];
        prstr='prmslmsl';
    case{'nam'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/nam/nam' datestr(cycledate,'yyyymmdd') '/nam_' num2str(cyclehour,'%0.2i') 'z'];
        prstr='prmslmsl';
    case{'gdas'}
        if year(now)~=year(cycledate)
            ystr=num2str(year(cycledate));
            mstr=num2str(month(cycledate),'%0.2i');
            dr=[ystr mstr '/'];
            extstr='';
        else
            dr='';
            extstr='.grib2';
        end
%        urlstr=['http://nomad3.ncep.noaa.gov:9090/dods/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
        urlstr=['http://nomad3.ncep.noaa.gov:9090/pub/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
        prstr='prmslmsl';
end

try

    ok=0;
    nok=0;
    while nok<ntry
        try
            att=loaddap('-A',[urlstr '?ugrd10m']);
            nok=ntry;
            ok=1;
        catch
            nok=nok+1;
            ok=0;
            pause(5);
        end
    end

    if ~ok
        err='could not find file';
        return
    end

    tmin=att.ugrd10m.time.minimum;
    tmax=att.ugrd10m.time.maximum;
    tmin=GetDatenum(tmin);
    tmax=GetDatenum(tmax);
    nt=att.ugrd10m.time.DODS_ML_Size;
    dt=(tmax-tmin)/(nt-1);
    times=tmin:dt:tmax;
    if ~isempty(t)
        it1=find(times==t(1))-1;
        it2=find(times<=t(end),1,'last')-1;
    else
        it1=0;
        it2=length(times)-1;
    end
    tstr=['[' num2str(it1) ':1:' num2str(it2) ']'];

    lon1=att.ugrd10m.lon.minimum;
    lon2=att.ugrd10m.lon.maximum;
    dlon=(lon2-lon1)/(att.ugrd10m.lon.DODS_ML_Size-1);
    lon=lon1:dlon:lon2;
    if ~isempty(xlim)
        ilon1=find(lon<=xlim(1), 1, 'last' )-1;
        ilon2=find(lon>=xlim(2), 1 )-1;
        lonstr=['[' num2str(ilon1) ':1:' num2str(ilon2) ']'];
    else
        lonstr=['[0:1:' num2str(length(lon)-1) ']'];
    end

    lat1=att.ugrd10m.lat.minimum;
    lat2=att.ugrd10m.lat.maximum;
    dlat=(lat2-lat1)/(att.ugrd10m.lat.DODS_ML_Size-1);
    lat=lat1:dlat:lat2;
    if ~isempty(ylim)
        ilat1=find(lat<=ylim(1), 1, 'last' )-1;
        ilat2=find(lat>=ylim(2), 1 )-1;
        latstr=['[' num2str(ilat1) ':1:' num2str(ilat2) ']'];
    else
        latstr=['[0:1:' num2str(length(lat)-1) ']'];
    end

    k=0;

    k=k+1;
    disp(datestr(times(k)));

    %% U-Wind
    url=[urlstr '?ugrd10m' tstr latstr lonstr];
    disp(url);
    tic
    disp('Loading ugrd10m ...');
    ok=0;
    nok=0;
    while nok<ntry
        try
            u0=loaddap(url);
            nok=ntry;
            ok=1;
        catch
            nok=nok+1;
            pause(5);
        end
    end
    toc
    if ~ok
        err='could not download ugrd10m';
        return
    end

    u=u0.ugrd10m.ugrd10m;

    x=u0.ugrd10m.lon;
    y=u0.ugrd10m.lat;


    %% V-Wind
    url=[urlstr '?vgrd10m' tstr latstr lonstr];
    tic
    disp('Loading vgrd10m ...');
    ok=0;
    nok=0;
    while nok<ntry
        try
            v0=loaddap(url);
            nok=ntry;
            ok=1;
        catch
            nok=nok+1;
            pause(5);
        end
    end
    toc
    if ~ok
        err='could not download vgrd10m';
        return
    end
    v=v0.vgrd10m.vgrd10m;

    %% Pressure
    url=[urlstr '?' prstr tstr latstr lonstr];
    tic
    disp('Loading prmsl ...');
    nok=0;
    while nok<ntry
        try
            p0=loaddap(url);
            nok=ntry;
            ok=1;
        catch
            nok=nok+1;
            pause(5);
        end
    end
    toc

    if ~ok
        err='could not download prmsl';
        return
    end

    p=p0.(prstr).(prstr);

%     %% Solar radiation (short wave)
%     url=[urlstr '?dswrfsfc' tstr latstr lonstr];
%     tic
%     disp('Loading dswrfsfc ...');
%     ok=0;
%     nok=0;
%     while nok<ntry
%         try
%             sw0=loaddap(url);
%             nok=ntry;
%             ok=1;
%         catch
%             nok=nok+1;
%             pause(5);
%         end
%     end
%     toc
%     if ~ok
%         err='could not download dswrfsfc';
%         return
%     end
%     sw=sw0.dswrfsfc.dswrfsfc;
% 
%     %% Temperature (2 m above ground)
%     url=[urlstr '?tmp2m' tstr latstr lonstr];
%     tic
%     disp('Loading tmp2m ...');
%     ok=0;
%     nok=0;
%     while nok<ntry
%         try
%             temp0=loaddap(url);
%             nok=ntry;
%             ok=1;
%         catch
%             nok=nok+1;
%             pause(5);
%         end
%     end
%     toc
%     if ~ok
%         err='could not download dswrfsfc';
%         return
%     end
%     temp=temp0.tmp2m.tmp2m;
% 
%     %% Relative humidity (2 m above ground)
%     url=[urlstr '?rh2m' tstr latstr lonstr];
%     tic
%     disp('Loading rh2m ...');
%     ok=0;
%     nok=0;
%     while nok<ntry
%         try
%             relhum0=loaddap(url);
%             nok=ntry;
%             ok=1;
%         catch
%             nok=nok+1;
%             pause(5);
%         end
%     end
%     toc
%     if ~ok
%         err='could not download dswrfsfc';
%         return
%     end
%     relhum=relhum0.rh2m.rh2m;
%     
    
    % Output
    k=0;
    for ii=it1:it2
        k=k+1;
        tstr=datestr(times(ii+1),'yyyymmddHHMMSS');
        s=[];
        s.t=times(ii+1);
        s.dLon=dlon;
        s.dLat=dlat;
        s.lon=x;
        s.lat=y;
        s.u=squeeze(u(:,:,k));
        s.v=squeeze(v(:,:,k));
        s.p=squeeze(p(:,:,k));
%         s.sw=squeeze(sw(:,:,k));
%         s.temp=squeeze(temp(:,:,k));
%         s.relhum=squeeze(relhum(:,:,k));
        fname=[meteoname '_' tstr '.mat'];
        disp([dirstr fname]);
        if ~exist(dirstr)
            mkdir(dirstr)
        end
        save([dirstr fname],'-struct','s');
    end

catch

    disp('Something went wrong downloading meteo data');
    a=lasterror;
    disp(a.stack(1));

end

%%
function tmin=GetDatenum(tmin)
tmin=strread(tmin,'%s','delimiter','"','whitespace','');
tmin=tmin{2};
tminHH=tmin(1:2);
tmindd=tmin(4:5);
tminmmm=tmin(6:8);
tminyyyy=tmin(9:12);
tmin=[tmindd '-' tminmmm '-' tminyyyy ' ' tminHH ':00'];
tmin=datenum(tmin);

%%
function y=year(t)
dv=datevec(t);
y=dv(1);

%%
function m=month(t)
dv=datevec(t);
m=dv(2);

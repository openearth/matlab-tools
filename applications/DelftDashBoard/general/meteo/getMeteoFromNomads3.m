function err=getMeteoFromNomads3(meteosource,meteoname,cycledate,cyclehour,t,xlim,ylim,dirstr,varargin)

includeHeat=0;
precip=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'includeheat'}
                includeHeat=varargin{i+1};
            case{'precipitation'}
                precip=varargin{i+1};
        end                
    end
end

err=[];
ntry=1;

cloudstr='otcdcclm';
prstr='prmslmsl';

switch lower(meteosource)
    case{'ncep_gfs_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/analysis_complete';
        prstr='prmsl';
    case{'ncep_gfs'}
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_GFS/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfs_3_' datestr(cycledate,'yyyymmdd')  '_' num2str(cyclehour,'%0.2i') '00_fff'];
        prstr='prmsl';
    case{'gfs1p0'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs/gfs' datestr(cycledate,'yyyymmdd') '/gfs_' num2str(cyclehour,'%0.2i') 'z'];
        cloudstr='tcdcclm';
    case{'gfs0p5'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_hd/gfs_hd' datestr(cycledate,'yyyymmdd') '/gfs_hd_' num2str(cyclehour,'%0.2i') 'z'];
        cloudstr='tcdcclm';
        xlim=mod(xlim,360);
    case{'nam'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/nam/nam' datestr(cycledate,'yyyymmdd') '/nam_' num2str(cyclehour,'%0.2i') 'z'];
        cloudstr='tcdcclm';
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
    case{'ncep_nam'}
        ystr=num2str(year(cycledate));
        mstr=num2str(month(cycledate),'%0.2i');
        dr=[ystr mstr '/'];
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_NAM/' dr datestr(cycledate,'yyyymmdd') '/nam_218_' datestr(cycledate,'yyyymmdd') '_' num2str(cyclehour,'%0.2i') '00_fff'];
    case{'ncepncar_reanalysis'}
        urlstr='http://nomad3.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-1/6hr/grb2d/grb2d';
        prstr='pressfc';
    case{'ncep_nam_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/Anl_Complete';
    case{'ncep_nam_analysis_precip'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/3hr_Pcp';
end

try

%     ok=1;
    
%     infr=nc_info(urlstr);
    
%     if ~ok
%         err='could not find file';
%         return
%     end

%     nanval1=att.ugrd10m.missing_value;
%     nanval2=att.ugrd10m.ml__FillValue;
%     nanval3=-999000000;
    
%     if isfield(infr,'DataSet')
%         infr.Dataset=infr.DataSet;
%         infr=rmfield(infr,'DataSet');
%     end
% 
%     %% Time
%     ii=fieldNr(infr.Dataset,'Name','time');
%     nt=infr.Dataset(ii).Size;
% 
%     jj=fieldNr(infr.Dataset(ii).Attribute,'Name','minimum');
%     tminstr=infr.Dataset(ii).Attribute(jj).Value;
%     tminstr=nc_attget(url,'time','minimum');
%     tminstr=deblank(strrep(tminstr,'z',' '));
%     tmin=datenum(tminstr,'HHddmmmyyyy');
% 
%     jj=fieldNr(infr.Dataset(ii).Attribute,'Name','maximum');
%     tmaxstr=infr.Dataset(ii).Attribute(jj).Value;
%     tmax=datenum(tmaxstr,'HHddmmmyyyy');

    tminstr=nc_attget(urlstr,'time','minimum');
    tmaxstr=nc_attget(urlstr,'time','maximum');
    tminstr=deblank(strrep(tminstr,'z',' '));
    tmaxstr=deblank(strrep(tmaxstr,'z',' '));
    tmin=datenum(tminstr,'HHddmmmyyyy');
    tmax=datenum(tmaxstr,'HHddmmmyyyy');
    timdim=nc_getdiminfo(urlstr,'time');
    nt=timdim.Length;
%     nanval1=nc_attget(urlstr,'ugrd10m','missing_value');
%     nanval2=nc_attget(urlstr,'ugrd10m','_FillValue');
%     nanval3=-999000000;

    dt=(tmax-tmin)/(nt-1);
    times=tmin:dt:tmax;
    if ~isempty(t)
        it1=find(times==t(1));
        it2=find(times<=t(end),1,'last');
    else
        it1=0;
        it2=length(times)-1;
    end
%     tstr=['[' num2str(it1) ':1:' num2str(it2) ']'];

    %% Longitude
    lon=nc_varget(urlstr,'lon');
    if ~isempty(xlim)
        ilon1=find(lon<=xlim(1), 1, 'last' );
        ilon2=find(lon>=xlim(2), 1 );
        if isempty(ilon1)
            ilon1=1;
        end
        if isempty(ilon2)
            ilon2=length(lon);
        end
    else
        ilon1=1;
        ilon2=length(lon);
    end

    %% Latitude
    lat=nc_varget(urlstr,'lat');
    if ~isempty(ylim)
        ilat1=find(lat<=ylim(1), 1, 'last' );
        ilat2=find(lat>=ylim(2), 1 );
        if isempty(ilat1)
            ilat1=1;
        end
        if isempty(ilat2)
            ilat2=length(lat);
        end
    else
        ilat1=1;
        ilat2=length(lat);
    end
    
    if ~precip
        parstr={'ugrd10m','vgrd10m',prstr,'dswrfsfc','tmp2m','rh2m',cloudstr};
        pr={'u','v','p','swrf','airtemp','relhum','cloudcover'};
        if includeHeat
            npar=length(parstr);
        else
            npar=3;
        end
    else
        parstr={'apcpsfc'};
        pr={'precip'};
        npar=1;
    end

    for i=1:npar
 
%         url=[urlstr '?' parstr{i} tstr latstr lonstr];
%         disp(url);
        tic
        disp(['Loading ' parstr{i} ' ...']);
        ok=0;
        nok=0;
        while nok<ntry
            try
%                disp([num2str([it1-1 ilat1-1 ilon1-1]) ' ' num2str([it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1])]);
                data=nc_varget(urlstr,parstr{i},[it1-1 ilat1-1 ilon1-1],[it2-it1+1 ilat2-ilat1+1 ilon2-ilon1+1]);
                nok=ntry;
                ok=1;
            catch
                disp(['Failed loading ' parstr{i} ' - trying again ...']);
                nok=nok+1;
                pause(5);
            end
        end
        toc
        if ~ok
            err=['could not download ' parstr{i}];
            return
        end

        d.(parstr{i})=data;
        nanval1=nc_attget(urlstr,parstr{i},'missing_value');
%         ii=fieldNr(infr.Dataset,'Name',parstr{i});
%         jj=fieldNr(infr.Dataset(ii).Attribute,'Name','missing_value');
%         nanval1=infr.Dataset(ii).Attribute(jj).Value;
        
        d.(parstr{i})(d.(parstr{i})==nanval1)=NaN;
%         d.(parstr{i})(d.(parstr{i})==nanval2)=NaN;
%         d.(parstr{i})(d.(parstr{i})==nanval3)=NaN;
        
        
        switch lower(parstr{i})
            case{'tmp2m'}
                tmpmax=max(max(max(d.(parstr{i}))));
                if tmpmax>200
                    % Probably Kelvin i.s.o. Celsius
                    d.(parstr{i})=d.(parstr{i})-273.15;
                end
        end

        nlon=(ilon2-ilon1);
        nlat=(ilat2-ilat1);
        dlon=(lon(ilon2)-lon(ilon1))/nlon;
        dlat=(lat(ilat2)-lat(ilat1))/nlat;
        x=lon(ilon1):dlon:lon(ilon2);
        y=lat(ilat1):dlat:lat(ilat2);
    
    end
        
    %% Output
    k=0;
    for ii=it1:it2
        k=k+1;
        for j=1:npar
            tstr=datestr(times(ii),'yyyymmddHHMMSS');
            s=[];
            s.t=times(ii);
            s.dLon=dlon;
            s.dLat=dlat;
            s.lon=x;
            s.lat=y;
            s.(pr{j})=squeeze(d.(parstr{j})(k,:,:));
            if ~isnan(max(max(s.(pr{j}))))
                fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                disp([dirstr fname]);
                save([dirstr fname],'-struct','s');
            end
        end
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

%%
function i=fieldNr(s,fld,val)
for i=1:length(s)
    if strcmpi(s(i).(fld),val)
        break
    end
end

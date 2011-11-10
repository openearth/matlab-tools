function err=getMeteoFromNomads3(meteosource,meteoname,cycledate,cyclehour,t,xlim,ylim,dirstr,parstr,pr,varargin)

err=[];
ntry=1;

urlstr = getMeteoUrl(meteosource,cycledate,cyclehour);
switch lower(meteosource)
    case{'gfs1p0','gfs0p5','ncep_gfs_analysis'}
        xlim=mod(xlim,360);
end

try

    tminstr=nc_attget(urlstr,'time','minimum');
    tmaxstr=nc_attget(urlstr,'time','maximum');
    tminstr=deblank(strrep(tminstr,'z',''));
    tmaxstr=deblank(strrep(tmaxstr,'z',''));
    tmin=datenum(tminstr(3:end),'ddmmmyyyy')+str2double(tminstr(1:2))/24;
    tmax=datenum(tmaxstr(3:end),'ddmmmyyyy')+str2double(tmaxstr(1:2))/24;
    timdim=nc_getdiminfo(urlstr,'time');
    nt=timdim.Length;

    dt=(tmax-tmin)/(nt-1);
    times=tmin:dt:tmax;
    if ~isempty(t)
        it1=find(abs(times-t(1))<0.01,1,'first');
        it2=find(times<=t(end),1,'last');
    else
        it1=0;
        it2=length(times)-1;
    end

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

    npar = length(parstr);

    for i=1:npar
 
        tic
        disp(['Loading ' parstr{i} ' ...']);
        ok=0;
        nok=0;
        while nok<ntry
            try
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
        
        d.(parstr{i})(d.(parstr{i})==nanval1)=NaN;        
        
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
                disp([dirstr filesep fname]);
                save([dirstr filesep fname],'-struct','s');
            else
                % Only NaNs found ...
                sz=size(s.(pr{j}));
                s.(pr{j})=zeros(sz);
                fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                disp([dirstr filesep fname]);
                save([dirstr filesep fname],'-struct','s');
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

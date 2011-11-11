function writeD3DMeteoFile4(meteodir,meteoname,rundir,fname,xlim,ylim,coordsys,coordsystype,reftime,tstart,tstop,varargin)
% Parameters can be any cell array with strings u, v, p, airtemp, relhum
% and cloud cover.

parameter={'u','v','p'};

dx=[];
dy=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'parameter'}
                parameter=varargin{i+1};
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
        end
    end
end

% If only dx or dy is given
if isempty(dx) && ~isempty(dy)
    dx=dy;
end
if ~isempty(dx) && isempty(dy)
    dy=dx;
end

% Make parameter a cell array
if ~iscell(parameter)
    p=parameter;
    parameter=[];
    parameter{1}=p;
end

% Add file separators to meteodir and run dir
if ~strcmpi(meteodir,filesep)
    meteodir=[meteodir filesep];
end
if ~strcmpi(rundir,filesep)
    rundir=[rundir filesep];
end

npar=length(parameter);

% Make rectangular grid (only for projected coordinate systems)

xlimg=xlim;ylimg=ylim;

% xlim(2)=max(xlim(2),xlim(1)+dx);
% ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=convertCoordinates(xg,yg,'persistent','CS1.name',coordsys,'CS1.type',coordsystype,'CS2.name','WGS 84','CS2.type','geographic');
    xlimg(1)=min(min(xgeo));
    xlimg(2)=max(max(xgeo));
    ylimg(1)=min(min(ygeo));
    ylimg(2)=max(max(ygeo));
    unit='m';
else
    unit='degree';
end

% Loop through parameters
for ipar=1:npar

    switch parameter{ipar}
        case{'u'}
            meteostr='x_wind';
            unitstr='m s-1';
            extstr='amu';
        case{'v'}
            meteostr='y_wind';
            unitstr='m s-1';
            extstr='amv';
        case{'p'}
            meteostr='air_pressure';
            unitstr='Pa';
            extstr='amp';
        case{'airtemp'}
            meteostr='air_temperature';
            unitstr='Celsius';
            extstr='amt';
        case{'relhum'}
            meteostr='relative_humidity';
            unitstr='%';
            extstr='amr';
        case{'cloudcover'}
            meteostr='cloudiness';
            unitstr='%';
            extstr='amc';
    end
    
    flist=dir([meteodir meteoname '.' parameter{ipar} '.*.mat']);
    for i=1:length(flist)
        tstr=flist(i).name(end-17:end-4);
        for j=1:10
            try
                t(i)=datenum(tstr,'yyyymmddHHMMSS');
                break
            catch
                pause(0.001);
            end
        end
    end
    it0=find(t<=tstart-0.001,1,'last');
    it1=find(t>=tstop+0.001,1,'first');
    
    if isempty(it0)
        it0=1;
    end

    if isempty(it1)
        it1=length(t);
    end

    for it=it0:it1
        
        s=load([meteodir flist(it).name]);
        
        [val,lon,lat]=getMeteoMatrix(s.(parameter{ipar}),s.lon,s.lat,xlimg,ylimg);
        
        if ~strcmpi(coordsystype,'geographic')
            val=interp2(lon,lat,val,xgeo,ygeo);
        end
        
        s2.time(it)=t(it);
        
        if ~strcmpi(coordsystype,'geographic')
            s2.x=xlim(1):dx:xlim(2);
            s2.y=ylim(1):dy:ylim(2);
            s2.dx=dx;
            s2.dy=dy;
        else
            if isfield(s,'dLon')
                csz(1)=s.dLon;
                csz(2)=s.dLat;
            else
                csz(1)=abs(s.lon(2)-s.lon(1));
                csz(2)=abs(s.lat(2)-s.lat(1));
            end
            s2.x=lon;
            s2.y=lat;
            s2.dx=csz(1);
            s2.dy=csz(2);
        end
        
        s2.(parameter{ipar})(:,:,it)=val;
        
    end
    
    writeD3Dmeteo([rundir fname '.' extstr],s2,parameter{ipar},meteostr,unitstr,unit,reftime);

end

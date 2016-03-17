function tc=readjmv30(fname)

tc.rhoa=1.15;
tc.radius_velocity=[34 50 64 100];
tc.wind_speed_unit='kts';
tc.radius_unit='NM';
tc.wind_conversion_factor=0.9;
tc.cs.name='WGS 84';
tc.cs.type='geographic';
tc.phi_spiral=20;

fid=fopen(fname,'r');

% Read header
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
str=fgetl(fid);
f=strread(str,'%s','delimiter',' ');
t0=datenum(f{1}(1:10),'yyyymmddHH');
tc.name=f{3};
tc.advisorynumber=str2double(f{4});

it=0;
while 1
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');
    if ~strcmpi(f{1}(1),'T')
        break
    end
    it=it+1;
    tc.track(it).time=t0+str2double(f{1}(2:end))/24;
    latstr=f{2};
    if strcmpi(latstr(end),'N')
        tc.track(it).y=0.10*str2double(latstr(1:end-1));
    else
        tc.track(it).y=-0.10*str2double(latstr(1:end-1));
    end
    lonstr=f{3};
    if strcmpi(lonstr(end),'E')
        tc.track(it).x=0.10*str2double(lonstr(1:end-1));
    else
        tc.track(it).x=-0.10*str2double(lonstr(1:end-1));
    end
    tc.track(it).vmax=str2double(f{4});
    for iq=1:4
        tc.track(it).quadrant(iq).radius=[NaN NaN NaN NaN];
    end
    for n=5:length(f)
        switch lower(f{n})
            case{'r034'}
                tc.track(it).quadrant(1).radius(1)=str2double(f{n+1});
                tc.track(it).quadrant(2).radius(1)=str2double(f{n+4});
                tc.track(it).quadrant(3).radius(1)=str2double(f{n+7});
                tc.track(it).quadrant(4).radius(1)=str2double(f{n+10});
            case{'r050'}
                tc.track(it).quadrant(1).radius(2)=str2double(f{n+1});
                tc.track(it).quadrant(2).radius(2)=str2double(f{n+4});
                tc.track(it).quadrant(3).radius(2)=str2double(f{n+7});
                tc.track(it).quadrant(4).radius(2)=str2double(f{n+10});
            case{'r064'}
                tc.track(it).quadrant(1).radius(3)=str2double(f{n+1});
                tc.track(it).quadrant(2).radius(3)=str2double(f{n+4});
                tc.track(it).quadrant(3).radius(3)=str2double(f{n+7});
                tc.track(it).quadrant(4).radius(3)=str2double(f{n+10});
            case{'r100'}
                tc.track(it).quadrant(1).radius(4)=str2double(f{n+1});
                tc.track(it).quadrant(2).radius(4)=str2double(f{n+4});
                tc.track(it).quadrant(3).radius(4)=str2double(f{n+7});
                tc.track(it).quadrant(4).radius(4)=str2double(f{n+10});
        end
    end
    
    tc.track(it).method=2;

end

fclose(fid);

tc.first_forecast_time=tc.track(1).time;

% Now read what came before
% First find position
fid=fopen(fname,'r');
n=0;
while 1
    n=n+1;
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');
    f=f{end};
    f=deblank2(f);
    if strcmpi(f(end-1:end),'//')
        istart=n+1;
    end
    if strcmpi(f,'NNNN')
        istop=n-2;
        break
    end
end
fclose(fid);

fid=fopen(fname,'r');
for ii=1:istart-1
    str=fgetl(fid);
end
it=0;
for ii=istart:istop
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');


    tim=datenum(f{1}(3:end),'yymmddHH');

    if it>0
        if abs(tim-tc0.track(it).time)<1/86400
            % Time was already given, skip this record
            continue
        end
    end
    
    it=it+1;
    
    tc0.track(it).time=datenum(f{1}(3:end),'yymmddHH');
    
%    latstr=f{2};
    idir=find(f{2}=='N');
    if isempty(idir)
        idir=find(f{2}=='S');
    end        
    latstr=f{2}(1:idir);
    if strcmpi(latstr(end),'N')
        tc0.track(it).y=0.10*str2double(latstr(1:end-1));
    else
        tc0.track(it).y=-0.10*str2double(latstr(1:end-1));
    end
        
    lonstr=f{2}(idir+1:end);
    if strcmpi(lonstr(end),'E')
        tc0.track(it).x=0.10*str2double(lonstr(1:end-1));
    else
        tc0.track(it).x=-0.10*str2double(lonstr(1:end-1));
    end
    
    yr=2000+str2double(f{1}(3:4));
    mn=str2double(f{1}(5:6));
    dy=str2double(f{1}(7:8));
    hr=str2double(f{1}(9:10));
    tc0.track(it).time=datenum(yr,mn,dy,hr,0,0);
    
%    tc0.vmax(it,1:4)=str2double(f{4}); 
    tc0.track(it).vmax=str2double(f{3}); 
    for iq=1:1
        for ir=1:1
            tc0.track(it).quadrant(iq).radius(ir)=NaN;
        end
    end

    tc0.track(it).method=7;
    
end

if abs(tc0.track(end).time-tc.track(1).time)<1/86400
    % Times of forecast and hindcast overlap
    tc0.track=tc0.track(1:end-1);
end

% Merge
tc.track=[tc0.track tc.track];

fclose(fid);


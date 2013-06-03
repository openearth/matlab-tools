function tc=readjmv30(fname)

fid=fopen(fname,'r');

% Read header
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
str=fgetl(fid);
f=strread(str,'%s','delimiter',' ');
t0=datenum(f{1}(1:10),'yyyymmddHH');
tc.name=f{3};
it=0;
while 1
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');
    if ~strcmpi(f{1}(1),'T')
        break
    end
    it=it+1;
    tc.time(it)=t0+str2double(f{1}(2:end))/24;
    latstr=f{2};
    if strcmpi(latstr(end),'N')
        tc.lat(it)=0.10*str2double(latstr(1:end-1));
    else
        tc.lat(it)=-0.10*str2double(latstr(1:end-1));
    end
    lonstr=f{3};
    if strcmpi(lonstr(end),'E')
        tc.lon(it)=0.10*str2double(lonstr(1:end-1));
    else
        tc.lon(it)=-0.10*str2double(lonstr(1:end-1));
    end
    tc.vmax(it,1:4)=str2double(f{4}); 
    tc.r34(it,1:4)=[NaN NaN NaN NaN];
    tc.r50(it,1:4)=[NaN NaN NaN NaN];
    tc.r64(it,1:4)=[NaN NaN NaN NaN];
    tc.r100(it,1:4)=[NaN NaN NaN NaN];
    for n=5:length(f)
        switch lower(f{n})
            case{'r034'}
                tc.r34(it,1)=str2double(f{n+1});
                tc.r34(it,2)=str2double(f{n+4});
                tc.r34(it,3)=str2double(f{n+7});
                tc.r34(it,4)=str2double(f{n+10});
            case{'r050'}
                tc.r50(it,1)=str2double(f{n+1});
                tc.r50(it,2)=str2double(f{n+4});
                tc.r50(it,3)=str2double(f{n+7});
                tc.r50(it,4)=str2double(f{n+10});
            case{'r064'}
                tc.r64(it,1)=str2double(f{n+1});
                tc.r64(it,2)=str2double(f{n+4});
                tc.r64(it,3)=str2double(f{n+7});
                tc.r64(it,4)=str2double(f{n+10});
            case{'r100'}
                tc.r100(it,1)=str2double(f{n+1});
                tc.r100(it,2)=str2double(f{n+4});
                tc.r100(it,3)=str2double(f{n+7});
                tc.r100(it,4)=str2double(f{n+10});
        end
    end
end


fclose(fid);

% Now read what came before
% First find position
fid=fopen(fname,'r');
n=0;
while 1
    n=n+1;
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ')
    if strcmpi(f{1},'//')
        istart=n+1;
    end
    if strcmpi(f{1},'NNNN')
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

    it=it+1;
    
    tc0.time(it)=datenum(f{1}(3:end),'yymmddHH');
    
    latstr=f{2};
    if strcmpi(latstr(end),'N')
        tc0.lat(it)=0.10*str2double(latstr(1:end-1));
    else
        tc0.lat(it)=-0.10*str2double(latstr(1:end-1));
    end
    lonstr=f{3};
    if strcmpi(lonstr(end),'E')
        tc0.lon(it)=0.10*str2double(lonstr(1:end-1));
    else
        tc0.lon(it)=-0.10*str2double(lonstr(1:end-1));
    end
    
    yr=2000+str2double(f{1}(3:4));
    mn=str2double(f{1}(5:6));
    dy=str2double(f{1}(7:8));
    hr=str2double(f{1}(9:10));
    tc0.time(it)=datenum(yr,mn,dy,hr,0,0);
    
    tc0.vmax(it,1:4)=str2double(f{4}); 
    tc0.r34(it,1:4)=[NaN NaN NaN NaN];
    tc0.r50(it,1:4)=[NaN NaN NaN NaN];
    tc0.r64(it,1:4)=[NaN NaN NaN NaN];
    tc0.r100(it,1:4)=[NaN NaN NaN NaN];
end

% Merge
tc.time=[tc0.time tc.time];
tc.lon=[tc0.lon tc.lon];
tc.lat=[tc0.lat tc.lat];
tc.vmax=[tc0.vmax;tc.vmax]; 
tc.r34=[tc0.r34;tc.r34]; 
tc.r50=[tc0.r50;tc.r50]; 
tc.r64=[tc0.r64;tc.r64]; 
tc.r100=[tc0.r100;tc.r100]; 

fclose(fid);


tc.r34(isnan(tc.r34))=-999;
tc.r50(isnan(tc.r50))=-999;
tc.r64(isnan(tc.r64))=-999;
tc.r100(isnan(tc.r100))=-999;

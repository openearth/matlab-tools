function tc=readBestTrackUnisys(fname)

fid=fopen(fname,'r');

n=0;

tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',' ');
nn=length(v0);
y=str2double(v0{nn});

tx0=fgets(fid);
name=tx0(1:end-1);

tc.name=name;

tx0=fgets(fid);

for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%s','delimiter',' ');
        lat=str2double(v0{2});
        lon=str2double(v0{3});
        tstr=v0{4};
        vel=str2double(v0{5});
        pr=v0{6};
        if isnan(str2double(pr))
            pr=1012;
        else
            pr=str2double(pr);
        end
        pr=pr*100;
        mm=str2double(tstr(1:2));
        dd=str2double(tstr(4:5));
        hh=str2double(tstr(7:8));
        tnew=datenum(y,mm,dd,hh,0,0);
        if n>1
            % If two identical consecutive times are found, only use the
            % first one!
            if tnew>tc.time(n)+0.001
                n=n+1;
            end
        else
            n=n+1;
        end
        tc.time(n)=tnew;
        tc.lon(n)=lon;
        tc.lat(n)=lat;
        tc.vmax(n,:)=[vel vel vel vel];
        tc.p(n,:)=[pr pr pr pr];
    else
        break;
    end
end

fclose(fid);

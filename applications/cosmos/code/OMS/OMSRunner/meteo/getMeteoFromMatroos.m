function err=getMeteoFromMatroos(meteoname,cycledate,cyclehour,tdummy,xlim,ylim,dirstr)
err=[];

try

    url='http://matroos.deltares.nl:8080/opendap/maps/normal/knmi_hirlam_maps/';

    ncfile=[datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];

    urlstr=[url ncfile];

    sx=nc_varget([url ncfile],'x');
    sy=nc_varget([url ncfile],'y');
    ny=length(sy);
    nx=length(sx);

    tdummy=tdummy(1):0.125:tdummy(2);
    
    nt = length(tdummy);

    urlasc=[urlstr '.ascii'];

    % Available Times

    url=[urlasc '?time' '[0:1:' num2str(nt-1) ']'];
    s=urlread(url);

    a = strread(s,'%s','delimiter','\n');

    b=strread(a{2},'%s','delimiter',',');
    for jj=1:nt
        t0=str2double(b{jj+1});
        t(jj)=datenum(1970,1,1)+t0/1440;
    end

    % Longitudes

    url=[urlasc '?x' '[0:1:' num2str(nx-1) ']'];
    s=urlread(url);

    a = strread(s,'%s','delimiter','\n');

    b=strread(a{2},'%s','delimiter',',');
    for jj=1:nx
        x(jj)=str2double(b{jj+1});
    end
    dx=(x(end)-x(1))/(nx-1);
    x=x(1):dx:x(end);

    % Latitudes

    url=[urlasc '?y' '[0:1:' num2str(ny-1) ']'];
    s=urlread(url);

    a = strread(s,'%s','delimiter','\n');

    b=strread(a{2},'%s','delimiter',',');
    for jj=1:ny
        y(jj)=str2double(b{jj+1});
    end
    dy=(y(end)-y(1))/(ny-1);
    y=y(1):dy:y(end);


    % Pressure

    url=[urlasc '?p' '[0:1:' num2str(nt-1) '][0:1:' num2str(ny-1) '][0:1:' num2str(nx-1) ']'];
    s=urlread(url);
    a = strread(s,'%s','delimiter','\n');

    nl=2;
    for it=1:nt
        for ii=1:ny
            nl=nl+1;
            b=strread(a{nl},'%s','delimiter',',');
            for jj=1:nx
                p(ii,jj,it)=str2double(b{jj+1});
            end
        end
    end

    % U-vel
    url=[urlasc '?wind_u' '[0:1:' num2str(nt-1) '][0:1:' num2str(ny-1) '][0:1:' num2str(nx-1) ']'];
    s=urlread(url);
    a = strread(s,'%s','delimiter','\n');

    nl=2;
    for it=1:nt
        for ii=1:ny
            nl=nl+1;
            b=strread(a{nl},'%s','delimiter',',');
            for jj=1:nx
                u(ii,jj,it)=str2double(b{jj+1});
            end
        end
    end

    % V-vel

    url=[urlasc '?wind_v' '[0:1:' num2str(nt-1) '][0:1:' num2str(ny-1) '][0:1:' num2str(nx-1) ']'];
    s=urlread(url);
    a = strread(s,'%s','delimiter','\n');

    nl=2;
    for it=1:nt
        for ii=1:ny
            nl=nl+1;
            b=strread(a{nl},'%s','delimiter',',');
            for jj=1:nx
                v(ii,jj,it)=str2double(b{jj+1});
            end
        end
    end

    % Output
    for ii=1:nt
        tstr=datestr(t(ii),'yyyymmddHHMMSS');
        s=[];
        s.t=t(ii);
        s.dLon=dx;
        s.dLat=dy;
        s.lon=x;
        s.lat=y;
        s.u=squeeze(u(:,:,ii));
        s.v=squeeze(v(:,:,ii));
        s.p=squeeze(p(:,:,ii));
        fname=[meteoname '.' tstr '.mat'];
        disp(fname);
        save([dirstr fname],'-struct','s');
    end

catch
    disp('Something went wrong downloading HIRLAM data ...');
    a=lasterror;
    for i=1:length(a.stack)
        disp(a.stack(i));
    end
end

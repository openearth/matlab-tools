function [val1,lon1,lat1]=getMeteoMatrix(val,lon,lat,xlim,ylim)

if size(lon,1)>1
    lon=lon';
end

if lon(end)-lon(1)>350
    % Probably covering the entire globe
    if lon(1)>=0
        lon=[lon-360 lon];
    else
        lon=[lon lon+360];
    end
    val=[val val];
    % Add one extra column
    lon(end+1)=lon(end);
    val(:,end+1)=val(:,end);
end

if xlim(2)<lon(1)
    lon=lon-360;
elseif xlim(1)>lon(end)
    lon=lon+360;
end

i1=find(lon>xlim(1), 1 )-1;
i2=find(lon<xlim(2), 1, 'last' )+1;
j1=find(lat>ylim(1), 1 )-1;
j2=find(lat<ylim(2), 1, 'last' )+1;

i1=max(i1,1);
i2=min(i2,length(lon));
j1=max(j1,1);
j2=min(j2,length(lat));

lon1=lon(i1:i2);
lat1=lat(j1:j2);
val1=val(j1:j2,i1:i2);

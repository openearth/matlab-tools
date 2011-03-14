function [dmin,dmax]=findMinMaxGridSize(xg,yg,varargin)

cstype='projected';
geofac=111111;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'cstype'}
                cstype=varargin{i+1};
        end
    end
end


dmin=1e9;
dmax=0;

xg1=xg(1:end-1,1:end);
xg2=xg(2:end,1:end);
xg3=xg(1:end,1:end-1);
xg4=xg(1:end,2:end);

yg1=yg(1:end-1,1:end);
yg2=yg(2:end,1:end);
yg3=yg(1:end,1:end-1);
yg4=yg(1:end,2:end);

switch lower(cstype)
    case{'geographic'}
        dstn=sqrt((geofac.*cos(pi*yg1/180).*(xg2-xg1)).^2+(geofac*(yg2-yg1)).^2);
    otherwise
        dstn=sqrt((xg2-xg1).^2+(yg2-yg1).^2);
end
dmin=min(dmin,min(min(dstn)));
dmax=max(dmax,max(max(dstn)));

switch lower(cstype)
    case{'geographic'}
dstn=sqrt((geofac.*cos(pi*yg3/180).*(xg4-xg3)).^2+(geofac*(yg4-yg3)).^2);
    otherwise
        dstn=sqrt((xg4-xg3).^2+(yg4-yg3).^2);
end
dmin=min(dmin,min(min(dstn)));
dmax=max(dmax,max(max(dstn)));

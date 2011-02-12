function len=computeLength(x,y,varargin)
geofac=111111;
cstype='projected';
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'cstype'}
                cstype=lower(varargin{i+1});
        end
    end
end
len=0;
for i=2:length(x)
    switch cstype
        case{'geographic'}
            dx=x(i)-x(i-1);
            dy=y(i)-y(i-1);
            dx=dx*geofac*cos(0.5*(y(i)+y(i-1))*pi/180);
            dy=dy*geofac;
            len=len+sqrt(dx^2+dy^2);            
        otherwise
            len=len+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
    end
end

function dd = dms2dd(d,m,s)
 error('%s has been deprecated',mfilename)
%converts degrees-minutes-seconds notation to decimal degrees

IO=d>0;

%east of greenwich meridian
ddE=d+(m/60)+(s/3600);
%west of greenwich meridian
ddW=d-(m/60)-(s/3600);

dd=IO.*ddE+~IO.*ddW;
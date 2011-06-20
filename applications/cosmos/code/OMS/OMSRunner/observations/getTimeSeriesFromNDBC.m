function [t,obs]=getTimeSeriesFromNDBC(urlstr,t0,t1,idcode,par)

dv1=datevec(now);
dv0=datevec(t1);

if dv1(1)>dv0(1)
    % Observations from a previous year
    yr=num2str(dv0(1));
    urlstr=[urlstr idcode '/' idcode 'h' yr '.nc'];
else
    urlstr=[urlstr idcode '/' idcode 'h9999.nc'];
end

t=nc_varget(urlstr,'time');
t=double(t);
t=datenum(1970,1,1)+t/86400;

it0=find(t>=t0,1,'first');
if t1>t(end)
    it1=length(t);
else
    it1=find(t>=t1,1,'first');
end

t=t(it0:it1);

obs=nc_varget(urlstr,par,[it0-1 0 0],[it1-it0+1 1 1]);

% att=loaddap('-A',[urlstr '?' par]);
% 
% nanval=att.(par).ml__FillValue;
% 
% nok=0;
% while nok<5
%     try
%         data=loaddap([urlstr '?' par]);
%         nok=5;
%     catch
%         system(killwdapstr);
%         disp('Process writedap.exe was killed');
%         nok=nok+1;
%         pause(1);
%     end
% end
% 
% obs=squeeze(data.(par).(par));
% ts=data.(par).time;
% 
% t=datenum(1970,1,1)+ts/86400;
% 
% it0=find(t>=t0,1,'first');
% it1=find(t>=t1,1,'first');
% 
% if isempty(it0)
%     it0=1;
% end
% if isempty(it1)
%     it1=length(t);
% end
% 
% t=t(it0:it1);
% obs=obs(it0:it1);
% 
% obs(obs==nanval)=NaN;
% 

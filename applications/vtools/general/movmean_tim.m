%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18279 $
%$Date: 2022-08-02 16:45:02 +0200 (Tue, 02 Aug 2022) $
%$Author: chavarri $
%$Id: absmintol.m 18279 2022-08-02 14:45:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absmintol.m $
%
%Moving mean based on time
%
%INPUT:
%   -time_dnum: time [dnum]
%   -data: data [nt,ns]
%   -window_w: [s] time to make the window average
%
%OUTPUT:
%   -filtered signal

function [fil,tim_re]=movmean_tim(time_dtime,data,window_s)

time_dnum=datenum(time_dtime); %we do operations in +00:00

dt=diff(time_dnum);
if any(abs(dt-dt(1))>1e-8)
%     tim_in=datetime(time_dnum,'convertFrom','datenum','TimeZone','+00:00');
%     tim_re=datetime(time_dnum(1):dt(1):time_dnum(end),'convertFrom','datenum','TimeZone','+00:00');
    dt_dtime=diff(time_dtime);
    dt_dtime=dt_dtime(1);
    tim_re=time_dtime(1):dt_dtime:time_dtime(end);
    data_re=interpolate_timetable({time_dtime},{data},tim_re,'disp',0);
%     time_dnum=datenum(data_re);
    data=data_re;
else
    tim_re=time_dtime;
end

if isvector(data)
    data=reshape(data,[],1);
end

num_ave=round((window_s/24/3600)/dt(1)); 
[np,nS]=size(data);
fil=NaN(np,nS);
for kS=1:nS
    fil(:,kS)=movmean(data,num_ave);
    fil(1:num_ave,kS)=NaN;
    fil(end-num_ave:end,kS)=NaN;
end

end %function
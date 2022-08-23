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

[tim_re,data]=uniform_data(time_dtime,data);

if isvector(data)
    data=reshape(data,[],1);
end

dt=diff(tim_re);

num_ave=round((window_s/24/3600)/dt(1)); 
[np,nS]=size(data);
fil=NaN(np,nS);
for kS=1:nS
    fil(:,kS)=movmean(data,num_ave);
    fil(1:num_ave,kS)=NaN;
    fil(end-num_ave:end,kS)=NaN;
end

end %function